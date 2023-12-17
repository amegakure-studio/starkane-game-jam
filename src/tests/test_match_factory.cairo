// Core imports

use debug::PrintTrait;

// Dojo imports

use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

// Internal imports

use starkane::store::{Store, StoreTrait};
use starkane::systems::match_factory::{IActionsDispatcherTrait, PlayerCharacter};
use starkane::models::entities::character::{Character, CharacterType};

use starkane::tests::setup::{setup, setup::Systems, setup::PLAYER};

// Constants

const ACCOUNT: felt252 = 'ACCOUNT';
const SEED: felt252 = 'SEED';
const NAME: felt252 = 'NAME';

#[test]
#[available_gas(1_000_000_000)]
fn test_create() {
    // [Setup]
    let (world, systems) = setup::spawn_game();
    let mut store = StoreTrait::new(world);

    // // [Create]
    let mut players_characters = array![];
    let player_character = PlayerCharacter {
        player: ACCOUNT,
        character: Character {
            character_id: 1,
            character_type: CharacterType::Archer.into(),
            hp: 250,
            mp: 100,
            attack: 15,
            defense: 10,
            evasion: 15,
            crit_chance: 20,
            crit_rate: 2,
            movement_range: 6,
        }
    };
    players_characters.append(player_character);
    systems.player_actions.create(world, players_characters);

    // // [Assert] Game
    // let game: Game = store.game(ACCOUNT);
    // assert(game.id == 0, 'Game: wrong id');
    // assert(game.seed == SEED, 'Game: wrong seed');
    // assert(game.over == false, 'Game: wrong status');
    // assert(game.gold == GAME_INITIAL_GOLD, 'Game: wrong gold');
}