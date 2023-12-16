use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use starkane::models::entities::map::{Map, MapTrait};

#[derive(Model, Copy, Drop, Serde)]
struct MatchState {
    #[key]
    id: u32,
    turn: u32,
    player_turn: felt252,
    players_len: u32,
    characters_len: u32,
    map: Map,
    over: bool,
}

#[derive(Model, Copy, Drop, Serde)]
struct MatchPlayers {
    #[key]
    game_id: u32,
    #[key]
    id: u32,
    player: felt252,
}

trait MatchTrait {
    fn new(match_id: u32) -> MatchState;
}

impl MatchImpl of MatchTrait {
    #[inline(always)]
    fn new(match_id: u32) -> MatchState {
        MatchState {
            id: match_id,
            turn: 0,
            player_turn: 0,
            players_len: 0,
            characters_len: 0,
            // TODO: for now we only have one map
            map: MapTrait::new(0),
            over: false
        }
    }
}
