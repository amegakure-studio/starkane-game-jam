use dojo::world::IWorldDispatcher;

#[starknet::interface]
trait IActions<TContractState> {
    fn init(self: @TContractState, world: IWorldDispatcher);
}

#[starknet::contract]
mod actions {
    use super::IActions;

    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

    use starkane::models::map::{Map, Position, Tile};

    #[storage]
    struct Storage {}

    #[external(v0)]
    impl Actions of IActions<ContractState> {
        fn create(self: @ContractState, world: IWorldDispatcher) {}
    }
}
