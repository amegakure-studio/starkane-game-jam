use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

#[starknet::interface]
trait IMapSystem<TContractState> {
    fn init(self: @TContractState, world: IWorldDispatcher);
}

#[starknet::contract]
mod map_system {
    use super::IMapSystem;
    use starkane::models::entities::map::{Map, MapTrait};
    use starkane::store::{Store, StoreTrait};
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

    #[storage]
    struct Storage {}

    #[external(v0)]
    impl MapSystem of IMapSystem<ContractState> {
        fn init(self: @ContractState, world: IWorldDispatcher) {
            // [Setup] Datastore
            let mut store: Store = StoreTrait::new(world);

            let map_id = 1;
            let (map, tiles) = MapTrait::new(map_id);

            store.set_map(map);

            let mut idx = 0;
            loop {
                if idx == tiles.len() {
                    break;
                }
                store.set_tile(*tiles.at(idx));
                idx += 1;
            }
        }
    }
}
