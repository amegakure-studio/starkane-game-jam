#[derive(Serde, Copy, Drop, PartialEq)]
enum CharacterType {
    Archer,
    Cleric,
    Warrior,
    Pig,
}

impl CharacterTypeIntoU8 of Into<CharacterType, u8> {
    #[inline(always)]
    fn into(self: CharacterType) -> u8 {
        match self {
            CharacterType::Archer => 0,
            CharacterType::Cleric => 1,
            CharacterType::Warrior => 2,
            CharacterType::Pig => 3,
        }
    }
}

#[derive(Model, Copy, Drop, Serde)]
struct Character {
    #[key]
    key: u32,
    id: u32,
    character_type: u8,
    hp: u128,
    mp: u128,
    attack: u128,
    defense: u128,
    evasion: u128,
    crit_chance: u128,
    crit_rate: u128,
    movement_range: u128,
}

trait CharacterTrait {
    fn new(key: u32, id: u32, seed: felt252, character_type: CharacterType) -> Character;
}

impl CharacterImpl of CharacterTrait {
    fn new(key: u32, id: u32, seed: felt252, character_type: CharacterType) -> Character {
        match character_type {
            CharacterType::Archer => create_archer(key, id),
            CharacterType::Cleric => create_cleric(key, id),
            CharacterType::Warrior => create_warrior(key, id),
            CharacterType::Pig => create_pig(key, id),
        }
    }
}

fn create_archer(key: u32, id: u32) -> Character {
    Character {
        key: key,
        id: id,
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

fn create_cleric(key: u32, id: u32) -> Character {
    Character {
        key: key,
        id: id,
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

fn create_warrior(key: u32, id: u32) -> Character {
    Character {
        key: key,
        id: id,
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

fn create_pig(key: u32, id: u32) -> Character {
    Character {
        key: key,
        id: id,
        character_type: CharacterType::Pig.into(),
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
