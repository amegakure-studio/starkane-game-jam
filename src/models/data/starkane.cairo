const GAME_IDX_KEY: felt252 = 'game_idx_key';

#[derive(Model, Copy, Drop, Serde)]
struct MatchIndex {
    #[key]
    id: felt252,
    index: u32,
}

// relacion user -> characters (unico con nivel, exp, etc)
#[derive(Model, Copy, Drop, Serde)]
struct CharacterPlayerProgress {
    #[key]
    owner: felt252,
    #[key]
    character_id: u32,
    owned: bool,
    level: u32,
}

// calculate_attack(cahracetr, character_progress.level)  

// relacion user -> score by game o total score
#[derive(Model, Copy, Drop, Serde)]
struct PlayerStadistics {
    #[key]
    owner: felt252,
    games_won: u128,
    games_lost: u128,
    characters_owned: u32,
    total_score: u256,
}
