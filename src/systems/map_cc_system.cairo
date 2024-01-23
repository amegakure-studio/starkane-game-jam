use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

#[starknet::interface]
trait IMapCCSystem<TContractState> {
    fn init(ref self: TContractState);
    fn mint_cc_map(ref self: TContractState, player: felt252);
}

#[dojo::contract]
mod map_cc_system {
    use cc_starknet::IERC721Enumerable;
    use super::IMapCCSystem;
    use starknet::{get_caller_address, ContractAddress};
    use starkane::models::entities::map_cc::MapCC;
    use starkane::store::{Store, StoreTrait};
    use cc_starknet::{Dungeons, utils::pack::Pack, IERC721EnumerableDispatcher};

    #[storage]
    struct Storage {}

    #[abi(embed_v0)]
    impl MapCCSystem of IMapCCSystem<ContractState> {
        fn init(ref self: ContractState) {
            // [Setup] Datastore
            let world = self.world();
            let mut store: Store = StoreTrait::new(world);

            let mut state = Dungeons::unsafe_new_contract_state();
            Dungeons::mint(ref state);
            // let dungeon = Dungeons::generate_dungeon_dojo(@state, 1);
            let player = get_caller_address();

            let (pack, size) = Dungeons::get_layout(
                @state,
                2736342820117253318139212381411529799466697035823955982763560346397174457569,
                26
            );

            set!(
                world,
                MapCC {
                    id: 1,
                    token_id: 1,
                    size: 25,
                    obstacles_1: pack.first,
                    obstacles_2: pack.second,
                    obstacles_3: pack.third,
                    owner: Dungeons::ERC721Impl::owner_of(@state, 1).into(),
                    width: 25,
                    height: 25,
                }
            );
        }

        fn mint_cc_map(ref self: ContractState, player: felt252) {
            // [Setup] Datastore
            let world = self.world();
            let mut store: Store = StoreTrait::new(world);

            assert(player.is_non_zero(), 'player cannot be zero');

            // Check if owner has enough played matches
            let player_stadistics = store.get_player_stadistics(player);
            assert(
                player_stadistics.matchs_lost + player_stadistics.matchs_won >= 5,
                'you need 5 matchs to claim this'
            );

            let mut state = Dungeons::unsafe_new_contract_state();
            Dungeons::mint(ref state);
            let last_mint = state.total_supply();
            let dungeon = Dungeons::generate_dungeon_dojo(@state, last_mint);

            set!(
                world,
                MapCC {
                    id: last_mint.try_into().unwrap(),
                    token_id: last_mint.try_into().unwrap(),
                    size: dungeon.size,
                    obstacles_1: dungeon.layout.first,
                    obstacles_2: dungeon.layout.second,
                    obstacles_3: dungeon.layout.third,
                    owner: player,
                    width: 25,
                    height: 25,
                }
            );
        }
    }
}
