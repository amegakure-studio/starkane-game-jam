#[starknet::interface]
trait IStadisticsSystem<TContractState> {
    // fn record_match_stadistics(self: @TContractState, match_id: u32);
}
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

#[dojo::contract]
mod stadistics_system {
    use super::IStadisticsSystem;
    use starkane::store::{Store, StoreTrait};
    use starkane::models::states::match_state::{ MatchState, MatchPlayer };
    use starkane::models::states::character_state::CharacterState;


    #[storage]
    struct Storage {}

    #[external(v0)]
    impl StadisticsSystem of IStadisticsSystem<ContractState> {
    }

    fn record_match_stadistics(world: IWorldDispatcher, match_id: u32) {
            // [Setup] Datastore
            let mut store: Store = StoreTrait::new(world);
            
            let match_state = store.get_match_state(match_id);
            let match_players = store.get_match_players(match_id);
            let winner_characters_states = store.get_match_player_characters_states(match_id, match_state.winner);

            let mut i = 0;
            loop {
                if i == match_players.len() {
                    break;
                }
                let match_player: MatchPlayer = (*match_players[i]);
                let mut player_stadistics = store.get_player_stadistics(match_player.player);
                if match_player.player == match_state.winner {
                    player_stadistics.total_score += calculate_score(match_state, @winner_characters_states);
                    player_stadistics.matchs_won += 1; 
                } else {
                    // give 50 points to player for participate
                    player_stadistics.total_score += 50; 
                    player_stadistics.matchs_lost += 1; 
                }
                store.set_player_stadistics(player_stadistics);
                i += 1;
            }
        }

    fn calculate_score(match_state: MatchState, characters_states: @Array<CharacterState>) -> u128 {
        let mut score = 0;
        let mut i = 0;
        loop {
            if characters_states.len() == i {
                break;
            }
            let character_state: CharacterState = (*characters_states[i]);
            score += character_state.remain_hp;
            i += 1;
        };
        score
    }
}
