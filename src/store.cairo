//! Store struct and component management methods.

// Dojo imports

use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

// Components imports

use starkane::models::game::{CharacterState, GameState};
use starkane::models::character::Character;

/// Store struct.
#[derive(Drop)]
struct Store {
    world: IWorldDispatcher
}

/// Trait to initialize, get and set components from the Store.
trait StoreTrait {
    fn new(world: IWorldDispatcher) -> Store;
    // State
    fn get_game_state(ref self: Store, game_state_id: u32) -> GameState;
    fn set_game_state(ref self: Store, game_state: GameState);
    fn get_character_state(
        ref self: Store, game_state: GameState, character_id: u32, turn: u32
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
    fn get_game_state(ref self: Store, game_state_id: u32) -> GameState {
        get!(self.world, game_state_id, (GameState))
    }

    #[inline(always)]
    fn set_game_state(ref self: Store, game_state: GameState) {
        set!(self.world, (game_state));
    }

    fn get_character_state(
        ref self: Store, game_state: GameState, character_id: u32, turn: u32
    ) -> CharacterState {
        let character_state_key = (game_state.game_id, character_id, turn);
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
