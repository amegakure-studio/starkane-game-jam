//! Store struct and component management methods.

// Dojo imports

use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

// Components imports

use starkane::models::states::match_state::MatchState;
use starkane::models::states::character_state::CharacterState;
use starkane::models::entities::character::Character;

/// Store struct.
#[derive(Drop)]
struct Store {
    world: IWorldDispatcher
}

/// Trait to initialize, get and set components from the Store.
trait StoreTrait {
    fn new(world: IWorldDispatcher) -> Store;
    // State
    fn get_match_state(ref self: Store, match_state_id: u32) -> MatchState;
    fn set_match_state(ref self: Store, match_state: MatchState);
    fn get_character_state(
        ref self: Store, match_state: MatchState, character_id: u32, turn: u32
    ) -> CharacterState;
    fn set_character_state(ref self: Store, character_state: CharacterState);
    // Game
    fn get_character(ref self: Store, character_id: u32) -> Character;
    fn set_character(ref self: Store, character: Character);
}

/// Implementation of the `StoreTrait` trait for the `Store` struct.
impl StoreImpl of StoreTrait {
    #[inline(always)]
    fn new(world: IWorldDispatcher) -> Store {
        Store { world: world }
    }

    // State

    #[inline(always)]
    fn get_match_state(ref self: Store, match_state_id: u32) -> MatchState {
        get!(self.world, match_state_id, (MatchState))
    }

    #[inline(always)]
    fn set_match_state(ref self: Store, match_state: MatchState) {
        set!(self.world, (match_state));
    }

    fn get_character_state(
        ref self: Store, match_state: MatchState, character_id: u32, turn: u32
    ) -> CharacterState {
        let character_state_key = (match_state.id, character_id, turn);
        get!(self.world, character_state_key.into(), (CharacterState))
    }

    fn set_character_state(ref self: Store, character_state: CharacterState) {
        set!(self.world, (character_state));
    }

    // Game

    fn get_character(ref self: Store, character_id: u32) -> Character {
        get!(self.world, character_id, (Character))
    }

    fn set_character(ref self: Store, character: Character) {
        set!(self.world, (character));
    }
}
