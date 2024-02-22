#[starknet::interface]
trait IRecommendationSystem<TContractState> {
    fn recommend_player(self: @TContractState, from: felt252, to: felt252);
}

#[dojo::contract]
mod recommendation_system {
    use super::IRecommendationSystem;
    use starkane::store::{Store, StoreTrait};
    use starkane::models::data::starkane::Recommendation;

    #[storage]
    struct Storage {}

    #[abi(embed_v0)]
    impl RecommendationSystem of IRecommendationSystem<ContractState> {
        fn recommend_player(self: @ContractState, from: felt252, to: felt252) {
            // [Setup] Datastore
            let mut store: Store = StoreTrait::new(self.world_dispatcher.read());
            assert(
                !store.get_recommendation(from, to).recommended, 'already recommend this player'
            );

            store.set_recommendation(Recommendation { from, to, recommended: true });

            let mut to_stadistics = store.get_player_stadistics(to);
            to_stadistics.recommendation_score += 1;
            store.set_player_stadistics(to_stadistics);
        }
    }
}
