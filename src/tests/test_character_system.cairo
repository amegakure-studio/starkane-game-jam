// Core imports
use debug::PrintTrait;

// Dojo imports
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

// Internal imports
use starkane::store::{Store, StoreTrait};
use starkane::systems::character_system::ICharacterSystemDispatcherTrait;
use starkane::models::entities::character::{Character, CharacterType};

use starkane::tests::setup::{setup, setup::Systems, setup::PLAYER};

// Constants
const ACCOUNT: felt252 = 'ACCOUNT';
const SEED: felt252 = 'SEED';
const NAME: felt252 = 'NAME';

#[test]
#[available_gas(1_000_000_000)]
fn test_initialize_characters() {
    // [Setup]
    let (world, systems) = setup::spawn_game();
    let mut store = StoreTrait::new(world);

    // [Create]
    systems.character_system.init();

    // [Assert] Archer
    let archer = store.get_character(1);
    assert(archer.character_type == 1, 'archer wrong id');
    assert(archer.hp == 250, 'archer wrong initial hp');
    assert(archer.mp == 100, 'archer wrong initial mp');
    assert(archer.attack == 15, 'archer wrong initial attack');
    assert(archer.defense == 10, 'archer wrong initial defense');
    assert(archer.evasion == 15, 'archer wrong initial evasion');
    assert(archer.crit_chance == 20, 'archer wrong crit_chance');
    assert(archer.crit_rate == 2, 'archer wrong initial crit_rate');
    assert(archer.movement_range == 6, 'archer wrong initial movement');

    // [Assert] Cleric
    let cleric = store.get_character(2);
    assert(cleric.character_type == 2, 'cleric wrong id');
    assert(cleric.hp == 200, 'cleric wrong initial hp');
    assert(cleric.mp == 350, 'cleric wrong initial mp');
    assert(cleric.attack == 5, 'cleric wrong initial attack');
    assert(cleric.defense == 20, 'cleric wrong initial defense');
    assert(cleric.evasion == 15, 'cleric wrong initial evasion');
    assert(cleric.crit_chance == 0, 'cleric wrong crit_chance');
    assert(cleric.crit_rate == 0, 'cleric wrong initial crit_rate');
    assert(cleric.movement_range == 4, 'cleric wrong initial movement');

    // [Assert] Warrior
    let warrior = store.get_character(3);
    assert(warrior.character_type == 3, 'warrior wrong id');
    assert(warrior.hp == 300, 'warrior wrong initial hp');
    assert(warrior.mp == 100, 'warrior wrong initial mp');
    assert(warrior.attack == 20, 'warrior wrong initial attack');
    assert(warrior.defense == 15, 'warrior wrong initial defense');
    assert(warrior.evasion == 5, 'warrior wrong initial evasion');
    assert(warrior.crit_chance == 10, 'warrior wrong crit_chance');
    assert(warrior.crit_rate == 2, 'warrior wrong initial crit_rate');
    assert(warrior.movement_range == 5, 'warrior wrong initial movement');

    // [Assert] Pig
    let pig = store.get_character(4);
    assert(pig.character_type == 4, 'pig wrong id');
    assert(pig.hp == 150, 'pig wrong initial hp');
    assert(pig.mp == 0, 'pig wrong initial mp');
    assert(pig.attack == 25, 'pig wrong initial attack');
    assert(pig.defense == 10, 'pig wrong initial defense');
    assert(pig.evasion == 5, 'pig wrong initial evasion');
    assert(pig.crit_chance == 15, 'pig wrong crit_chance');
    assert(pig.crit_rate == 2, 'pig wrong initial crit_rate');
    assert(pig.movement_range == 4, 'pig wrong initial movement');

    // [Assert] Peasent
    let peasent = store.get_character(5);
    assert(peasent.character_type == 5, 'peasent wrong id');
    assert(peasent.hp == 300, 'peasent wrong initial hp');
    assert(peasent.mp == 100, 'peasent wrong initial mp');
    assert(peasent.attack == 20, 'peasent wrong initial attack');
    assert(peasent.defense == 15, 'peasent wrong initial defense');
    assert(peasent.evasion == 0, 'peasent wrong initial evasion');
    assert(peasent.crit_chance == 0, 'peasent wrong crit_chance');
    assert(peasent.crit_rate == 2, 'peasent wrong initial crit_rate');
    assert(peasent.movement_range == 5, 'peasent wrong initial movement');
}

#[test]
#[available_gas(1_000_000_000)]
fn test_mint_character() {
    // [Setup]
    let (world, systems) = setup::spawn_game();
    let mut store = StoreTrait::new(world);
    let PLAYER_1 = '0x1';

    // [Create]
    systems.character_system.init();

    // [Create]
    systems.character_system.init();

    // [Mint]
    systems.character_system.mint(CharacterType::Warrior.into(), PLAYER_1, 1);
    systems.character_system.mint(CharacterType::Archer.into(), PLAYER_1, 1);

    let player_stadistics = store.get_player_stadistics(PLAYER_1);
    let archer = store.get_character(1); // ARCHER
    let warrior = store.get_character(3); // WARRIOR

    assert(warrior.hp == 300, 'wrong hp');
    assert(warrior.mp == 100, 'wrong mp');
    assert(archer.hp == 250, 'wrong hp');
    assert(archer.mp == 100, 'wrong mp');
    assert(player_stadistics.characters_owned == 2, 'wrong characters owned number');
}

#[test]
#[available_gas(1_000_000_000)]
#[should_panic(expected: ('ERR: character already owned', 'ENTRYPOINT_FAILED'))]
fn test_mint_same_character_twice() {
    // [Setup]
    let (world, systems) = setup::spawn_game();
    let mut store = StoreTrait::new(world);

    // [Create]
    systems.character_system.init();

    // [Mint] Warrior
    let PLAYER_1 = '0x1';

    // [Create]
    systems.character_system.init();

    // [Mint]
    systems.character_system.mint(CharacterType::Warrior.into(), PLAYER_1, 1);
    systems.character_system.mint(CharacterType::Warrior.into(), PLAYER_1, 1);
}

