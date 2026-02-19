use crate::graph::prelude::{Generator, GeneratorState, Rng};
use synth_gen::Never;
use uuid::Uuid;

pub struct UuidGen {}

impl Generator for UuidGen {
    type Yield = String;
    type Return = Never;

    fn next<R: Rng>(&mut self, rng: &mut R) -> GeneratorState<Self::Yield, Self::Return> {
        let uuid = Uuid::from_u128(rng.random());
        GeneratorState::Yielded(uuid.hyphenated().to_string())
    }
}
