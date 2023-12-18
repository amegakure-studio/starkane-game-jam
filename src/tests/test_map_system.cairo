use core::traits::Into;
// Core imports
use debug::PrintTrait;

// Dojo imports
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

// Internal imports
use starkane::store::{Store, StoreTrait};
use starkane::models::entities::map::{Map, Tile, TerrainType};
use starkane::systems::map_system::IMapSystemDispatcherTrait;

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
    systems.map_system.init(world);

    let map_id = 1;
    let map = store.get_map(map_id);
    assert(map.id == map_id, 'map wrong id');
    assert(map.width == 25, 'map wrong width');
    assert(map.height == 25, 'map wrong height');

    let mut index: u32 = 0;
    let len: u32 = (map.width * map.height).try_into().unwrap();
    loop {
        if index == len {
            break;
        }
        let tile = store.get_tile(map_id, index);
        assert(tile.id == index, 'tile wrong id');
        assert(tile.walkable == true, 'tile wrong walkable');
        assert(tile.terrain_type == TerrainType::Grass.into(), 'tile wrong terrain_type');

        index += 1;
    };
}
