use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

#[derive(Serde, Copy, Drop, PartialEq)]
enum CharacterType {
    Archer,
    Cleric,
    Warrior,
    Goblin,
    // Peasant character doesnt have crit or evasion stats, mainly for tests
    Peasant,
    Goblin2,
    Goblin3,
}

#[derive(Model, Copy, Drop, Serde)]
struct Character {
    #[key]
    character_id: u32,
    character_type: u8,
    hp: u64,
    mp: u64,
    attack: u64,
    defense: u64,
    evasion: u64,
    crit_chance: u64,
    crit_rate: u64,
    movement_range: u64,
}

trait CharacterTrait {
    fn new(character_type: CharacterType) -> Character;
}

impl CharacterImpl of CharacterTrait {
    fn new(character_type: CharacterType) -> Character {
        let character = match character_type {
            CharacterType::Archer => create_archer(character_type.into()),
            CharacterType::Cleric => create_cleric(character_type.into()),
            CharacterType::Warrior => create_warrior(character_type.into()),
            CharacterType::Goblin => create_goblin(character_type.into(), CharacterType::Goblin),
            CharacterType::Peasant => create_peasant(character_type.into()),
            CharacterType::Goblin2 => create_goblin(character_type.into(), CharacterType::Goblin2),
            CharacterType::Goblin3 => create_goblin(character_type.into(), CharacterType::Goblin3),
        };
        character
    }
}

fn create_archer(id: u32) -> Character {
    Character {
        character_id: id,
        character_type: CharacterType::Archer.into(),
        hp: 250,
        mp: 100,
        attack: 15,
        defense: 10,
        evasion: 15,
        crit_chance: 20,
        crit_rate: 2,
        movement_range: 6,
    }
}

fn create_cleric(id: u32) -> Character {
    Character {
        character_id: id,
        character_type: CharacterType::Cleric.into(),
        hp: 200,
        mp: 350,
        attack: 5,
        defense: 20,
        evasion: 15,
        crit_chance: 0,
        crit_rate: 0,
        movement_range: 4,
    }
}

fn create_warrior(id: u32) -> Character {
    Character {
        character_id: id,
        character_type: CharacterType::Warrior.into(),
        hp: 300,
        mp: 100,
        attack: 20,
        defense: 15,
        evasion: 5,
        crit_chance: 10,
        crit_rate: 2,
        movement_range: 5,
    }
}

fn create_goblin(id: u32, character_type: CharacterType) -> Character {
    Character {
        character_id: id,
        character_type: character_type.into(),
        hp: 150,
        mp: 0,
        attack: 25,
        defense: 10,
        evasion: 5,
        crit_chance: 15,
        crit_rate: 2,
        movement_range: 4,
    }
}

fn create_peasant(id: u32) -> Character {
    Character {
        character_id: id,
        character_type: CharacterType::Peasant.into(),
        hp: 300,
        mp: 100,
        attack: 20,
        defense: 15,
        evasion: 0,
        crit_chance: 0,
        crit_rate: 2,
        movement_range: 5,
    }
}

// Converters

impl CharacterTypeIntoU8 of Into<CharacterType, u8> {
    #[inline(always)]
    fn into(self: CharacterType) -> u8 {
        match self {
            CharacterType::Archer => 1,
            CharacterType::Cleric => 2,
            CharacterType::Warrior => 3,
            CharacterType::Goblin => 4,
            CharacterType::Peasant => 5,
            CharacterType::Goblin2 => 6,
            CharacterType::Goblin3 => 7,
        }
    }
}

impl CharacterTypeIntoU32 of Into<CharacterType, u32> {
    #[inline(always)]
    fn into(self: CharacterType) -> u32 {
        match self {
            CharacterType::Archer => 1,
            CharacterType::Cleric => 2,
            CharacterType::Warrior => 3,
            CharacterType::Goblin => 4,
            CharacterType::Peasant => 5,
            CharacterType::Goblin2 => 6,
            CharacterType::Goblin3 => 7,
        }
    }
}
