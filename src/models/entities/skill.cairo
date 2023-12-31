use core::traits::Into;
#[derive(Serde, Copy, Drop, PartialEq)]
enum SkillType {
    MeeleAttack,
    RangeAttack,
    Fireball,
    Heal,
    SpecialMeeleAttack,
    SpecialRangeAttack,
}

#[derive(Model, Copy, Drop, Serde)]
struct Skill {
    #[key]
    id: u32,
    #[key]
    character_id: u32,
    #[key]
    level: u8,
    character_level_required: u8,
    skill_type: u8,
    power: u64,
    mp_cost: u64,
    range: u64,
    is_special: bool
}

trait SkillTrait {
    fn new(skill_type: SkillType, character_id: u32, level: u8) -> Skill;
}

impl SkillImpl of SkillTrait {
    fn new(skill_type: SkillType, character_id: u32, level: u8) -> Skill {
        match skill_type {
            SkillType::MeeleAttack => create_meele(character_id, skill_type.into(), level),
            SkillType::RangeAttack => create_range(character_id, skill_type.into(), level),
            SkillType::Fireball => create_fireball(character_id, skill_type.into(), level),
            SkillType::Heal => create_heal(character_id, skill_type.into(), level),
            SkillType::SpecialMeeleAttack => create_special_meele(
                character_id, skill_type.into(), level
            ),
            SkillType::SpecialRangeAttack => create_special_range(
                character_id, skill_type.into(), level
            ),
        }
    }
}

fn create_meele(character_id: u32, id: u32, level: u8) -> Skill {
    assert(level == 1, 'meele attack only has level 1');
    Skill {
        id: id,
        character_id: character_id,
        skill_type: SkillType::MeeleAttack.into(),
        level: 1,
        character_level_required: 1,
        power: 25,
        mp_cost: 0,
        range: 2,
        is_special: false
    }
}

fn create_range(character_id: u32, id: u32, level: u8) -> Skill {
    assert(level == 1, 'range attack only has level 1');
    Skill {
        id: id,
        character_id: character_id,
        skill_type: SkillType::RangeAttack.into(),
        level: 1,
        character_level_required: 1,
        power: 15,
        mp_cost: 0,
        range: 5,
        is_special: false
    }
}

fn create_fireball(character_id: u32, id: u32, level: u8) -> Skill {
    assert(level <= 3, 'fireball level > 3');
    let mut skill = Skill {
        id: id,
        character_id: character_id,
        skill_type: SkillType::Fireball.into(),
        level: 1,
        character_level_required: 1,
        power: 20,
        mp_cost: 40,
        range: 4,
        is_special: false
    };

    if level == 2 {
        skill =
            Skill {
                id: id,
                character_id: character_id,
                skill_type: SkillType::Fireball.into(),
                level: 2,
                character_level_required: 3,
                power: 40,
                mp_cost: 50,
                range: 4,
                is_special: false
            }
    }

    if level == 3 {
        skill =
            Skill {
                id: id,
                character_id: character_id,
                skill_type: SkillType::Fireball.into(),
                level: 3,
                character_level_required: 6,
                power: 60,
                mp_cost: 60,
                range: 5,
                is_special: false
            }
    }
    skill
}

fn create_heal(character_id: u32, id: u32, level: u8) -> Skill {
    assert(level <= 3, 'heal level > 3');
    let mut skill = Skill {
        id: id,
        character_id: character_id,
        skill_type: SkillType::Heal.into(),
        level: 1,
        character_level_required: 1,
        power: 40,
        mp_cost: 60,
        range: 3,
        is_special: false
    };

    if level == 2 {
        skill =
            Skill {
                id: id,
                character_id: character_id,
                skill_type: SkillType::Heal.into(),
                level: 2,
                character_level_required: 3,
                power: 80,
                mp_cost: 90,
                range: 4,
                is_special: false
            }
    }

    if level == 3 {
        skill =
            Skill {
                id: id,
                character_id: character_id,
                skill_type: SkillType::Heal.into(),
                level: 3,
                character_level_required: 6,
                power: 120,
                mp_cost: 100,
                range: 5,
                is_special: false
            }
    }
    skill
}

fn create_special_meele(character_id: u32, id: u32, level: u8) -> Skill {
    assert(level == 1, 'sp meele att only has level 1');
    Skill {
        id: id,
        character_id: character_id,
        skill_type: SkillType::MeeleAttack.into(),
        level: 1,
        character_level_required: 1,
        power: 30,
        mp_cost: 30,
        range: 2,
        is_special: true
    }
}

fn create_special_range(character_id: u32, id: u32, level: u8) -> Skill {
    assert(level == 1, 'sp range att only has level 1');
    Skill {
        id: id,
        character_id: character_id,
        skill_type: SkillType::RangeAttack.into(),
        level: 1,
        character_level_required: 1,
        power: 20,
        mp_cost: 30,
        range: 5,
        is_special: true
    }
}

impl SkillTypeIntoU8 of Into<SkillType, u8> {
    #[inline(always)]
    fn into(self: SkillType) -> u8 {
        match self {
            SkillType::MeeleAttack => 1,
            SkillType::RangeAttack => 2,
            SkillType::Fireball => 3,
            SkillType::Heal => 4,
            SkillType::SpecialMeeleAttack => 5,
            SkillType::SpecialRangeAttack => 6,
        }
    }
}

impl SkillTypeIntoU32 of Into<SkillType, u32> {
    #[inline(always)]
    fn into(self: SkillType) -> u32 {
        match self {
            SkillType::MeeleAttack => 1,
            SkillType::RangeAttack => 2,
            SkillType::Fireball => 3,
            SkillType::Heal => 4,
            SkillType::SpecialMeeleAttack => 5,
            SkillType::SpecialRangeAttack => 6,
        }
    }
}

impl U8TryIntoSkillType of TryInto<u8, SkillType> {
    #[inline(always)]
    fn try_into(self: u8) -> Option<SkillType> {
        if self == 1 {
            Option::Some(SkillType::MeeleAttack)
        } else if self == 2 {
            Option::Some(SkillType::RangeAttack)
        } else if self == 3 {
            Option::Some(SkillType::Fireball)
        } else if self == 4 {
            Option::Some(SkillType::Heal)
        } else if self == 5 {
            Option::Some(SkillType::SpecialMeeleAttack)
        } else if self == 6 {
            Option::Some(SkillType::SpecialRangeAttack)
        } else {
            Option::None(())
        }
    }
}
