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
    player_address_turn: felt252,
    map: Map,
    over: bool,
}

#[derive(Model, Copy, Drop, Serde)]
struct GameIdx {
    #[key]
    world_address: felt252,
    idx: u32,
}

trait GameTrait {
    fn new(world: IWorldDispatcher, world_address: felt252) -> GameState;
}

impl GameImpl of GameTrait {
    #[inline(always)]
    fn new(world: IWorldDispatcher, world_address: felt252) -> GameState {
        let game_idx = get!(world, (world_address), (GameIdx));
        let new_game_state = GameState {
            game_id: game_idx.idx + 1,
            turn: 0,
            player_address_turn: 0,
            // TODO: for now we only have one map
            map: MapTrait::new(0),
            over: false
        };

        set!(world, (new_game_state));
        set!(world, GameIdx {world_address: game_idx.world_address, idx: game_idx.idx + 1 });
        new_game_state
    }
}
