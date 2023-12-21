use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

#[starknet::interface]
trait IMoveSystem<TContractState> {
    fn move(
        self: @TContractState,
        world: IWorldDispatcher,
        match_id: u32,
        player: felt252,
        character_id: u32,
        position: (u128, u128)
    );
}

#[starknet::contract]
mod move_system {
    use super::IMoveSystem;
    use starkane::models::states::match_state::MatchState;
    use starkane::models::states::character_state::{
        CharacterState, ActionState, ActionStateTrait
    };

    use starkane::models::entities::map::{Map, Tile, MapTrait};
    use starkane::models::entities::character::Character;
    use starkane::store::{Store, StoreTrait};

    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

    use debug::PrintTrait;
    
    #[storage]
    struct Storage {}

    #[external(v0)]
    impl MoveSystem of IMoveSystem<ContractState> {
        fn move(
            self: @ContractState,
            world: IWorldDispatcher,
            match_id: u32,
            player: felt252,
            character_id: u32,
            position: (u128, u128)
        ) {
            // [Setup] Datastore
            let mut store: Store = StoreTrait::new(world);

            let match_state = store.get_match_state(match_id);
            assert(match_state.winner == 0, 'this match is over');
            assert(match_state.player_turn == player, 'wait for your turn');

            let character_progress = store.get_character_player_progress(player, character_id);
            assert(character_progress.owned, 'player wrong character_id');

            let mut last_action_state = store.get_action_state(match_id, character_id, player);
            assert(!last_action_state.movement, 'already move in this turn');

            let (to_x, to_y) = position;
            let map = store.get_map(match_state.map_id);
            assert(map.is_inside((to_x, to_y)), 'position is outside of map');

            let mut character_state = store
                .get_character_state(match_state.id, character_id, player);
            assert(!(character_state.x == to_x && character_state.y == to_y), 'already in that position');

            // TODO: remove map_id hardcoded
            assert(
                store.get_tile(1, (to_y * map.width + to_x).try_into().unwrap()).walkable,
                'tile not walkable'
            );

            let character = store.get_character(character_id);
            let distance_to = distance((character_state.x, character_state.y), (to_x, to_y));
            assert(distance_to <= character.movement_range, 'character cannot move that far');

            character_state.x = to_x;
            character_state.y = to_y;
            store.set_character_state(character_state);

            last_action_state.movement = true;
            store.set_action_state(last_action_state);
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
            from_y - to_y
        } else {
            to_y - from_y
        };
        distance_x + distance_y
    }
}
