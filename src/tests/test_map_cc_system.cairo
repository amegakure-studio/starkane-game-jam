use core::traits::Into;
// Core imports
use debug::PrintTrait;

// Dojo imports
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

// Internal imports
use starkane::store::{Store, StoreTrait};
use starkane::models::entities::map_cc::{MapCC, MapCCTrait};
use starkane::systems::map_cc_system::IMapCCSystemDispatcherTrait;

use starkane::tests::setup::{setup, setup::Systems, setup::PLAYER};

// Constants
const ACCOUNT: felt252 = 'ACCOUNT';
const SEED: felt252 = 'SEED';
const NAME: felt252 = 'NAME';

#[test]
#[available_gas(1_000_000_000_000_000)]
fn test_initialize_map() {
    // [Setup]
    let (world, systems) = setup::spawn_game();
    let mut store = StoreTrait::new(world);

    // [Create]
    systems.map_system.init();

    let map_id = 1;
    let map = store.get_map_cc(map_id);
    assert(map.id == map_id, 'map wrong id');
    assert(map.width == 25, 'map wrong width');
    assert(map.height == 25, 'map wrong height');

    let mut y: u64 = 0;
    loop {
        if y == 25 {
            break;
        }
        let row = format!(
            "{} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {} {}",
            map.get_value((y, 0)),
            map.get_value((y, 1)),
            map.get_value((y, 2)),
            map.get_value((y, 3)),
            map.get_value((y, 4)),
            map.get_value((y, 5)),
            map.get_value((y, 6)),
            map.get_value((y, 7)),
            map.get_value((y, 8)),
            map.get_value((y, 9)),
            map.get_value((y, 10)),
            map.get_value((y, 11)),
            map.get_value((y, 12)),
            map.get_value((y, 13)),
            map.get_value((y, 14)),
            map.get_value((y, 15)),
            map.get_value((y, 16)),
            map.get_value((y, 17)),
            map.get_value((y, 18)),
            map.get_value((y, 19)),
            map.get_value((y, 20)),
            map.get_value((y, 21)),
            map.get_value((y, 22)),
            map.get_value((y, 23)),
            map.get_value((y, 24)),
        );
        println!("{}", row);
        y += 1;
    };
}
