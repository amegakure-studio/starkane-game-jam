use core::traits::Into;
// Core imports
use debug::PrintTrait;

// Dojo imports
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

// Internal imports
use starkane::store::{Store, StoreTrait};
use starkane::models::entities::map::{Map, Tile, TerrainType, DEFAULT_MAP_WIDTH, DEFAULT_MAP_HEIGHT};
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
    assert(map.width == DEFAULT_MAP_WIDTH, 'map wrong width');
    assert(map.height == DEFAULT_MAP_HEIGHT, 'map wrong height');

    let mut index: u32 = 0;
    let len: u32 = (DEFAULT_MAP_HEIGHT * DEFAULT_MAP_WIDTH).try_into().unwrap();
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