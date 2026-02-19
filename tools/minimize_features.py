#!/usr/bin/env python3

"""
Shed a light on what actual cargo features are being used
"""

import argparse
import json
import re
import subprocess
from collections import defaultdict

TREE_LINE = re.compile(r"^([0-9]+)(.+)$")
FEATURES_RE = re.compile(r'feature "([^"]+)"')


def run(cmd, cwd=None):
    return subprocess.check_output(cmd, cwd=cwd, text=True)


def parse_tree(tree_text):
    feature_flags = defaultdict(set)
    uses_default = defaultdict(bool)
    for line in tree_text.splitlines():
        m = TREE_LINE.match(line)
        if not m:
            continue
        depth = int(m.group(1))
        rest = m.group(2).strip()
        # Only depth 1 feature lines correspond to direct deps
        if depth != 1:
            continue
        fm = FEATURES_RE.search(rest)
        if not fm:
            continue
        name = rest.split()[0]
        feat = fm.group(1).strip()
        if feat == "default":
            uses_default[name] = True
        else:
            feature_flags[name].add(feat)
    return feature_flags, uses_default


def load_direct_deps(args):
    cmd = ["cargo", "metadata", "--format-version", "1", "--no-deps"]
    if not args.online:
        cmd.append("--offline")
    if args.manifest_path:
        cmd += ["--manifest-path", args.manifest_path]
    data = json.loads(run(cmd))
    if not args.package:
        # pick workspace root package
        root_id = data.get("resolve", {}).get("root")
        for p in data["packages"]:
            if p["id"] == root_id:
                args.package = p["name"]
                break
    pkg = None
    for p in data["packages"]:
        if p["name"] == args.package:
            pkg = p
            break
    if not pkg:
        raise SystemExit(f"package not found: {args.package}")
    direct = []
    for dep in pkg["dependencies"]:
        if dep["kind"] in (None, "normal") and dep["target"] is None:
            direct.append(dep["name"])
    return direct


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("-p", "--package", help="package name (as cargo -p)")
    ap.add_argument("--manifest-path", help="path to Cargo.toml")
    ap.add_argument("--edges", default="normal", help="cargo tree edges (default: normal)")
    ap.add_argument("--online", action="store_true", help="allow network access")
    args = ap.parse_args()

    cmd = ["cargo", "tree", "-e", "features", "--prefix", "depth", "--edges", args.edges]
    if not args.online:
        cmd.append("--offline")
    if args.package:
        cmd += ["-p", args.package]
    if args.manifest_path:
        cmd += ["--manifest-path", args.manifest_path]

    tree = run(cmd)
    feature_flags, uses_default = parse_tree(tree)
    direct_deps = load_direct_deps(args)

    out = {}
    for name in sorted(direct_deps):
        feats = sorted(feature_flags.get(name, set()))
        out[name] = {"features": feats, "uses_default": uses_default.get(name, False)}

    print(json.dumps(out, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
