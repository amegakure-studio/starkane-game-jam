// Core imports
use debug::PrintTrait;

// Dojo imports
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

// Internal imports
use starkane::store::{Store, StoreTrait};
use starkane::systems::character_system::ICharacterSystemDispatcherTrait;
use starkane::systems::turn_system::ITurnSystemDispatcherTrait;
use starkane::systems::map_cc_system::IMapCCSystemDispatcherTrait;
use starkane::systems::skill_system::ISkillSystemDispatcherTrait;
use starkane::systems::match_system::{IMatchSystemDispatcherTrait, PlayerCharacter};
use starkane::systems::action_system::IActionSystemDispatcherTrait;
use starkane::systems::move_system::IMoveSystemDispatcherTrait;
use starkane::models::entities::character::{Character, CharacterType};
use starkane::models::entities::skill::{Skill, SkillType};
use starkane::models::data::starkane::{MatchCount, MATCH_COUNT_KEY};

use starkane::tests::setup::{setup, setup::Systems, setup::PLAYER};

// Constants
const ACCOUNT: felt252 = 'ACCOUNT';
const SEED: felt252 = 'SEED';
const NAME: felt252 = 'NAME';

// #[test]
// #[available_gas(1_000_000_000)]
// fn test_end_turn() {
//     // [Setup]
//     let (world, systems) = setup::spawn_game();
//     let mut store = StoreTrait::new(world);

//     let PLAYER_1 = '0x1';
//     let PLAYER_2 = '0x2';
//     let MATCH_ID = 0;

//     // [Create]
//     systems.character_system.init();
//     systems.skill_system.init();
//     systems.map_system.init();

//     // [Mint]
//     systems.character_system.mint(CharacterType::Warrior.into(), PLAYER_1, 1);
//     systems.character_system.mint(CharacterType::Warrior.into(), PLAYER_2, 1);

//     let player_characters = array![
//         PlayerCharacter { player: PLAYER_1, character_id: CharacterType::Warrior.into() },
//         PlayerCharacter { player: PLAYER_2, character_id: CharacterType::Warrior.into() },
//     ];

//     systems.match_system.init(player_characters);
//     let match_state = store.get_match_state(MATCH_ID);

//     // Actual turn is for player 1
//     assert(match_state.player_turn == PLAYER_1, 'turn should be player 0x1');
//     assert(match_state.turn == 0, 'turn should be number 0');
//     systems.turn_system.end_turn(MATCH_ID, PLAYER_1);

//     // End turn, so player 2 turn
//     let match_state = store.get_match_state(MATCH_ID);
//     assert(match_state.player_turn == PLAYER_2, 'turn should be player 0x2');
//     assert(match_state.turn == 1, 'turn should be number 1');
//     systems.turn_system.end_turn(MATCH_ID, PLAYER_2);

//     // It should be player 1 again
//     let match_state = store.get_match_state(MATCH_ID);
//     assert(match_state.turn == 2, 'turn should be number 2');
//     assert(match_state.player_turn == PLAYER_1, 'turn should be player 0x1');
// }

#[test]
#[available_gas(1_000_000_000)]
fn test_end_turn_2_turns_resets_actions() {
    // [Setup]
    let (world, systems) = setup::spawn_game();
    let mut store = StoreTrait::new(world);

    let PLAYER_1 = 1;
    let PLAYER_2 = 2;
    let MATCH_ID = 0;

    // [Create]
    systems.character_system.init();
    systems.skill_system.init();
    systems.map_system.init();

    // [Mint]
    systems.character_system.mint(CharacterType::Warrior.into(), PLAYER_1, 1);
    systems.character_system.mint(CharacterType::Goblin.into(), PLAYER_2, 1);

    let player_characters = array![
        PlayerCharacter { player: PLAYER_1, character_id: CharacterType::Warrior.into() },
        PlayerCharacter { player: PLAYER_2, character_id: CharacterType::Goblin.into() },
    ];

    systems.match_system.init(player_characters);
    let match_state = store.get_match_state(MATCH_ID);

    // initial position for first character is (5, 5)
    // move warrior player 1, then character position should be updated
    systems.move_system.move(MATCH_ID, PLAYER_1, CharacterType::Warrior.into(), (6, 6));
    let mut player_1_action_state = store
        .get_action_state(MATCH_ID, CharacterType::Warrior.into(), PLAYER_1);
    assert(player_1_action_state.movement, 'movement 1 should be true');
    systems.turn_system.end_turn(MATCH_ID, PLAYER_1);
    // check when turn ends that action its reset
    player_1_action_state = store
        .get_action_state(MATCH_ID, CharacterType::Warrior.into(), PLAYER_1);
    assert(!player_1_action_state.movement, 'movement 1 should be false');

    // initial position for first character is (5, 25)
    // End turn, so player 2 turn
    systems.move_system.move(MATCH_ID, PLAYER_2, CharacterType::Goblin.into(), (5, 24));
    let mut player_2_action_state = store
        .get_action_state(MATCH_ID, CharacterType::Goblin.into(), PLAYER_2);
    assert(player_2_action_state.movement, 'movement 2 should be true');
    systems.turn_system.end_turn(MATCH_ID, PLAYER_2);

    // check when turn ends that action its reset
    player_2_action_state = store
        .get_action_state(MATCH_ID, CharacterType::Goblin.into(), PLAYER_2);
    assert(!player_2_action_state.movement, 'movement 2 should be false');

    // move warrior player 1, then character position should be updated
    systems.move_system.move(MATCH_ID, PLAYER_1, CharacterType::Warrior.into(), (7, 8));
    player_1_action_state = store
        .get_action_state(MATCH_ID, CharacterType::Warrior.into(), PLAYER_1);
    assert(player_1_action_state.movement, 'movement should be true');
    systems.turn_system.end_turn(MATCH_ID, PLAYER_1);

    // check when turn ends that action its reset
    player_1_action_state = store
        .get_action_state(MATCH_ID, CharacterType::Warrior.into(), PLAYER_1);
    assert(!player_1_action_state.movement, 'movement should be false');

    // initial position for first character is (5, 25)
    // End turn, so player 2 turn
    systems.move_system.move(MATCH_ID, PLAYER_2, CharacterType::Goblin.into(), (6, 22));
    player_2_action_state = store
        .get_action_state(MATCH_ID, CharacterType::Goblin.into(), PLAYER_2);
    assert(player_2_action_state.movement, 'movement should be true');
    systems.turn_system.end_turn(MATCH_ID, PLAYER_2);

    // check when turn ends that action its reset
    player_2_action_state = store
        .get_action_state(MATCH_ID, CharacterType::Goblin.into(), PLAYER_2);
    assert(!player_2_action_state.movement, 'movement should be false');
}
