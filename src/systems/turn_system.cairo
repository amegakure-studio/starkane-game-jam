#[starknet::interface]
trait ITurnSystem<TContractState> {
    fn end_turn(self: @TContractState, match_id: u32, player: felt252);
}

#[dojo::contract]
mod turn_system {
    use super::ITurnSystem;
    use starkane::store::{Store, StoreTrait};
    use starkane::models::states::match_state::MatchPlayer;
    use starkane::models::entities::character::Character;

    use debug::PrintTrait;

    #[storage]
    struct Storage {}

    #[external(v0)]
    impl TurnSystem of ITurnSystem<ContractState> {
        fn end_turn(self: @ContractState, match_id: u32, player: felt252) {
            // [Setup] Datastore
            let mut store: Store = StoreTrait::new(self.world_dispatcher.read());

            let mut match_state = store.get_match_state(match_id);
            assert(match_state.winner.is_zero(), 'match already ended');
            assert(match_state.player_turn == player, 'wait for your turn');

            // Restart movement and action for character players
            let player_characters = store.get_match_player_characters(match_id, player);
            let mut i = 0;
            loop {
                if player_characters.len() == i {
                    break;
                }
                let mut character: Character = *player_characters[i];
                let mut action_state = store
                    .get_action_state(match_id, character.character_id, player);

                action_state.movement = false;
                action_state.action = false;
                store.set_action_state(action_state);

                i += 1;
            };

            // Increment turn counter
            match_state.turn += 1;
            // Change player turn to the next one
            match_state.player_turn = get_next_player_turn(ref store, match_id, player);
            store.set_match_state(match_state);
        }
    }

    fn get_next_player_turn(ref store: Store, match_id: u32, player: felt252) -> felt252 {
        let match_players = store.get_match_players(match_id);
        let player_index = get_player_index(@match_players, player).unwrap();
        let mut next_player = 0;
        // if the player is the last one, then should return to the first of the list
        let match_players_len = match_players.len();
        if player_index == match_players_len - 1 {
            let first_match_player: MatchPlayer = *match_players[0];
            next_player = first_match_player.player;
        } else {
            let mut i = 0;
            loop {
                if match_players_len == i || next_player != 0 {
                    break;
                }
                let match_player: MatchPlayer = *match_players[i];
                if match_player.player == player {
                    let next_match_player: MatchPlayer = *match_players[i + 1];
                    next_player = next_match_player.player;
                }
                i += 1;
            };
        }
        next_player
    }

    fn get_player_index(match_players: @Array<MatchPlayer>, player: felt252) -> Option<u32> {
        let mut i = 0;
        let mut index = Option::None(());
        loop {
            if match_players.len() == i {
                break;
            }
            let match_player: MatchPlayer = *match_players[i];
            if match_player.player == player {
                index = Option::Some(i);
                break;
            }
            i += 1;
        };
        index
    }
}
