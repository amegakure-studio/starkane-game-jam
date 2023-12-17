mod setup {
    // Starknet imports

    use starknet::ContractAddress;
    use starknet::testing::set_contract_address;

    // Dojo imports

    use dojo::world::{IWorldDispatcherTrait, IWorldDispatcher};
    use dojo::test_utils::{spawn_test_world, deploy_contract};

    // Internal imports

    use starkane::models::states::match_state::{match_state, MatchState};
    use starkane::models::states::character_state::{character_state, CharacterState};
    use starkane::models::entities::character::{character, Character};
    use starkane::models::entities::skill::{skill, Skill};
    use starkane::models::entities::map::{tile, Tile};
    use starkane::models::data::starkane::{character_player_progress, CharacterPlayerProgress, match_index, MatchIndex};

    use starkane::systems::character_manager::{actions as player_actions, IActionsDispatcher};

    // Constants

    fn PLAYER() -> ContractAddress {
        starknet::contract_address_const::<'PLAYER'>()
    }

    #[derive(Drop)]
    struct Systems {
        player_actions: IActionsDispatcher,
    }

    fn spawn_game() -> (IWorldDispatcher, Systems) {
        // [Setup] World
        let mut models = array::ArrayTrait::new();
        models.append(match_state::TEST_CLASS_HASH);
        models.append(character_state::TEST_CLASS_HASH);
        models.append(character::TEST_CLASS_HASH);
        models.append(skill::TEST_CLASS_HASH);
        models.append(tile::TEST_CLASS_HASH);
        models.append(character_player_progress::TEST_CLASS_HASH);
        models.append(match_index::TEST_CLASS_HASH);

        let world = spawn_test_world(models);

        // [Setup] Systems
        let player_actions_address = deploy_contract(
            player_actions::TEST_CLASS_HASH, array![].span()
        );

        let systems = Systems {
            player_actions: IActionsDispatcher { contract_address: player_actions_address },
        };

        // [Return]
        set_contract_address(PLAYER());
        (world, systems)
    }
}