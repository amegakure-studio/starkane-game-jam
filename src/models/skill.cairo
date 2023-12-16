use core::traits::Into;
#[derive(Serde, Copy, Drop, PartialEq)]
enum SkillType {
    MeeleAttack,
    RangeAttack,
    Fireball,
    Heal,
}

impl SkillTypeIntoU8 of Into<SkillType, u8> {
    #[inline(always)]
    fn into(self: SkillType) -> u8 {
        match self {
            SkillType::MeeleAttack => 0,
            SkillType::RangeAttack => 1,
            SkillType::Fireball => 2,
            SkillType::Heal => 3,
        }
    }
}

impl U8TryIntoSkillType of TryInto<u8, SkillType > {
    #[inline(always)]
    fn try_into(self: u8) -> Option<SkillType> {
        if self == 0 {
            Option::Some(SkillType::MeeleAttack)
        } else if self == 1 {
            Option::Some(SkillType::RangeAttack)
        } else if self == 2 {
            Option::Some(SkillType::Fireball)
        } else if self == 3 {
            Option::Some(SkillType::Heal)
        } else {
            Option::None(())
        }
    }
}

#[derive(Model, Copy, Drop, Serde)]
struct Skill {
    #[key]
    character_id: u32,
    #[key]
    id: u32,
    skill_type: u8,
    level: u8,
    power: u128,
    mp_cost: u128,
    range: u128,
}

trait SkillTrait {
    fn new(key: u32, character_id: u32, id: u32, skill_type: SkillType, level: u8) -> Skill;
}

impl SkillImpl of SkillTrait {
    fn new(key: u32, character_id: u32, id: u32, skill_type: SkillType, level: u8) -> Skill {
        match skill_type {
            SkillType::MeeleAttack => create_meele(key, character_id, id, level),
            SkillType::RangeAttack => create_range(key, character_id, id, level),
            SkillType::Fireball => create_fireball(key, character_id, id, level),
            SkillType::Heal => create_heal(key, character_id, id, level),
        }
    }
}

fn create_meele(key: u32, character_id: u32, id: u32, level: u8) -> Skill {
    assert(level != 1, 'meele attack only has level 1');
    Skill {
        character_id: character_id,
        id: id,
        skill_type: SkillType::MeeleAttack.into(),
        level: 1,
        power: 25,
        mp_cost: 0,
        range: 2
    }
}

fn create_range(key: u32, character_id: u32, id: u32, level: u8) -> Skill {
    assert(level != 1, 'range attack only has level 1');
    Skill {
        character_id: character_id,
        id: id,
        skill_type: SkillType::RangeAttack.into(),
        level: 1,
        power: 15,
        mp_cost: 0,
        range: 5
    }
}

fn create_fireball(key: u32, character_id: u32, id: u32, level: u8) -> Skill {
    assert(level == 0 || level > 3, 'fireball level > 3');
    let mut skill = 
        Skill {
            character_id: character_id,
            id: id,
            skill_type: SkillType::Fireball.into(),
            level: 1,
            power: 20,
            mp_cost: 40,
            range: 4
        };

    if level == 2 {
        skill = Skill {
            character_id: character_id,
            id: id, 
            skill_type: SkillType::Fireball.into(),
            level: 2,
            power: 40,
            mp_cost: 50,
            range: 4
        }
    } 

    if level == 3 {
        skill = Skill {
            character_id: character_id,
            id: id,
            skill_type: SkillType::Fireball.into(),
            level: 3,
            power: 60,
            mp_cost: 60,
            range: 5
        }
    }
    skill
}

fn create_heal(key: u32, character_id: u32, id: u32, level: u8) -> Skill {
    assert(level == 0 || level > 3, 'heal level > 3');
    let mut skill = 
        Skill {
            character_id: character_id,
            id: id,
            skill_type: SkillType::Heal.into(),
            level: 1,
            power: 40,
            mp_cost: 60,
            range: 3
        };

    if level == 2 {
        skill = Skill {
            character_id: character_id,
            id: id,
            skill_type: SkillType::Heal.into(),
            level: 2,
            power: 80,
            mp_cost: 90,
            range: 4
        }
    } 

    if level == 3 {
        skill = Skill {
            character_id: character_id,
            id: id,
            skill_type: SkillType::Heal.into(),
            level: 3,
            power: 120,
            mp_cost: 110,
            range: 5
        }
    }
    skill
}