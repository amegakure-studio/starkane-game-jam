//! Store struct and component management methods.

// Dojo imports

use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

// Components imports

use starkane::models::states::match_state::MatchState;
use starkane::models::states::character_state::CharacterState;
use starkane::models::entities::character::Character;
use starkane::models::entities::skill::Skill;
use starkane::models::entities::map::Tile;
use starkane::models::data::starkane::{CharacterPlayerProgress, MatchIndex};

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
        ref self: Store, match_state: MatchState, character_id: u32, player: felt252
    ) -> CharacterState;
    fn set_character_state(ref self: Store, character_state: CharacterState);
    // Entities
    fn get_character(ref self: Store, character_id: u32) -> Character;
    fn set_character(ref self: Store, character: Character);
    fn get_skill(ref self: Store, skill_id: u32, character_id: u32, level: u32) -> Skill;
    fn set_skill(ref self: Store, skill: Skill);
    fn get_tile(ref self: Store, map_id: u32, tile_id: u32) -> Tile;
    fn set_tile(ref self: Store, tile: Tile);
    // Data
    fn get_match_index(ref self: Store, id: felt252) -> MatchIndex;
    fn set_match_index(ref self: Store, match_index: MatchIndex);
    fn get_character_player_progress(
        ref self: Store, owner: felt252, character_id: u32
    ) -> CharacterPlayerProgress;
    fn set_character_player_progress(
        ref self: Store, character_player_progress: CharacterPlayerProgress
    );
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
        ref self: Store, match_state: MatchState, character_id: u32, player: felt252
    ) -> CharacterState {
        let character_state_key = (match_state.id, character_id, player);
        get!(self.world, character_state_key.into(), (CharacterState))
    }

    fn set_character_state(ref self: Store, character_state: CharacterState) {
        set!(self.world, (character_state));
    }

    // Entities

    fn get_character(ref self: Store, character_id: u32) -> Character {
        get!(self.world, character_id, (Character))
    }

    fn set_character(ref self: Store, character: Character) {
        set!(self.world, (character));
    }

    fn get_skill(ref self: Store, skill_id: u32, character_id: u32, level: u32) -> Skill {
        let skill_key = (skill_id, character_id, level);
        get!(self.world, skill_key.into(), (Skill))
    }

    fn set_skill(ref self: Store, skill: Skill) {
        set!(self.world, (skill));
    }

    fn get_tile(ref self: Store, map_id: u32, tile_id: u32) -> Tile {
        let tile_key = (map_id, tile_id);
        get!(self.world, tile_key.into(), (Tile))
    }

    fn set_tile(ref self: Store, tile: Tile) {
        set!(self.world, (tile));
    }

    // Data

    fn get_match_index(ref self: Store, id: felt252) -> MatchIndex {
        get!(self.world, id, (MatchIndex))
    }

    fn set_match_index(ref self: Store, match_index: MatchIndex) {
        set!(self.world, (match_index));
    }

    fn get_character_player_progress(
        ref self: Store, owner: felt252, character_id: u32
    ) -> CharacterPlayerProgress {
        let character_player_progress_key = (owner, character_id);
        get!(self.world, character_player_progress_key.into(), (CharacterPlayerProgress))
    }

    fn set_character_player_progress(
        ref self: Store, character_player_progress: CharacterPlayerProgress
    ) {
        set!(self.world, (character_player_progress));
    }
}
