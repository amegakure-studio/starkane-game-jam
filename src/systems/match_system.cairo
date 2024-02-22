use starkane::models::entities::character::Character;

#[derive(Copy, Drop, Serde)]
struct PlayerCharacter {
    player: felt252,
    character_id: u32
}

#[starknet::interface]
trait IMatchSystem<TContractState> {
    fn init(self: @TContractState, players_characters: Array<PlayerCharacter>);
}

#[dojo::contract]
mod match_system {
    use super::{IMatchSystem, PlayerCharacter};
    use starkane::models::data::starkane::{MatchCount, MATCH_COUNT_KEY};
    use starkane::models::entities::map_cc::{MapCC, MapCCTrait};
    use starkane::models::entities::character::Character;
    use starkane::models::states::character_state::{
        ActionState, ActionStateTrait, CharacterState, CharacterStateTrait
    };
    use starkane::models::states::match_state::{
        MatchState, MatchTrait, MatchPlayer, MatchPlayerLen, MatchPlayerCharacter,
        MatchPlayerCharacterLen
    };
    use starkane::store::{Store, StoreTrait};

    #[storage]
    struct Storage {}

    #[abi(embed_v0)]
    impl MatchSystem of IMatchSystem<ContractState> {
        fn init(self: @ContractState, players_characters: Array<PlayerCharacter>) {
            // [Setup] Datastore
            let world = self.world();
            let mut store: Store = StoreTrait::new(world);

            assert(players_characters.len() > 0, 'characters cannot be empty');
            let match_count = store.get_match_count(MATCH_COUNT_KEY).index;
            // TODO: ver en que mapa van a jugar
            let map_id = 1;
            let mut new_match = MatchTrait::new(match_count, map_id);

            let players = get_players(@players_characters);
            let players_len = players.len();
            assert(players_len > 1, 'at least 2 players for a match');

            // Add players to the match
            store.set_match_player_len(MatchPlayerLen { match_id: match_count, players_len });
            let mut i = 0;
            loop {
                if i == players_len {
                    break;
                }
                let match_player = MatchPlayer {
                    match_id: match_count, id: i, player: *players[i]
                };
                store.set_match_player(match_player);
                i += 1;
            };

            // Add player characters to the match
            let mut characters_per_player: Felt252Dict<u32> = Default::default();
            let mut i = 0;
            loop {
                if i == players_characters.len() {
                    break;
                }
                let p: PlayerCharacter = *players_characters[i];
                // track how many character has every player
                characters_per_player.insert(p.player, characters_per_player.get(p.player) + 1);

                let (x, y) = obtain_position(player_index(p.player, players), i);
                let character = store.get_character(p.character_id);

                let mut match_player_characters_len = store
                    .get_match_player_characters_len(match_count, p.player);
                let match_player_character = MatchPlayerCharacter {
                    match_id: match_count,
                    player: p.player,
                    id: match_player_characters_len.characters_len,
                    character_id: character.character_id
                };
                match_player_characters_len.characters_len += 1;
                store.set_match_player_character_len(match_player_characters_len);
                store.set_match_player_character(match_player_character);

                // create a state for that character
                let character_state = CharacterStateTrait::new(
                    match_count, character.character_id, p.player, character.hp, character.mp, x, y
                );
                store.set_character_state(character_state);

                // create init action state for that character
                let action_state = ActionStateTrait::new(
                    match_count, character.character_id, p.player, false, false
                );

                store.set_action_state(action_state);
                i += 1;
            };

            // Add characters len per player
            i = 0;
            loop {
                if players_len == i {
                    break;
                }
                store
                    .set_match_player_character_len(
                        MatchPlayerCharacterLen {
                            match_id: match_count,
                            player: *players[i],
                            characters_len: characters_per_player.get(*players[i]),
                            remain_characters: characters_per_player.get(*players[i])
                        }
                    );
                i += 1;
            };

            // TODO: agregar mapa y asignar id
            new_match.player_turn = *players[0];
            store.set_match_state(new_match);
            store.set_match_count(MatchCount { id: MATCH_COUNT_KEY, index: match_count + 1 });
        }
    }

    fn obtain_position(player_index: u32, i: u32) -> (u64, u64) {
        if player_index == 0 {
            (5 + i.into(), 5)
        } else if player_index == 1 {
            (6 + i.into(), 11)
        } else if player_index == 2 {
            (5, 15 + i.into())
        } else {
            (24, 15 + i.into())
        }
    }

    fn get_players(players_characters: @Array<PlayerCharacter>) -> @Array<felt252> {
        let mut i = 0;
        let mut ret = array![];
        loop {
            if i == players_characters.len() {
                break;
            }
            let pc: PlayerCharacter = *players_characters[i];
            if !contains(pc.player, @ret) {
                ret.append(pc.player);
            }
            i += 1;
        };
        @ret
    }

    fn contains(item: felt252, arr: @Array<felt252>) -> bool {
        let mut i = 0;
        let mut founded = false;
        loop {
            if i == arr.len() {
                break;
            }
            let arr_item = *arr[i];
            if arr_item == item {
                founded = true;
                break;
            }
            i += 1;
        };
        founded
    }

    fn player_index(player: felt252, players: @Array<felt252>) -> u32 {
        let mut i = 0;
        let mut founded_idx = 999;
        loop {
            if i == players.len() {
                break;
            }
            if player == *players[i] {
                founded_idx = i;
                break;
            }
            i += 1;
        };
        founded_idx
    }
}
