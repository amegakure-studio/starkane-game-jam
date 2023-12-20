// Core imports
use debug::PrintTrait;

// Dojo imports
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

// Internal imports
use starkane::store::{Store, StoreTrait};
use starkane::systems::character_system::ICharacterSystemDispatcherTrait;
use starkane::systems::map_system::IMapSystemDispatcherTrait;
use starkane::systems::skill_system::ISkillSystemDispatcherTrait;
use starkane::systems::match_system::{IMatchSystemDispatcherTrait, PlayerCharacter};
use starkane::systems::action_system::IActionSystemDispatcherTrait;
use starkane::models::entities::character::{Character, CharacterType};
use starkane::models::entities::skill::{Skill, SkillType};
use starkane::models::data::starkane::{MatchCount, MATCH_COUNT_KEY};

use starkane::tests::setup::{setup, setup::Systems, setup::PLAYER};

// Constants
const ACCOUNT: felt252 = 'ACCOUNT';
const SEED: felt252 = 'SEED';
const NAME: felt252 = 'NAME';

#[test]
#[available_gas(1_000_000_000)]
fn test_attack() {
    // [Setup]
    let (world, systems) = setup::spawn_game();
    let mut store = StoreTrait::new(world);

    let PLAYER_1 = '0x1';
    let PLAYER_2 = '0x2';

    // [Create]
    systems.character_system.init(world);
    systems.skill_system.init(world);
    systems.map_system.init(world);

    // [Mint]
    systems.character_system.mint(world, CharacterType::Warrior, PLAYER_1, 1);
    systems.character_system.mint(world, CharacterType::Warrior, PLAYER_2, 1);

    let player_characters = array![
        PlayerCharacter { player: PLAYER_1, character_id: CharacterType::Warrior.into() },
        PlayerCharacter { player: PLAYER_2, character_id: CharacterType::Warrior.into() },
    ];

    systems.match_system.init(world, player_characters);
    let MATCH_ID = 0;
    let match_state = store.get_match_state(MATCH_ID);

    let mut cs_player_1 = store
        .get_character_state(match_state.id, CharacterType::Warrior.into(), PLAYER_1);
    let mut cs_player_2 = store
        .get_character_state(match_state.id, CharacterType::Warrior.into(), PLAYER_2);

    cs_player_1.x = 1;
    cs_player_1.y = 1;

    cs_player_2.x = 2;
    cs_player_2.y = 1;

    store.set_character_state(cs_player_1);
    store.set_character_state(cs_player_2);

    // [Attack]
    systems
        .action_system
        .action(
            world,
            MATCH_ID,
            PLAYER_1,
            CharacterType::Warrior.into(),
            SkillType::MeeleAttack.into(),
            1,
            PLAYER_2,
            CharacterType::Warrior.into()
        );

    let mut cs_player_2_af = store
        .get_character_state(match_state.id, CharacterType::Warrior.into(), PLAYER_2);

    // 300 start hp minus 20 + 25 from warrior attack + skill power
    assert(cs_player_2_af.match_id == cs_player_2.match_id, 'wrong player 2 char match_id');
    assert(cs_player_2_af.character_id == cs_player_2.character_id, 'wrong player 2 character_id');
    assert(
        cs_player_2_af.remain_hp == cs_player_2.remain_hp - (20 + 25), 'wrong player 2 character hp'
    );
    assert(cs_player_2_af.remain_mp == cs_player_2.remain_mp, 'wrong player 2 character mp');
    assert(cs_player_2_af.x == cs_player_2.x, 'wrong player 2 character x');
    assert(cs_player_2_af.y == cs_player_2.y, 'wrong player 2 character y');
    assert(cs_player_2_af.player == cs_player_2.player, 'wrong player 2 character player');

    let mut cs_player_1_af = store
        .get_character_state(match_state.id, CharacterType::Warrior.into(), PLAYER_1);

    assert(cs_player_1_af.match_id == cs_player_1.match_id, 'wrong player 1 char match_id');
    assert(cs_player_1_af.character_id == cs_player_1.character_id, 'wrong player 1 character_id');
    assert(cs_player_1_af.remain_hp == cs_player_1.remain_hp, 'wrong player 1 character hp');
    assert(cs_player_1_af.remain_mp == cs_player_1.remain_mp, 'wrong player 1 character mp');
    assert(cs_player_1_af.x == cs_player_1.x, 'wrong player 1 character x');
    assert(cs_player_1_af.y == cs_player_1.y, 'wrong player 1 character y');
    assert(cs_player_1_af.player == cs_player_1.player, 'wrong player 1 character player');
}

#[test]
#[available_gas(1_000_000_000)]
#[should_panic(expected: ('already took action this turn', 'ENTRYPOINT_FAILED'))]
fn test_player_attack_twice_same_character_same_turn() {
    // [Setup]
    let (world, systems) = setup::spawn_game();
    let mut store = StoreTrait::new(world);

    let PLAYER_1 = '0x1';
    let PLAYER_2 = '0x2';

    // [Create]
    systems.character_system.init(world);
    systems.skill_system.init(world);
    systems.map_system.init(world);

    // [Mint]
    systems.character_system.mint(world, CharacterType::Warrior, PLAYER_1, 1);
    systems.character_system.mint(world, CharacterType::Warrior, PLAYER_2, 1);

    let player_characters = array![
        PlayerCharacter { player: PLAYER_1, character_id: CharacterType::Warrior.into() },
        PlayerCharacter { player: PLAYER_2, character_id: CharacterType::Warrior.into() },
    ];

    systems.match_system.init(world, player_characters);
    let MATCH_ID = 0;
    let match_state = store.get_match_state(MATCH_ID);

    let mut cs_player_1 = store
        .get_character_state(match_state.id, CharacterType::Warrior.into(), PLAYER_1);
    let mut cs_player_2 = store
        .get_character_state(match_state.id, CharacterType::Warrior.into(), PLAYER_2);

    cs_player_1.x = 1;
    cs_player_1.y = 1;

    cs_player_2.x = 2;
    cs_player_2.y = 1;

    store.set_character_state(cs_player_1);
    store.set_character_state(cs_player_2);

    // [Attack]
    systems
        .action_system
        .action(
            world,
            MATCH_ID,
            PLAYER_1,
            CharacterType::Warrior.into(),
            SkillType::MeeleAttack.into(),
            1,
            PLAYER_2,
            CharacterType::Warrior.into()
        );

    systems
        .action_system
        .action(
            world,
            MATCH_ID,
            PLAYER_1,
            CharacterType::Warrior.into(),
            SkillType::MeeleAttack.into(),
            1,
            PLAYER_2,
            CharacterType::Warrior.into()
        );
}

#[test]
#[available_gas(1_000_000_000)]
fn test_player_attack_twice_same_turn() {
    // [Setup]
    let (world, systems) = setup::spawn_game();
    let mut store = StoreTrait::new(world);

    let PLAYER_1 = '0x1';
    let PLAYER_2 = '0x2';

    // [Create]
    systems.character_system.init(world);
    systems.skill_system.init(world);
    systems.map_system.init(world);

    // [Mint]
    systems.character_system.mint(world, CharacterType::Warrior, PLAYER_1, 1);
    systems.character_system.mint(world, CharacterType::Archer, PLAYER_1, 1);
    systems.character_system.mint(world, CharacterType::Warrior, PLAYER_2, 1);
    systems.character_system.mint(world, CharacterType::Archer, PLAYER_2, 1);

    let player_characters = array![
        PlayerCharacter { player: PLAYER_1, character_id: CharacterType::Warrior.into() },
        PlayerCharacter { player: PLAYER_1, character_id: CharacterType::Archer.into() },
        PlayerCharacter { player: PLAYER_2, character_id: CharacterType::Warrior.into() },
        PlayerCharacter { player: PLAYER_2, character_id: CharacterType::Archer.into() },
    ];

    systems.match_system.init(world, player_characters);
    let MATCH_ID = 0;
    let match_state = store.get_match_state(MATCH_ID);

    let mut cs_player_1_warrior = store
        .get_character_state(match_state.id, CharacterType::Warrior.into(), PLAYER_1);
    let mut cs_player_1_archer = store
        .get_character_state(match_state.id, CharacterType::Archer.into(), PLAYER_1);
    let mut cs_player_2 = store
        .get_character_state(match_state.id, CharacterType::Warrior.into(), PLAYER_2);

    cs_player_1_warrior.x = 1;
    cs_player_1_warrior.y = 1;

    cs_player_1_archer.x = 1;
    cs_player_1_archer.y = 2;

    cs_player_2.x = 2;
    cs_player_2.y = 1;

    store.set_character_state(cs_player_1_warrior);
    store.set_character_state(cs_player_1_archer);
    store.set_character_state(cs_player_2);

    // [Attack]
    systems
        .action_system
        .action(
            world,
            MATCH_ID,
            PLAYER_1,
            CharacterType::Warrior.into(),
            SkillType::MeeleAttack.into(),
            1,
            PLAYER_2,
            CharacterType::Warrior.into()
        );

    systems
        .action_system
        .action(
            world,
            MATCH_ID,
            PLAYER_1,
            CharacterType::Archer.into(),
            SkillType::RangeAttack.into(),
            1,
            PLAYER_2,
            CharacterType::Warrior.into()
        );
}

#[test]
#[available_gas(1_000_000_000)]
#[should_panic(expected: ('wait for your turn', 'ENTRYPOINT_FAILED'))]
fn test_player_attack_when_isnt_their_turn() {
    // [Setup]
    let (world, systems) = setup::spawn_game();
    let mut store = StoreTrait::new(world);

    let PLAYER_1 = '0x1';
    let PLAYER_2 = '0x2';

    // [Create]
    systems.character_system.init(world);
    systems.skill_system.init(world);
    systems.map_system.init(world);

    // [Mint]
    systems.character_system.mint(world, CharacterType::Warrior, PLAYER_1, 1);
    systems.character_system.mint(world, CharacterType::Warrior, PLAYER_2, 1);

    let player_characters = array![
        PlayerCharacter { player: PLAYER_1, character_id: CharacterType::Warrior.into() },
        PlayerCharacter { player: PLAYER_2, character_id: CharacterType::Warrior.into() },
    ];

    systems.match_system.init(world, player_characters);
    let MATCH_ID = 0;
    let match_state = store.get_match_state(MATCH_ID);

    let mut cs_player_1 = store
        .get_character_state(match_state.id, CharacterType::Warrior.into(), PLAYER_1);
    let mut cs_player_2 = store
        .get_character_state(match_state.id, CharacterType::Warrior.into(), PLAYER_2);

    cs_player_1.x = 1;
    cs_player_1.y = 1;

    cs_player_2.x = 2;
    cs_player_2.y = 1;

    store.set_character_state(cs_player_1);
    store.set_character_state(cs_player_2);

    // [Attack]
    systems
        .action_system
        .action(
            world,
            MATCH_ID,
            PLAYER_2,
            CharacterType::Warrior.into(),
            SkillType::MeeleAttack.into(),
            1,
            PLAYER_1,
            CharacterType::Warrior.into()
        );
}


#[test]
#[available_gas(1_000_000_000)]
#[should_panic(expected: ('at least 2 players for a match', 'ENTRYPOINT_FAILED'))]
fn test_init_match_with_one_player() {
    // [Setup]
    let (world, systems) = setup::spawn_game();
    let mut store = StoreTrait::new(world);

    let PLAYER_1 = '0x1';
    let PLAYER_2 = '0x2';

    // [Create]
    systems.character_system.init(world);
    systems.skill_system.init(world);
    systems.map_system.init(world);

    // [Mint]
    systems.character_system.mint(world, CharacterType::Warrior, PLAYER_1, 1);

    let player_characters = array![
        PlayerCharacter { player: PLAYER_1, character_id: CharacterType::Warrior.into() },
    ];

    systems.match_system.init(world, player_characters);
}