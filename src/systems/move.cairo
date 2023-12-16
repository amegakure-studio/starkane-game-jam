use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

#[starknet::interface]
trait IActions<TContractState> {
    fn move(
        self: @TContractState,
        world: IWorldDispatcher,
        game_id: u32,
        player: felt252,
        character_id: u32,
        position: (u128, u128)
    );
}

#[starknet::contract]
mod actions {
    use super::IActions;
    use starkane::models::states::match_state::MatchState;
    use starkane::models::states::character_state::CharacterState;

    use starkane::models::entities::map::{Map, Tile, MapTrait, DEFAULT_MAP_WIDTH};
    use starkane::models::entities::character::{Character, CharacterTypeIntoU32};
    use starkane::systems::character_manager::actions::Actions as CharacterActions;
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

    #[storage]
    struct Storage {}

    #[external(v0)]
    impl Actions of IActions<ContractState> {
        fn move(
            self: @ContractState,
            world: IWorldDispatcher,
            game_id: u32,
            player: felt252,
            character_id: u32,
            position: (u128, u128)
        ) {
            let match_state = get!(world, (game_id), (MatchState));
            assert(!match_state.over, 'ERR: this game is over!');
            assert(match_state.player_turn == player, 'ERR: wait for your turn!');

            // TODO: resolve this into Store
            // let character_owned = CharacterActions::has_character_owned(world, character_id, player
            // );
            // assert(character_owned, 'ERR: player wrong character_id');

            let mut character_state = get!(
                world, (game_id, character_id, player), (CharacterState)
            );
            assert(!character_state.action_state.movement, 'already move in this turn');

            let (to_x, to_y) = position;
            assert(MapTrait::is_inside((to_x, to_y)), 'position is outside of map');
            assert(
                character_state.x != to_x && character_state.y != to_y, 'already in that position'
            );
            // TODO: height hardcoded, this should be taken from map
            assert(
                get!(world, (to_y * DEFAULT_MAP_WIDTH + to_x), (Tile)).walkable, 'tile not walkable'
            );

            let character = get!(world, (character_id), (Character));
            let distance_to = distance((character_state.x, character_state.y), (to_x, to_y));
            assert(distance_to <= character.movement_range, 'character cannot move that far');

            character_state.x = to_x;
            character_state.y = to_y;
            character_state.action_state.movement = true;
            set!(world, (character_state))
        }
    }

    fn distance(from: (u128, u128), to: (u128, u128)) -> u128 {
        let (from_x, from_y) = from;
        let (to_x, to_y) = to;

        let distance_x = if from_x > to_x {
            from_x - to_x
        } else {
            to_x - from_x
        };
        let distance_y = if from_y > to_y {
            to_x - to_y
        } else {
            to_y - to_x
        };
        distance_x + distance_y
    }
}
