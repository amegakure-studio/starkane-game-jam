use arcane_abyss::models::map::{Position, Map};

#[derive(Model, Copy, Drop, Serde)]
struct ActionState {
    #[key]
    key: u32,
    id: u32,
    action: bool,
    movement: bool,
}

#[derive(Model, Copy, Drop, Serde)]
struct CharacterState {
    #[key]
    game_id: u32,
    #[key]
    key: u32,
    id: u32,
    character_id: u32,
    action_state: ActionState,
    remain_hp: u128,
    remain_mp: u128,
    position: Position,
}

#[derive(Model, Copy, Drop, Serde)]
struct Game {
    #[key]
    key: felt252,
    #[key]
    id: u32,
    turn: u128,
    map: Map,
    over: bool,
}

trait GameTrait {
    fn new(key: felt252, id: u32) -> Game;
}
// impl GameImpl of GameTrait {
//     #[inline(always)]
//     fn new(key: felt252, id: u32) -> Game {

//         Game {
//             key: key,
//             id: id,
//         }
//     }
// }


