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
use starkane::models::data::starkane::{MatchIndex, MATCH_IDX_KEY};


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

    // [Create]
    systems.character_system.init(world);
    systems.skill_system.init(world);
    systems.map_system.init(world);

    // [Mint]
    systems.character_system.mint(world, CharacterType::Warrior, '0x1', 1);
    systems.character_system.mint(world, CharacterType::Warrior, '0x2', 1);

    let player_characters = array![
        PlayerCharacter { player: '0x1', character_id: CharacterType::Warrior.into() },
        PlayerCharacter { player: '0x2', character_id: CharacterType::Warrior.into() },
    ];

    systems.match_system.init(world, player_characters);
    let match_idx = store.get_match_index(MATCH_IDX_KEY);
    let match_state = store.get_match_state(match_idx.index);

    let mut cs_player_1 = store
        .get_character_state(match_state, CharacterType::Warrior.into(), '0x1');
    let mut cs_player_2 = store
        .get_character_state(match_state, CharacterType::Warrior.into(), '0x2');

    cs_player_1.x = 1;
    cs_player_1.y = 1;

    cs_player_2.x = 2;
    cs_player_2.y = 1;

    store.set_character_state(cs_player_1);
    store.set_character_state(cs_player_2);

    // [Attack]
    // match_id: u32,
    // player: felt252,
    // player_character_id: u32,
    // skill_id: u32,
    // level: u32,
    // receiver: felt252,
    // receiver_character_id: u32
    systems
        .action_system
        .action(
            world,
            match_idx.index,
            '0x1',
            CharacterType::Warrior.into(),
            SkillType::MeeleAttack.into(),
            1,
            '0x2',
            CharacterType::Warrior.into()
        );
}
