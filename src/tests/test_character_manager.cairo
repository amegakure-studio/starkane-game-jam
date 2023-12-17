// Core imports

use debug::PrintTrait;

// Dojo imports

use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

// Internal imports

use starkane::store::{Store, StoreTrait};
use starkane::systems::character_manager::IActionsDispatcherTrait;
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
    systems.player_actions.initialize(world);

    // // [Assert] Game
    let archer = store.get_character(1);
    assert(archer.hp == 250, 'error');
    // assert(game.seed == SEED, 'Game: wrong seed');
    // assert(game.over == false, 'Game: wrong status');
    // assert(game.gold == GAME_INITIAL_GOLD, 'Game: wrong gold');
}