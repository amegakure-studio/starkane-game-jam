use starkane::models::entities::character::Character;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

#[derive(Copy, Drop, Serde)]
struct PlayerCharacter {
    player: felt252,
    character_id: u32
}

#[starknet::interface]
trait IMatchSystem<TContractState> {
    fn init(
        self: @TContractState, world: IWorldDispatcher, players_characters: Array<PlayerCharacter>
    );
}

#[starknet::contract]
mod match_system {
    use super::{IMatchSystem, PlayerCharacter};
    use starkane::models::data::starkane::{MatchCount, MATCH_COUNT_KEY};
    use starkane::models::entities::map::{Map, MapTrait};
    use starkane::models::entities::character::Character;
    use starkane::models::states::character_state::{ActionState, ActionStateTrait, CharacterState, CharacterStateTrait};
    use starkane::models::states::match_state::{MatchState, MatchTrait, MatchPlayers,};
    use starkane::store::{Store, StoreTrait};

    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

    #[storage]
    struct Storage {}

    #[external(v0)]
    impl MatchSystem of IMatchSystem<ContractState> {
        fn init(
            self: @ContractState,
            world: IWorldDispatcher,
            players_characters: Array<PlayerCharacter>
        ) {
            // [Setup] Datastore
            let mut store: Store = StoreTrait::new(world);

            assert(players_characters.len() > 0, 'characters cannot be empty');
            let match_count = store.get_match_count(MATCH_COUNT_KEY).index;
            // TODO: ver en que mapa van a jugar
            let map_id = 1;
            let mut new_match = MatchTrait::new(match_count, map_id);

            let players = get_players(@players_characters);
            let players_len = players.len();

            // Add players to the match
            let mut i = 0;
            loop {
                if i == players_len {
                    break;
                }
                let player = *players[i];
                let match_players = MatchPlayers { match_id: match_count, id: i, player: player };
                store.set_match_players(match_players);
                i += 1;
            };
            new_match.players_len = players_len;

            // Add player characters to the match
            let mut i = 0;
            loop {
                if i == players_characters.len() {
                    break;
                }
                let p: PlayerCharacter = *players_characters[i];
                let (x, y) = obtain_position(player_index(p.player, players), players_len, i);
                let character = store.get_character(p.character_id);

                let character_state = CharacterStateTrait::new(
                    match_count,
                    character.character_id,
                    p.player,
                    0,
                    character.hp,
                    character.mp,
                    x,
                    y
                );
                store.set_character_state(character_state);
                let action_state = ActionStateTrait::new(
                    match_count,
                    character.character_id,
                    p.player,
                    false,
                    false
                );
                store.set_action_state(action_state);
                i += 1;
            };
        // TODO: agregar mapa y asignar id
        // set!(world, (new_match));
        // set!(world, MatchCount { id: MATCH_COUNT_KEY, index: match_count + 1 });
        }
    }

    fn obtain_position(player_index: u32, players_len: u32, i: u32) -> (u128, u128) {
        // if players_len == 4 {
        // } else if players_len == 3 {
        // } else if players_len == 2 {
        // } else {
        //     assert(1 == 0, 'its only one player!')
        // }

        (1, 1)
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
