const MATCH_COUNT_KEY: felt252 = 'match_idx_key';
const RANKING_COUNT_KEY: felt252 = 'ranking_idx_key';

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
        MatchCount { id, index }
    }
}

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
    fn new(
        owner: felt252, character_id: u32, skin_id: u32, owned: bool, level: u32
    ) -> CharacterPlayerProgress;
}

impl CharacterPlayerProgressImpl of CharacterPlayerProgressTrait {
    fn new(
        owner: felt252, character_id: u32, skin_id: u32, owned: bool, level: u32
    ) -> CharacterPlayerProgress {
        CharacterPlayerProgress { owner, character_id, skin_id, owned, level }
    }
}

// calculate_attack(cahracetr, character_progress.level)  

// relacion user -> score by match o total score
#[derive(Model, Copy, Drop, Serde)]
struct PlayerStadistics {
    #[key]
    owner: felt252,
    matchs_won: u64,
    matchs_lost: u64,
    characters_owned: u32,
    total_score: u64,
}

#[derive(Model, Copy, Drop, Serde)]
struct Ranking {
    #[key]
    id: u32,
    player: felt252,
    score: u64
}

trait RankingTrait {
    fn new(id: u32, player: felt252, score: u64) -> Ranking;
}

impl RankingImpl of RankingTrait {
    fn new(id: u32, player: felt252, score: u64) -> Ranking {
        Ranking { id, player, score }
    }
}

impl RankingPartialEq of PartialEq<Ranking> {
    fn eq(lhs: @Ranking, rhs: @Ranking) -> bool {
        lhs.player == rhs.player
    }

    fn ne(lhs: @Ranking, rhs: @Ranking) -> bool {
        lhs.player != rhs.player
    }
}

impl RankingPartialOrd of PartialOrd<Ranking> {
    #[inline(always)]
    fn le(lhs: Ranking, rhs: Ranking) -> bool {
        lhs.score <= rhs.score
    }
    fn ge(lhs: Ranking, rhs: Ranking) -> bool {
        lhs.score >= rhs.score
    }
    fn lt(lhs: Ranking, rhs: Ranking) -> bool {
        lhs.score < rhs.score
    }
    fn gt(lhs: Ranking, rhs: Ranking) -> bool {
        lhs.score > rhs.score
    }
}

#[derive(Model, Copy, Drop, Serde)]
struct RankingCount {
    #[key]
    id: felt252,
    index: u32,
}

trait RankingCountTrait {
    fn new(index: u32) -> RankingCount;
}

impl RankingCountImpl of RankingCountTrait {
    fn new(index: u32) -> RankingCount {
        RankingCount { id: RANKING_COUNT_KEY, index }
    }
}
