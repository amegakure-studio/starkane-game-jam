use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

#[starknet::interface]
trait IActions<TContractState> {
    fn move(self: @TContractState, world: IWorldDispatcher, game_id: u32, player_address: felt252, character_id: u32, position: (u128, u128));
}

#[starknet::contract]
mod actions {
    use super::IActions;
    use arcane_abyss::models::character::{CharacterOwned, Character, CharacterImpl, CharacterTrait};
    use arcane_abyss::models::game::{GameState, CharacterState};
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

    #[storage]
    struct Storage {}

    #[external(v0)]
    impl Actions of IActions<ContractState> {
        fn move(self: @ContractState, world: IWorldDispatcher, game_id: u32, player_address: felt252, character_id: u32, position: (u128, u128)) {
            let game_state = get!(world, (game_id), (GameState));
            assert(!game_state.over, 'ERR: this game is over!');
            assert(game_state.player_address_turn == player_address, 'ERR: wait for your turn!');

            let character_owned = CharacterImpl::has_character_owned(world: world, id: character_id, player_address: player_address);
            assert(character_owned, 'ERR: player wrong character_id');

            let character_stats = get!(world, (character_id), (Character));
            let character_state = get!(world, (game_id, character_id, game_state.turn), (CharacterState));

            // assert(character_)
        }
    }

    fn get_distance(initial: (u128, u128), end: (u128, u128)) -> u32 {
        1
    }
}
