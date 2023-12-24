use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use starkane::models::data::starkane::Ranking;

#[starknet::interface]
trait IRankingSystem<TContractState> {
    fn update(self: @TContractState, player: felt252, score: u64);
}

#[dojo::contract]
mod ranking_system {
    use super::IRankingSystem;
    use starkane::models::entities::map::{Map, MapTrait};
    use starkane::store::{Store, StoreTrait};
    use starkane::models::data::starkane::{
        Ranking, RankingTrait, RankingCount, RankingCountTrait, RANKING_COUNT_KEY
    };
    use alexandria_sorting::merge_sort::merge;
    use alexandria_data_structures::array_ext::ArrayTraitExt;

    use debug::PrintTrait;

    const RANKING_MAX_LEN: u32 = 20;

    #[external(v0)]
    impl RankingSystem of IRankingSystem<ContractState> {
        fn update(self: @ContractState, player: felt252, score: u64) {
            // [Setup] Datastore
            let mut store: Store = StoreTrait::new(self.world());
            let ranking_count = store.get_ranking_count(RANKING_COUNT_KEY).index;

            if ranking_count >= RANKING_MAX_LEN {
                let last_ranking = store.get_ranking(RANKING_MAX_LEN - 1);
                if score > last_ranking.score {
                    let (mut top_20, was_top_player) = get_rankings(
                        ref store, player, RANKING_MAX_LEN, score
                    );
                    let sorted = merge(top_20);
                    set_rankings(ref store, sorted);
                    if !was_top_player {
                        store.set_ranking_count(RankingCountTrait::new(ranking_count + 1));
                    }
                }
            } else {
                let (top, was_top_player) = get_rankings(ref store, player, ranking_count, score);
                let sorted = merge(top);
                set_rankings(ref store, sorted);

                if !was_top_player {
                    store.set_ranking_count(RankingCountTrait::new(ranking_count + 1));
                }
            }
        }
    }

    fn get_rankings(
        ref store: Store, player: felt252, ranking_len: u32, score: u64
    ) -> (Array<Ranking>, bool) {
        let mut rankings = array![];
        let mut founded = false;
        let mut i = 0;
        loop {
            if i == ranking_len {
                break;
            }
            let ranking = store.get_ranking(i);
            if ranking.player == player {
                rankings.append(RankingTrait::new(0, player, score));
                founded = true;
            } else {
                rankings.append(ranking);
            }
            i += 1;
        };
        if !founded {
            rankings.append(RankingTrait::new(0, player, score));
        }
        (rankings, founded)
    }

    fn set_rankings(ref store: Store, sorted: Array<Ranking>) {
        let mut i = sorted.len();
        let corte = if sorted.len() == 21 {
            1
        } else {
            0
        };
        let mut id = 0;
        loop {
            if i == corte {
                break;
            }
            i -= 1;
            let mut new_ranking = *sorted.at(i);
            new_ranking.id = sorted.len() - i.into() - 1;
            store.set_ranking(new_ranking);
        };
    }
}
