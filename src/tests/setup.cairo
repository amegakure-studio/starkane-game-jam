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

    use starkane::systems::character_system::{character_system, ICharacterSystemDispatcher};
    use starkane::systems::skill_system::{skill_system, ISkillSystemDispatcher};
    use starkane::systems::map_system::{map_system, IMapSystemDispatcher};

    // Constants

    fn PLAYER() -> ContractAddress {
        starknet::contract_address_const::<'PLAYER'>()
    }

    #[derive(Drop)]
    struct Systems {
        character_system: ICharacterSystemDispatcher,
        skill_system: ISkillSystemDispatcher,
        map_system: IMapSystemDispatcher,
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
        let character_system_address = deploy_contract(
            character_system::TEST_CLASS_HASH, array![].span()
        );
        let skill_system_address = deploy_contract(
            skill_system::TEST_CLASS_HASH, array![].span()
        );
        let map_system_address = deploy_contract(
            map_system::TEST_CLASS_HASH, array![].span()
        );

        let systems = Systems {
            character_system: ICharacterSystemDispatcher { contract_address: character_system_address },
            skill_system: ISkillSystemDispatcher { contract_address: skill_system_address },
            map_system: IMapSystemDispatcher { contract_address: map_system_address },
        };

        // [Return]
        set_contract_address(PLAYER());
        (world, systems)
    }
}