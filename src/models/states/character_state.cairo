#[derive(Model, Copy, Drop, Serde)]
struct ActionState {
    #[key]
    match_id: u32,
    #[key]
    character_id: u32,
    #[key]
    player: felt252,
    action: bool,
    movement: bool,
}

trait ActionStateTrait {
    fn new(match_id: u32, character_id: u32, player: felt252, action: bool, movement: bool) -> ActionState;
}

impl ActionStateImpl of ActionStateTrait {
    fn new(match_id: u32, character_id: u32, player: felt252, action: bool, movement: bool) -> ActionState {
        ActionState {
            match_id,
            character_id,
            player,
            action,
            movement,
        }
    }
}

#[derive(Model, Copy, Drop, Serde)]
struct CharacterState {
    #[key]
    match_id: u32,
    #[key]
    character_id: u32,
    #[key]
    player: felt252,
    turn: u32,
    remain_hp: u128,
    remain_mp: u128,
    x: u128,
    y: u128,
}

trait CharacterStateTrait {
    fn new(match_id: u32, character_id: u32, player: felt252, turn: u32, remain_hp: u128, remain_mp: u128, x: u128, y: u128) -> CharacterState;
}

impl CharacterStateImpl of CharacterStateTrait {
    fn new(match_id: u32, character_id: u32, player: felt252, turn: u32, remain_hp: u128, remain_mp: u128, x: u128, y: u128) -> CharacterState {
        CharacterState {
            match_id,
            character_id,
            player,
            turn,
            remain_hp,
            remain_mp,
            x,
            y,
        }
    }
}
