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
use starkane::models::states::character_state::CharacterState;

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
    systems.character_system.init();
    systems.skill_system.init();
    systems.map_system.init();

    // [Mint]
    systems.character_system.mint(CharacterType::Peasant, PLAYER_1, 1);
    systems.character_system.mint(CharacterType::Peasant, PLAYER_2, 1);

    let player_characters = array![
        PlayerCharacter { player: PLAYER_1, character_id: CharacterType::Peasant.into() },
        PlayerCharacter { player: PLAYER_2, character_id: CharacterType::Peasant.into() },
    ];

    systems.match_system.init(player_characters);
    let MATCH_ID = 0;
    let match_state = store.get_match_state(MATCH_ID);

    let mut cs_player_1 = store
        .get_character_state(match_state.id, CharacterType::Peasant.into(), PLAYER_1);
    let mut cs_player_2 = store
        .get_character_state(match_state.id, CharacterType::Peasant.into(), PLAYER_2);

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
            MATCH_ID,
            PLAYER_1,
            CharacterType::Peasant.into(),
            SkillType::MeeleAttack.into(),
            1,
            PLAYER_2,
            CharacterType::Peasant.into()
        );

    let mut cs_player_2_af = store
        .get_character_state(match_state.id, CharacterType::Peasant.into(), PLAYER_2);

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
        .get_character_state(match_state.id, CharacterType::Peasant.into(), PLAYER_1);

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
    systems.character_system.init();
    systems.skill_system.init();
    systems.map_system.init();

    // [Mint]
    systems.character_system.mint(CharacterType::Peasant, PLAYER_1, 1);
    systems.character_system.mint(CharacterType::Peasant, PLAYER_2, 1);

    let player_characters = array![
        PlayerCharacter { player: PLAYER_1, character_id: CharacterType::Peasant.into() },
        PlayerCharacter { player: PLAYER_2, character_id: CharacterType::Peasant.into() },
    ];

    systems.match_system.init(player_characters);
    let MATCH_ID = 0;
    let match_state = store.get_match_state(MATCH_ID);

    let mut cs_player_1 = store
        .get_character_state(match_state.id, CharacterType::Peasant.into(), PLAYER_1);
    let mut cs_player_2 = store
        .get_character_state(match_state.id, CharacterType::Peasant.into(), PLAYER_2);

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
            MATCH_ID,
            PLAYER_1,
            CharacterType::Peasant.into(),
            SkillType::MeeleAttack.into(),
            1,
            PLAYER_2,
            CharacterType::Peasant.into()
        );

    systems
        .action_system
        .action(
            MATCH_ID,
            PLAYER_1,
            CharacterType::Peasant.into(),
            SkillType::MeeleAttack.into(),
            1,
            PLAYER_2,
            CharacterType::Peasant.into()
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
    systems.character_system.init();
    systems.skill_system.init();
    systems.map_system.init();

    // [Mint]
    systems.character_system.mint(CharacterType::Warrior, PLAYER_1, 1);
    systems.character_system.mint(CharacterType::Archer, PLAYER_1, 1);
    systems.character_system.mint(CharacterType::Warrior, PLAYER_2, 1);
    systems.character_system.mint(CharacterType::Archer, PLAYER_2, 1);

    let player_characters = array![
        PlayerCharacter { player: PLAYER_1, character_id: CharacterType::Warrior.into() },
        PlayerCharacter { player: PLAYER_1, character_id: CharacterType::Archer.into() },
        PlayerCharacter { player: PLAYER_2, character_id: CharacterType::Warrior.into() },
        PlayerCharacter { player: PLAYER_2, character_id: CharacterType::Archer.into() },
    ];

    systems.match_system.init(player_characters);
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
fn test_end_match_set_correct_winner() {
    // [Setup]
    let (world, systems) = setup::spawn_game();
    let mut store = StoreTrait::new(world);

    let PLAYER_1 = '0x1';
    let PLAYER_2 = '0x2';

    // [Create]
    systems.character_system.init();
    systems.skill_system.init();
    systems.map_system.init();

    // [Mint]
    systems.character_system.mint(CharacterType::Warrior, PLAYER_1, 1);
    systems.character_system.mint(CharacterType::Archer, PLAYER_1, 1);
    systems.character_system.mint(CharacterType::Warrior, PLAYER_2, 1);
    systems.character_system.mint(CharacterType::Archer, PLAYER_2, 1);

    let player_characters = array![
        PlayerCharacter { player: PLAYER_1, character_id: CharacterType::Warrior.into() },
        PlayerCharacter { player: PLAYER_1, character_id: CharacterType::Archer.into() },
        PlayerCharacter { player: PLAYER_2, character_id: CharacterType::Warrior.into() },
        PlayerCharacter { player: PLAYER_2, character_id: CharacterType::Archer.into() },
    ];

    systems.match_system.init(player_characters);
    let MATCH_ID = 0;
    let match_state = store.get_match_state(MATCH_ID);

    let mut cs_player_1_warrior = store
        .get_character_state(match_state.id, CharacterType::Warrior.into(), PLAYER_1);
    let mut cs_player_1_archer = store
        .get_character_state(match_state.id, CharacterType::Archer.into(), PLAYER_1);
    let mut cs_player_2_warrior = store
        .get_character_state(match_state.id, CharacterType::Warrior.into(), PLAYER_2);
    let mut cs_player_2_archer = store
        .get_character_state(match_state.id, CharacterType::Archer.into(), PLAYER_2);

    cs_player_1_warrior.x = 1;
    cs_player_1_warrior.y = 1;

    cs_player_1_archer.x = 2;
    cs_player_1_archer.y = 2;

    cs_player_2_warrior.x = 2;
    cs_player_2_warrior.y = 1;
    cs_player_2_warrior.remain_hp = 10;

    cs_player_2_archer.x = 1;
    cs_player_2_archer.y = 2;
    cs_player_2_archer.remain_hp = 10;

    store.set_character_state(cs_player_1_warrior);
    store.set_character_state(cs_player_1_archer);
    store.set_character_state(cs_player_2_warrior);
    store.set_character_state(cs_player_2_archer);

    // Check remainder characters for player 2
    let remain_characters_player_2 = store
        .get_match_player_characters_len(MATCH_ID, PLAYER_2)
        .remain_characters;
    assert(remain_characters_player_2 == 2, 'it should be remain 2 character');

    // [Attack]
    systems
        .action_system
        .action(
            MATCH_ID,
            PLAYER_1,
            CharacterType::Warrior.into(),
            SkillType::MeeleAttack.into(),
            1,
            PLAYER_2,
            CharacterType::Warrior.into()
        );

    // Player 2 warrior should be dead
    let cs_player_2_warrior = store
        .get_character_state(match_state.id, CharacterType::Warrior.into(), PLAYER_2);
    assert(cs_player_2_warrior.remain_hp.is_zero(), 'warrior should be dead');

    // Game shouldnt be over yet
    let match_state = store.get_match_state(MATCH_ID);
    assert(match_state.winner.is_zero(), 'winner should be 0 (not setted)');

    // Check remainder characters for player 2
    let remain_characters_player_2 = store
        .get_match_player_characters_len(MATCH_ID, PLAYER_2)
        .remain_characters;
    assert(remain_characters_player_2 == 1, 'it should be remain 1 character');

    // [Attack]
    systems
        .action_system
        .action(
            MATCH_ID,
            PLAYER_1,
            CharacterType::Archer.into(),
            SkillType::RangeAttack.into(),
            1,
            PLAYER_2,
            CharacterType::Archer.into()
        );

    // Player 2 warrior should be dead
    let cs_player_2_archer = store
        .get_character_state(match_state.id, CharacterType::Warrior.into(), PLAYER_2);
    assert(cs_player_2_archer.remain_hp.is_zero(), 'warrior should be dead');

    // Game shouldnt be over yet
    let match_state = store.get_match_state(MATCH_ID);
    assert(match_state.winner == PLAYER_1, 'winner should be 0x1');

    // Check remainder characters for player 2
    let remain_characters_player_2 = store
        .get_match_player_characters_len(MATCH_ID, PLAYER_2)
        .remain_characters;
    assert(remain_characters_player_2 == 0, 'it should be remain 0 character');

    // Check match stadistics update
    let player_1_stadistics = store.get_player_stadistics(PLAYER_1);
    assert(player_1_stadistics.matchs_lost == 0, 'wrong 0x1 match lost');
    assert(player_1_stadistics.matchs_won == 1, 'wrong 0x1 match won');

    // 
    let match_characters_player_1 = store.get_match_player_characters_states(MATCH_ID, PLAYER_1);
    let mut total_remain_hp = 0;
    let mut i = 0;
    loop {
        if match_characters_player_1.len() == i {
            break;
        }
        let character_state: CharacterState = *match_characters_player_1[i];
        total_remain_hp += character_state.remain_hp;
        i += 1;
    };
    assert(player_1_stadistics.total_score == 100 + total_remain_hp, 'wrong 0x1 wrong score');

    let player_2_stadistics = store.get_player_stadistics(PLAYER_2);
    assert(player_2_stadistics.matchs_lost == 1, 'wrong 0x2 match lost');
    assert(player_2_stadistics.matchs_won == 0, 'wrong 0x2 match won');
    assert(player_2_stadistics.total_score == 50, 'wrong 0x2 wrong score');
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
    systems.character_system.init();
    systems.skill_system.init();
    systems.map_system.init();

    // [Mint]
    systems.character_system.mint(CharacterType::Warrior, PLAYER_1, 1);
    systems.character_system.mint(CharacterType::Warrior, PLAYER_2, 1);

    let player_characters = array![
        PlayerCharacter { player: PLAYER_1, character_id: CharacterType::Warrior.into() },
        PlayerCharacter { player: PLAYER_2, character_id: CharacterType::Warrior.into() },
    ];

    systems.match_system.init(player_characters);
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
    systems.character_system.init();
    systems.skill_system.init();
    systems.map_system.init();

    // [Mint]
    systems.character_system.mint(CharacterType::Warrior, PLAYER_1, 1);

    let player_characters = array![
        PlayerCharacter { player: PLAYER_1, character_id: CharacterType::Warrior.into() },
    ];

    systems.match_system.init(player_characters);
}
