#[starknet::interface]
trait IRecommendSystem<TContractState> {
    fn recommend_player(self: @ContractState, from: felt252, to: felt252);
}

#[dojo::contract]
mod recommend_system {
    use super::IRecommendSystem;
    use starkane::store::{Store, StoreTrait};

    #[storage]
    struct Storage {}

    #[external(v0)]
    impl RecommendSystem of IRecommendSystem<ContractState> {
        fn recommend_player(self: @ContractState, from: felt252, to: felt252) {
            // [Setup] Datastore
            let mut store: Store = StoreTrait::new(self.world_dispatcher.read());
            assert(!store.get_recommendation(from, to), 'you already recommend this player');

            set_recommendation(Recommendation { from, to, recommended: true });

            let mut to_stadistics = get_player_stadistics(to);
            to_stadistics.recommendation_score += 1;
            set_player_stadistics(to_stadistics);
        }   
    }
}
