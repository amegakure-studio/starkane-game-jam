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
    player: felt252,
    turn: u32,
    action_state: ActionState,
    remain_hp: u128,
    remain_mp: u128,
    x: u128,
    y: u128,
}
