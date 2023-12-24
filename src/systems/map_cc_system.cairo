use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

#[starknet::interface]
trait IMapCCSystem<TContractState> {
    fn init(ref self: TContractState);
}

#[dojo::contract]
mod map_cc_system {
    use super::IMapCCSystem;
    use starknet::{get_caller_address, ContractAddress};
    use starkane::models::entities::map_cc::MapCC;
    use starkane::store::{Store, StoreTrait};
    use cc_starknet::{Dungeons, utils::pack::Pack};

    #[storage]
    struct Storage {}

    #[external(v0)]
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
            // let (pack, size) = Dungeons::get_layout(@state, 5472685640234506636278424762823059598933394071647911965527120692794348915138, 25);
            // println!("first: {}", pack.first);
            // println!("second: {}", pack.second);
            // println!("third: {}", pack.third);

            set!(
                world,
                MapCC {
                    id: 1,
                    token_id: 1,
                    size: 25,
                    obstacles_1: pack.first,
                    obstacles_2: pack.second,
                    obstacles_3: pack.third,
                    // obstacles_1: dungeon.layout.first,
                    // obstacles_2: dungeon.layout.second,
                    // obstacles_3: dungeon.layout.third,
                    owner: Dungeons::ERC721Impl::owner_of(@state, 1).into(),
                    width: 25,
                    height: 25,
                }
            );
        }
    }
}
