// Core imports
use debug::PrintTrait;

// Dojo imports
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

// Internal imports
use starkane::store::{Store, StoreTrait};
use starkane::systems::character_system::ICharacterSystemDispatcherTrait;
use starkane::systems::turn_system::ITurnSystemDispatcherTrait;
use starkane::systems::map_system::IMapSystemDispatcherTrait;
use starkane::systems::skill_system::ISkillSystemDispatcherTrait;
use starkane::systems::match_system::{IMatchSystemDispatcherTrait, PlayerCharacter};
use starkane::systems::move_system::IMoveSystemDispatcherTrait;

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
fn test_move_update_character_position() {
    // [Setup]
    let (world, systems) = setup::spawn_game();
    let mut store = StoreTrait::new(world);

    let PLAYER_1 = '0x1';
    let PLAYER_2 = '0x2';
    let MATCH_ID = 0;

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

    systems.match_system.init(store.world, player_characters);
    let match_state = store.get_match_state(MATCH_ID);

    // initial position for first character is (5, 5)
    // move warrior player 1, then character position should be updated
    systems
        .move_system
        .move(store.world, MATCH_ID, PLAYER_1, CharacterType::Warrior.into(), (6, 6));
    let player_1_character_state = store
        .get_character_state(MATCH_ID, CharacterType::Warrior.into(), PLAYER_1);

    assert(player_1_character_state.x == 6, 'wrong x position');
    assert(player_1_character_state.y == 6, 'wrong y position');
}

#[test]
#[available_gas(1_000_000_000)]
#[should_panic(expected: ('already move in this turn', 'ENTRYPOINT_FAILED'))]
fn test_fail_when_move_twice_same_character_same_turn() {
    // [Setup]
    let (world, systems) = setup::spawn_game();
    let mut store = StoreTrait::new(world);

    let PLAYER_1 = '0x1';
    let PLAYER_2 = '0x2';
    let MATCH_ID = 0;

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

    systems.match_system.init(store.world, player_characters);
    let match_state = store.get_match_state(MATCH_ID);

    // initial position for first character is (5, 5)
    systems
        .move_system
        .move(store.world, MATCH_ID, PLAYER_1, CharacterType::Warrior.into(), (6, 6));
    systems
        .move_system
        .move(store.world, MATCH_ID, PLAYER_1, CharacterType::Warrior.into(), (7, 7));
}

#[test]
#[available_gas(1_000_000_000)]
#[should_panic(expected: ('wait for your turn', 'ENTRYPOINT_FAILED'))]
fn test_fail_when_isnt_your_turn() {
    // [Setup]
    let (world, systems) = setup::spawn_game();
    let mut store = StoreTrait::new(world);

    let PLAYER_1 = '0x1';
    let PLAYER_2 = '0x2';
    let MATCH_ID = 0;

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

    systems.match_system.init(store.world, player_characters);
    let match_state = store.get_match_state(MATCH_ID);

    // initial position for second player is (5, 25)
    systems
        .move_system
        .move(store.world, MATCH_ID, PLAYER_2, CharacterType::Warrior.into(), (6, 24));
}

#[test]
#[available_gas(1_000_000_000)]
#[should_panic(expected: ('character cannot move that far', 'ENTRYPOINT_FAILED'))]
fn test_fail_when_move_target_is_gt_character_movement() {
    // [Setup]
    let (world, systems) = setup::spawn_game();
    let mut store = StoreTrait::new(world);

    let PLAYER_1 = '0x1';
    let PLAYER_2 = '0x2';
    let MATCH_ID = 0;

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

    systems.match_system.init(store.world, player_characters);
    let match_state = store.get_match_state(MATCH_ID);

    // initial position for first character is (5, 5)
    // warrior has 5 movement so, if we move to x: 11 (6 tiles) then should fail
    systems
        .move_system
        .move(store.world, MATCH_ID, PLAYER_1, CharacterType::Warrior.into(), (11, 5));

    let player_1_character_state = store
        .get_character_state(MATCH_ID, CharacterType::Warrior.into(), PLAYER_1);
    player_1_character_state.x.print();
    player_1_character_state.y.print();
}
