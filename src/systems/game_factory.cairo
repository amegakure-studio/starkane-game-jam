use starkane::models::entities::character::Character;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

#[derive(Copy, Drop, Serde)]
struct PlayerCharacter {
    player: felt252,
    character: Character
}

#[starknet::interface]
trait IActions<TContractState> {
    fn create(
        self: @TContractState, world: IWorldDispatcher, players_characters: Array<PlayerCharacter>
    );
}

#[starknet::contract]
mod actions {
    use super::{IActions, PlayerCharacter};
    use starkane::models::data::starkane::{MatchIndex, GAME_IDX_KEY};
    use starkane::models::entities::map::{Map, MapTrait};
    use starkane::models::entities::character::Character;
    use starkane::models::states::character_state::{ActionState, CharacterState};
    use starkane::models::states::match_state::{MatchState, MatchTrait, MatchPlayers,};
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

    #[storage]
    struct Storage {}

    #[external(v0)]
    impl Actions of IActions<ContractState> {
        fn create(
            self: @ContractState,
            world: IWorldDispatcher,
            players_characters: Array<PlayerCharacter>
        ) {
            assert(players_characters.len() > 0, 'characters cannot be empty');
            let game_index = get!(world, (GAME_IDX_KEY), (MatchIndex)).index;
            let mut new_game = MatchTrait::new(game_index);

            let players = get_players(@players_characters);
            let players_len = players.len();

            // Add players to the game
            let mut i = 0;
            loop {
                if i == players_len {
                    break;
                }
                let player = *players[i];
                set!(world, MatchPlayers { game_id: game_index, id: i, player: player });
                i += 1;
            };
            new_game.players_len = players_len;

            // Add player characters to the game
            let mut i = 0;
            loop {
                if i == players_characters.len() {
                    break;
                }
                let p: PlayerCharacter = *players_characters[i];
                let (x, y) = obtain_position(player_index(p.player, players), players_len, i);
                set!(
                    world,
                    CharacterState {
                        game_id: game_index,
                        character_id: p.character.character_id,
                        turn: 0,
                        player: p.player,
                        action_state: ActionState {
                            game_id: game_index,
                            character_id: p.character.character_id,
                            action: false,
                            movement: false
                        },
                        remain_hp: p.character.hp,
                        remain_mp: p.character.mp,
                        x: x,
                        y: y
                    }
                );
                i += 1;
            };

            set!(world, (new_game));
            set!(world, MatchIndex { id: GAME_IDX_KEY, index: game_index + 1 });
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
