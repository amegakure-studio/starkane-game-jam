// Core imports
use debug::PrintTrait;

// Dojo imports
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

// Internal imports
use starkane::store::{Store, StoreTrait};
use starkane::models::data::starkane::Recommendation;
use starkane::systems::recommendation_system::{
    IRecommendationSystemDispatcher, IRecommendationSystemDispatcherTrait
};

use starkane::tests::setup::{setup, setup::Systems, setup::PLAYER};

#[test]
#[available_gas(1_000_000_000)]
fn test_recommend_player() {
    // [Setup]
    let (world, systems) = setup::spawn_game();
    let mut store = StoreTrait::new(world);

    let PLAYER_1 = '0x1';
    let PLAYER_2 = '0x2';
    let PLAYER_3 = '0x3';

    let player_1_recommendation_bf = store.get_recommendation(PLAYER_1, PLAYER_2);
    let player_2_stadistics_bf = store.get_player_stadistics(PLAYER_2);
    assert(player_2_stadistics_bf.recommendation_score == 0, 'wrong player 2 reco score bf');
    assert(!player_1_recommendation_bf.recommended, 'wrong player 1 reco bf');
    systems.recommendation_system.recommend_player(PLAYER_1, PLAYER_2);

    let player_1_recommendation_af = store.get_recommendation(PLAYER_1, PLAYER_2);
    let player_2_stadistics_af = store.get_player_stadistics(PLAYER_2);
    assert(player_2_stadistics_af.recommendation_score == 1, 'wrong player 2 reco score af');
    assert(player_1_recommendation_af.recommended, 'wrong player 1 reco af');

    // new reco for player_2
    let PLAYER_3 = '0x3';
    systems.recommendation_system.recommend_player(PLAYER_3, PLAYER_2);

    let player_3_recommendation_af = store.get_recommendation(PLAYER_3, PLAYER_2);
    let player_2_stadistics_af = store.get_player_stadistics(PLAYER_2);
    assert(player_2_stadistics_af.recommendation_score == 2, 'wrong player 2 reco score af');
    assert(player_3_recommendation_af.recommended, 'wrong player 1 reco af');
}


#[test]
#[available_gas(1_000_000_000)]
fn test_recommend_several_players() {
    // [Setup]
    let (world, systems) = setup::spawn_game();
    let mut store = StoreTrait::new(world);

    let PLAYER_1 = '0x1';
    let PLAYER_2 = '0x2';
    let PLAYER_3 = '0x3';

    systems.recommendation_system.recommend_player(PLAYER_1, PLAYER_2);
    systems.recommendation_system.recommend_player(PLAYER_3, PLAYER_2);
    systems.recommendation_system.recommend_player(PLAYER_1, PLAYER_3);
    systems.recommendation_system.recommend_player(PLAYER_3, PLAYER_1);

    let player_1_stadistics_af = store.get_player_stadistics(PLAYER_1);
    let player_2_stadistics_af = store.get_player_stadistics(PLAYER_2);
    let player_3_stadistics_af = store.get_player_stadistics(PLAYER_3);
    assert(player_1_stadistics_af.recommendation_score == 1, 'wrong player 1 reco score af');
    assert(player_2_stadistics_af.recommendation_score == 2, 'wrong player 2 reco score af');
    assert(player_3_stadistics_af.recommendation_score == 1, 'wrong player 3 reco score af');
}

#[test]
#[available_gas(1_000_000_000)]
#[should_panic(expected: ('already recommend this player', 'ENTRYPOINT_FAILED'))]
fn test_recommend_player_same_from_to() {
    // [Setup]
    let (world, systems) = setup::spawn_game();
    let mut store = StoreTrait::new(world);

    let PLAYER_1 = '0x1';
    let PLAYER_2 = '0x2';

    systems.recommendation_system.recommend_player(PLAYER_1, PLAYER_2);
    systems.recommendation_system.recommend_player(PLAYER_1, PLAYER_2);
}

