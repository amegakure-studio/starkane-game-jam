use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use starkane::models::map::{Map, MapTrait};

#[derive(Model, Copy, Drop, Serde)]
struct ActionState {
    #[key]
    game_id: u32,
    #[key]
    character_id: u32,
    action: bool,
    movement: bool,
}

#[derive(Model, Copy, Drop, Serde)]
struct CharacterState {
    #[key]
    game_id: u32,
    #[key]
    character_id: u32,
    #[key]
    turn: u32,
    player: felt252,
    action_state: ActionState,
    remain_hp: u128,
    remain_mp: u128,
    x: u128,
    y: u128,
}

#[derive(Model, Copy, Drop, Serde)]
struct GameState {
    #[key]
    game_id: u32,
    turn: u32,
    player_turn: felt252,
    players_len: u32,
    characters_len: u32, 
    map: Map,
    over: bool,
}

#[derive(Model, Copy, Drop, Serde)]
struct GamePlayer {
    #[key]
    game_id: u32,
    #[key]
    id: u32,
    player: felt252,
}

const GAME_IDX_KEY: felt252 = 'game_idx_key';

#[derive(Model, Copy, Drop, Serde)]
struct GameIndex {
    #[key]
    id: felt252,
    index: u32,
}

trait GameTrait {
    fn new(game_id: u32) -> GameState;
}

impl GameImpl of GameTrait {
    #[inline(always)]
    fn new(game_id: u32) -> GameState {
        GameState {
            game_id: game_id,
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
