use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

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
            CharacterType::Archer => 1,
            CharacterType::Cleric => 2,
            CharacterType::Warrior => 3,
            CharacterType::Pig => 4,
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
            CharacterType::Pig => 4,
        }
    }
}

#[derive(Model, Copy, Drop, Serde)]
struct CharacterOwned {
    #[key]
    owner: felt252,
    #[key]
    character_id: u32,
    owned: bool,
}

#[derive(Model, Copy, Drop, Serde)]
struct Character {
    #[key]
    character_id: u32,
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
    fn new(character_type: CharacterType) -> Character;
}

impl CharacterImpl of CharacterTrait {
    fn new(character_type: CharacterType) -> Character {
        let character = match character_type {
            CharacterType::Archer => create_archer(character_type.into()),
            CharacterType::Cleric => create_cleric(character_type.into()),
            CharacterType::Warrior => create_warrior(character_type.into()),
            CharacterType::Pig => create_pig(character_type.into()),
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

fn create_pig(id: u32) -> Character {
    Character {
        character_id: id,
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
