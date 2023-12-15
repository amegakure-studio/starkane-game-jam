use dojo::world::IWorldDispatcher;

#[starknet::interface]
trait IActions<TContractState> {
    fn create(self: @TContractState, world: IWorldDispatcher, player: felt252, seed: felt252,);
}

#[starknet::contract]
mod actions {
    use super::IActions;

    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

    #[storage]
    struct Storage {}

    #[external(v0)]
    impl Actions of IActions<ContractState> {
        fn create(self: @ContractState, world: IWorldDispatcher, player: felt252, seed: felt252,) {}
    }
}

