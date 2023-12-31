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
            map.get_value((0, y)),
            map.get_value((1, y)),
            map.get_value((2, y)),
            map.get_value((3, y)),
            map.get_value((4, y)),
            map.get_value((5, y)),
            map.get_value((6, y)),
            map.get_value((7, y)),
            map.get_value((8, y)),
            map.get_value((9, y)),
            map.get_value((10, y)),
            map.get_value((11, y)),
            map.get_value((12, y)),
            map.get_value((13, y)),
            map.get_value((14, y)),
            map.get_value((15, y)),
            map.get_value((16, y)),
            map.get_value((17, y)),
            map.get_value((18, y)),
            map.get_value((19, y)),
            map.get_value((20, y)),
            map.get_value((21, y)),
            map.get_value((22, y)),
            map.get_value((23, y)),
            map.get_value((24, y)),
        );
        println!("{}", row);
        y += 1;
    };
}
