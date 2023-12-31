// Core imports
use debug::PrintTrait;

// Dojo imports
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

// Internal imports
use starkane::store::{Store, StoreTrait};
use starkane::models::entities::character::{Character, CharacterType};
use starkane::models::entities::skill::{Skill, SkillType};
use starkane::systems::skill_system::ISkillSystemDispatcherTrait;

use starkane::tests::setup::{setup, setup::Systems, setup::PLAYER};

// Constants
const ACCOUNT: felt252 = 'ACCOUNT';
const SEED: felt252 = 'SEED';
const NAME: felt252 = 'NAME';

#[test]
#[available_gas(1_000_000_000)]
fn test_initialize_skills() {
    // [Setup]
    let (world, systems) = setup::spawn_game();
    let mut store = StoreTrait::new(world);

    // [Create]
    systems.skill_system.init();

    // [Assert] MeeleAttack
    let meele_warrior = store
        .get_skill(SkillType::MeeleAttack.into(), CharacterType::Warrior.into(), 1);
    assert(meele_warrior.character_id == 3, 'meele warrior wrong char_id');
    assert(meele_warrior.skill_type == 1, 'meele warrior wrong skill_type');
    assert(meele_warrior.level == 1, 'meele warrior wrong level');
    assert(meele_warrior.power == 25, 'meele warrior wrong power');
    assert(meele_warrior.mp_cost == 0, 'meele warrior wrong mp_cost');
    assert(meele_warrior.range == 2, 'meele warrior wrong range');

    let meele_cleric = store
        .get_skill(SkillType::MeeleAttack.into(), CharacterType::Cleric.into(), 1);
    assert(meele_cleric.character_id == 2, 'meele cleric wrong char_id');
    assert(meele_cleric.skill_type == 1, 'meele cleric wrong skill_type');
    assert(meele_cleric.level == 1, 'meele cleric wrong level');
    assert(meele_cleric.power == 25, 'meele cleric wrong power');
    assert(meele_cleric.mp_cost == 0, 'meele cleric wrong mp_cost');
    assert(meele_cleric.range == 2, 'meele cleric wrong range');

    let meele_goblin = store
        .get_skill(SkillType::MeeleAttack.into(), CharacterType::Goblin.into(), 1);
    assert(meele_goblin.character_id == 4, 'meele goblin wrong char_id');
    assert(meele_goblin.skill_type == 1, 'meele goblin wrong skill_type');
    assert(meele_goblin.level == 1, 'meele goblin wrong level');
    assert(meele_goblin.power == 25, 'meele goblin wrong power');
    assert(meele_goblin.mp_cost == 0, 'meele goblin wrong mp_cost');
    assert(meele_goblin.range == 2, 'meele goblin wrong range');

    // [Assert] RangeAttack
    let range_archer = store
        .get_skill(SkillType::RangeAttack.into(), CharacterType::Archer.into(), 1);
    assert(range_archer.character_id == 1, 'range archer wrong char_id');
    assert(range_archer.skill_type == 2, 'range archer wrong skill_type');
    assert(range_archer.level == 1, 'range archer wrong level');
    assert(range_archer.character_level_required == 1, 'range archer wrong level');
    assert(range_archer.power == 15, 'range archer wrong power');
    assert(range_archer.mp_cost == 0, 'range archer wrong mp_cost');
    assert(range_archer.range == 5, 'range archer wrong range');

    // [Assert] Heal 1
    let cleric_heal = store.get_skill(SkillType::Heal.into(), CharacterType::Cleric.into(), 1);
    assert(cleric_heal.character_id == 2, 'cleric heal wrong char_id');
    assert(cleric_heal.skill_type == 4, 'cleric heal wrong skill_type');
    assert(cleric_heal.level == 1, 'cleric heal 1 wrong level');
    assert(cleric_heal.character_level_required == 1, 'cleric heal wrong level');
    assert(cleric_heal.power == 40, 'cleric heal wrong power');
    assert(cleric_heal.mp_cost == 60, 'cleric heal wrong mp_cost');
    assert(cleric_heal.range == 3, 'cleric heal wrong range');
// // [Assert] Heal 2
// let cleric_heal = store.get_skill(SkillType::Heal.into(), CharacterType::Cleric.into(), 2);
// assert(cleric_heal.character_id == 2, 'cleric heal wrong char_id');
// assert(cleric_heal.skill_type == 4, 'cleric heal wrong skill_type');
// assert(cleric_heal.level == 2, 'cleric heal 3 wrong level');
// assert(cleric_heal.character_level_required == 3, 'cleric heal wrong level');
// assert(cleric_heal.power == 80, 'cleric heal wrong power');
// assert(cleric_heal.mp_cost == 90, 'cleric heal wrong mp_cost');
// assert(cleric_heal.range == 4, 'cleric heal wrong range');

// // [Assert] Heal 3
// let cleric_heal = store.get_skill(SkillType::Heal.into(), CharacterType::Cleric.into(), 3);
// assert(cleric_heal.character_id == 2, 'cleric heal wrong char_id');
// assert(cleric_heal.skill_type == 4, 'cleric heal wrong skill_type');
// assert(cleric_heal.level == 3, 'cleric heal 3 wrong level');
// assert(cleric_heal.character_level_required == 6, 'cleric heal wrong level');
// assert(cleric_heal.power == 120, 'cleric heal wrong power');
// assert(cleric_heal.mp_cost == 100, 'cleric heal wrong mp_cost');
// assert(cleric_heal.range == 5, 'cleric heal wrong range');
}
