use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use starkane::models::entities::map_cc::{MapCC, MapCCTrait};

#[derive(Model, Copy, Drop, Serde)]
struct MatchState {
    #[key]
    id: u32,
    turn: u32,
    player_turn: felt252,
    map_id: u32,
    winner: felt252,
}

#[derive(Model, Copy, Drop, Serde)]
struct MatchPlayerLen {
    #[key]
    match_id: u32,
    players_len: u32,
}

#[derive(Model, Copy, Drop, Serde)]
struct MatchPlayer {
    #[key]
    match_id: u32,
    #[key]
    id: u32,
    player: felt252,
}

#[derive(Model, Copy, Drop, Serde)]
struct MatchPlayerCharacterLen {
    #[key]
    match_id: u32,
    #[key]
    player: felt252,
    characters_len: u32,
    remain_characters: u32,
}

#[derive(Model, Copy, Drop, Serde)]
struct MatchPlayerCharacter {
    #[key]
    match_id: u32,
    #[key]
    player: felt252,
    #[key]
    id: u32,
    character_id: u32,
}

trait MatchTrait {
    fn new(match_id: u32, map_id: u32) -> MatchState;
}

impl MatchImpl of MatchTrait {
    #[inline(always)]
    fn new(match_id: u32, map_id: u32) -> MatchState {
        MatchState { id: match_id, turn: 0, player_turn: 0, map_id, winner: 0 }
    }
}
