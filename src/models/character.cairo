#[derive(Serde, Copy, Drop, PartialEq)]
enum SkillType {
    MeeleAttack,
    RangeAttack,
    MagicAttack,
    Heal,
}

#[derive(Model, Copy, Drop, Serde)]
struct Skill {
    #[key]
    character_id: u32,
    #[key]
    key: u32,
    id: u32,
    skill_type: u8,
    power: u128,
    range: u128,
}

#[derive(Serde, Copy, Drop, PartialEq)]
enum CharacterType {
    Mage,
    Archer,
    Warrior,
    Orc,
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
    movement_range: u128,
}
