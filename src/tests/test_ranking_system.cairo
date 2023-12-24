use core::traits::Into;
// Core imports
use debug::PrintTrait;

// Dojo imports
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

// Internal imports
use starkane::store::{Store, StoreTrait};
use starkane::models::data::starkane::{Ranking, RankingTrait, RankingCount, RankingCountTrait};
use starkane::systems::ranking_system::IRankingSystemDispatcherTrait;

use starkane::tests::setup::{setup, setup::Systems, setup::PLAYER};

// Constants
const ACCOUNT: felt252 = 'ACCOUNT';
const SEED: felt252 = 'SEED';
const NAME: felt252 = 'NAME';

#[test]
#[available_gas(1_000_000_000_000_000)]
fn test_ranking() {
    // [Setup]
    let (world, systems) = setup::spawn_game();
    let mut store = StoreTrait::new(world);

    let ranking_0 = RankingTrait::new(0, 'PLAYER_1', 100);
    let ranking_1 = RankingTrait::new(1, 'PLAYER_2', 200);
    let ranking_2 = RankingTrait::new(2, 'PLAYER_3', 300);
    let ranking_3 = RankingTrait::new(3, 'PLAYER_4', 400);
    let ranking_4 = RankingTrait::new(4, 'PLAYER_5', 500);

    systems.ranking_system.update(ranking_0.player, ranking_0.score);
    assert(store.get_ranking(0) == ranking_0, 'wrong ranking first');

    systems.ranking_system.update(ranking_1.player, ranking_1.score);
    assert(store.get_ranking(1) == ranking_0, 'wrong ranking second');
    assert(store.get_ranking(0) == ranking_1, 'wrong ranking second');

    systems.ranking_system.update(ranking_4.player, ranking_4.score);
    assert(store.get_ranking(2) == ranking_0, 'wrong ranking third');
    assert(store.get_ranking(1) == ranking_1, 'wrong ranking third');
    assert(store.get_ranking(0) == ranking_4, 'wrong ranking third');

    systems.ranking_system.update(ranking_3.player, ranking_3.score);
    assert(store.get_ranking(3) == ranking_0, 'wrong ranking fourth');
    assert(store.get_ranking(2) == ranking_1, 'wrong ranking fourth');
    assert(store.get_ranking(1) == ranking_3, 'wrong ranking fourth');
    assert(store.get_ranking(0) == ranking_4, 'wrong ranking fourth');

    systems.ranking_system.update(ranking_2.player, ranking_2.score);
    assert(store.get_ranking(4) == ranking_0, 'wrong ranking fifth');
    assert(store.get_ranking(3) == ranking_1, 'wrong ranking fifth');
    assert(store.get_ranking(2) == ranking_2, 'wrong ranking fifth');
    assert(store.get_ranking(1) == ranking_3, 'wrong ranking fifth');
    assert(store.get_ranking(0) == ranking_4, 'wrong ranking fifth');

    let ranking_2 = RankingTrait::new(2, 'PLAYER_3', 800);
    systems.ranking_system.update(ranking_2.player, ranking_2.score);
    assert(store.get_ranking(4) == ranking_0, 'wrong ranking sixth');
    assert(store.get_ranking(3) == ranking_1, 'wrong ranking sixth');
    assert(store.get_ranking(2) == ranking_3, 'wrong ranking sixth');
    assert(store.get_ranking(1) == ranking_4, 'wrong ranking sixth');
    assert(store.get_ranking(0) == ranking_2, 'wrong ranking sixth');
}

#[test]
#[available_gas(1_000_000_000_000_000)]
fn test_top_20_new_player() {
    // [Setup]
    let (world, systems) = setup::spawn_game();
    let mut store = StoreTrait::new(world);
    store.set_ranking(RankingTrait::new(0, '0', 7000));
    store.set_ranking(RankingTrait::new(1, '1', 1900));
    store.set_ranking(RankingTrait::new(2, '2', 1800));
    store.set_ranking(RankingTrait::new(3, '3', 1700));
    store.set_ranking(RankingTrait::new(4, '4', 1600));
    store.set_ranking(RankingTrait::new(5, '5', 1500));
    store.set_ranking(RankingTrait::new(6, '6', 1400));
    store.set_ranking(RankingTrait::new(7, '7', 1300));
    store.set_ranking(RankingTrait::new(8, '8', 1200));
    store.set_ranking(RankingTrait::new(9, '9', 1100));
    store.set_ranking(RankingTrait::new(10, '10', 900));
    store.set_ranking(RankingTrait::new(11, '11', 800));
    store.set_ranking(RankingTrait::new(12, '12', 700));
    store.set_ranking(RankingTrait::new(13, '13', 600));
    store.set_ranking(RankingTrait::new(14, '14', 500));
    store.set_ranking(RankingTrait::new(15, '15', 400));
    store.set_ranking(RankingTrait::new(16, '16', 300));
    store.set_ranking(RankingTrait::new(17, '17', 200));
    store.set_ranking(RankingTrait::new(18, '18', 100));
    store.set_ranking(RankingTrait::new(19, '19', 90));

    store.set_ranking_count(RankingCountTrait::new(20));

    // new player top 1
    systems.ranking_system.update('top_1', 7500);

    assert(store.get_ranking(0).player == 'top_1', 'wrong test top 20 player');
    assert(store.get_ranking(0).score == 7500, 'wrong test top 20 score');

    assert(store.get_ranking(19).player == '18', 'wrong test top 20 last');
    assert(store.get_ranking(19).score == 100, 'wrong test top 20 last');
}

#[test]
#[available_gas(1_000_000_000_000_000)]
fn test_top_20_player_already_in_top() {
    // [Setup]
    let (world, systems) = setup::spawn_game();
    let mut store = StoreTrait::new(world);
    store.set_ranking(RankingTrait::new(0, '0', 7000));
    store.set_ranking(RankingTrait::new(1, '1', 1900));
    store.set_ranking(RankingTrait::new(2, '2', 1800));
    store.set_ranking(RankingTrait::new(3, '3', 1700));
    store.set_ranking(RankingTrait::new(4, '4', 1600));
    store.set_ranking(RankingTrait::new(5, '5', 1500));
    store.set_ranking(RankingTrait::new(6, '6', 1400));
    store.set_ranking(RankingTrait::new(7, '7', 1300));
    store.set_ranking(RankingTrait::new(8, '8', 1200));
    store.set_ranking(RankingTrait::new(9, '9', 1100));
    store.set_ranking(RankingTrait::new(10, '10', 900));
    store.set_ranking(RankingTrait::new(11, '11', 800));
    store.set_ranking(RankingTrait::new(12, '12', 700));
    store.set_ranking(RankingTrait::new(13, '13', 600));
    store.set_ranking(RankingTrait::new(14, '14', 500));
    store.set_ranking(RankingTrait::new(15, '15', 400));
    store.set_ranking(RankingTrait::new(16, '16', 300));
    store.set_ranking(RankingTrait::new(17, '17', 200));
    store.set_ranking(RankingTrait::new(18, '18', 100));
    store.set_ranking(RankingTrait::new(19, '19', 90));

    store.set_ranking_count(RankingCountTrait::new(20));

    // new player top 1
    systems.ranking_system.update('4', 7500);

    assert(store.get_ranking(0).player == '4', 'wrong test top 20 player');
    assert(store.get_ranking(0).score == 7500, 'wrong test top 20 score');

    assert(store.get_ranking(19).player == '19', 'wrong test top 20 last');
    assert(store.get_ranking(19).score == 90, 'wrong test top 20 last');
}
