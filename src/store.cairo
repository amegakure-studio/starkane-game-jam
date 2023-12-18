//! Store struct and component management methods.

// Dojo imports

use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

// Components imports

use starkane::models::states::match_state::{MatchState, MatchPlayerLen, MatchPlayer, MatchPlayerCharacterLen, MatchPlayerCharacter};
use starkane::models::states::character_state::{CharacterState, ActionState};
use starkane::models::entities::character::Character;
use starkane::models::entities::skill::Skill;
use starkane::models::entities::map::{Map, Tile};
use starkane::models::data::starkane::{CharacterPlayerProgress, MatchCount};

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
        ref self: Store, match_state_id: u32, character_id: u32, player: felt252
    ) -> CharacterState;
    fn set_character_state(ref self: Store, character_state: CharacterState);
    fn get_action_state(ref self: Store, match_state_id: u32, character_id: u32, player: felt252) -> ActionState;
    fn set_action_state(ref self: Store, action_state: ActionState);
    fn get_match_players(ref self: Store, match_id: u32) -> Array<MatchPlayer>;
    // fn set_match_players(ref self: Store, match_players: MatchPlayers);
    fn get_match_player_characters_states(ref self: Store, match_id: u32, player: felt252) -> Array<CharacterState>;
    fn get_match_player_characters(ref self: Store, match_id: u32, player: felt252) -> Array<Character>;
    // Entities
    fn get_character(ref self: Store, character_id: u32) -> Character;
    fn set_character(ref self: Store, character: Character);
    fn get_skill(ref self: Store, skill_id: u32, character_id: u32, level: u32) -> Skill;
    fn set_skill(ref self: Store, skill: Skill);
    fn get_tile(ref self: Store, map_id: u32, tile_id: u32) -> Tile;
    fn set_tile(ref self: Store, tile: Tile);
    fn get_map(ref self: Store, map_id: u32) -> Map;
    fn set_map(ref self: Store, map: Map);
    // Data
    fn get_match_count(ref self: Store, id: felt252) -> MatchCount;
    fn set_match_count(ref self: Store, match_count: MatchCount);
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
        ref self: Store, match_state_id: u32, character_id: u32, player: felt252
    ) -> CharacterState {
        let character_state_key = (match_state_id, character_id, player);
        get!(self.world, character_state_key.into(), (CharacterState))
    }

    fn set_character_state(ref self: Store, character_state: CharacterState) {
        set!(self.world, (character_state));
    }

    fn get_action_state(ref self: Store, match_state_id: u32, character_id: u32, player: felt252) -> ActionState {
        let action_state_key = (match_state_id, character_id, player);
        get!(self.world, action_state_key.into(), (ActionState))
    }

    fn set_action_state(ref self: Store, action_state: ActionState) {
        set!(self.world, (action_state));
    }

    fn get_match_players(ref self: Store, match_id: u32) -> Array<MatchPlayer> {
        let match_players_len = get!(self.world, (match_id), (MatchPlayerLen));
        let mut i = 0;
        let mut match_players = array![];

        loop {
            if match_players_len.players_len == i {
                break;
            }
            match_players.append(get!(self.world, (match_id, i).into(), (MatchPlayer)));
            i += 1;
        };
        match_players
    }
    
    // fn set_match_players(ref self: Store, match_players: MatchPlayers) {
    //     set!(self.world, (match_players));
    // }

    fn get_match_player_characters_states(ref self: Store, match_id: u32, player: felt252) -> Array<CharacterState> {
        let match_player_info = get!(self.world, (match_id, player).into(), (MatchPlayerCharacterLen));
        
        assert(match_player_info.characters_len.is_non_zero(), 'player characters is zero');
        let mut characters_states = array![]; 
        let mut i = 0;
        loop {
            if match_player_info.characters_len == i {
                break;
            }
            let match_player_character = get!(self.world, (match_id, player, i), (MatchPlayerCharacter));
            characters_states.append(get!(self.world, (match_id, match_player_character.character_id, player), (CharacterState)));
            i += 1;
        };
        characters_states
    }

    fn get_match_player_characters(ref self: Store, match_id: u32, player: felt252) -> Array<Character> {
        let match_player_info = get!(self.world, (match_id, player).into(), (MatchPlayerCharacterLen));
        
        assert(match_player_info.characters_len.is_non_zero(), 'player characters is zero');
        let mut characters = array![]; 
        let mut i = 0;
        loop {
            if match_player_info.characters_len == i {
                break;
            }
            let match_player_character = get!(self.world, (match_id, player, i), (MatchPlayerCharacter));
            characters.append(get!(self.world, match_player_character.character_id, (Character)));
            i += 1;
        };
        characters
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

    fn get_map(ref self: Store, map_id: u32) -> Map {
        get!(self.world, map_id, (Map))
    }

    fn set_map(ref self: Store, map: Map) {
        set!(self.world, (map));
    }

    // Data

    fn get_match_count(ref self: Store, id: felt252) -> MatchCount {
        get!(self.world, id, (MatchCount))
    }

    fn set_match_count(ref self: Store, match_count: MatchCount) {
        set!(self.world, (match_count));
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
