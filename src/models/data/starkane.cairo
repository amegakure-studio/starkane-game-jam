const MATCH_COUNT_KEY: felt252 = 'match_idx_key';

#[derive(Model, Copy, Drop, Serde)]
struct MatchCount {
    #[key]
    id: felt252,
    index: u32,
}

trait MatchCountTrait {
    fn new(id: felt252, index: u32) -> MatchCount;
}

impl MatchCountImpl of MatchCountTrait {
    fn new(id: felt252, index: u32) -> MatchCount {
        MatchCount {
            id, 
            index
        }
    }
}

// relacion user -> characters (unico con nivel, exp, etc)
#[derive(Model, Copy, Drop, Serde)]
struct CharacterPlayerProgress {
    #[key]
    owner: felt252,
    #[key]
    character_id: u32,
    skin_id: u32,
    owned: bool,
    level: u32,
}

trait CharacterPlayerProgressTrait {
    fn new(owner: felt252, character_id: u32, skin_id: u32, owned: bool, level: u32) -> CharacterPlayerProgress;
}

impl CharacterPlayerProgressImpl of CharacterPlayerProgressTrait {
    fn new(owner: felt252, character_id: u32, skin_id: u32, owned: bool, level: u32) -> CharacterPlayerProgress {
        CharacterPlayerProgress {
            owner,
            character_id,
            skin_id,
            owned,
            level
        }
    }
}

// calculate_attack(cahracetr, character_progress.level)  

// relacion user -> score by match o total score
#[derive(Model, Copy, Drop, Serde)]
struct PlayerStadistics {
    #[key]
    owner: felt252,
    matchs_won: u128,
    matchs_lost: u128,
    characters_owned: u32,
    total_score: u256,
}
