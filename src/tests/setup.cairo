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
    use starkane::models::data::starkane::{
        character_player_progress, CharacterPlayerProgress, match_count, MatchCount
    };

    use starkane::systems::character_system::{character_system, ICharacterSystemDispatcher};
    use starkane::systems::skill_system::{skill_system, ISkillSystemDispatcher};
    use starkane::systems::map_system::{map_system, IMapSystemDispatcher};
    use starkane::systems::match_system::{match_system, IMatchSystemDispatcher};
    use starkane::systems::action_system::{action_system, IActionSystemDispatcher};
    use starkane::systems::move_system::{move_system, IMoveSystemDispatcher};
    use starkane::systems::turn_system::{turn_system, ITurnSystemDispatcher};
    use starkane::systems::ranking_system::{ranking_system, IRankingSystemDispatcher};

    // Constants

    fn PLAYER() -> ContractAddress {
        starknet::contract_address_const::<'PLAYER'>()
    }

    #[derive(Drop)]
    struct Systems {
        character_system: ICharacterSystemDispatcher,
        skill_system: ISkillSystemDispatcher,
        map_system: IMapSystemDispatcher,
        match_system: IMatchSystemDispatcher,
        action_system: IActionSystemDispatcher,
        move_system: IMoveSystemDispatcher,
        turn_system: ITurnSystemDispatcher,
        ranking_system: IRankingSystemDispatcher,
    }

    fn spawn_game() -> (IWorldDispatcher, Systems) {
        // [Setup] World
        let models = array![
            match_state::TEST_CLASS_HASH,
            character_state::TEST_CLASS_HASH,
            character::TEST_CLASS_HASH,
            skill::TEST_CLASS_HASH,
            tile::TEST_CLASS_HASH,
            character_player_progress::TEST_CLASS_HASH,
            match_count::TEST_CLASS_HASH,
        ];

        let world = spawn_test_world(models);

        // [Setup] Systems
        let systems = Systems {
            character_system: ICharacterSystemDispatcher {
                contract_address: world
                    .deploy_contract('paper', character_system::TEST_CLASS_HASH.try_into().unwrap())
            },
            skill_system: ISkillSystemDispatcher {
                contract_address: world
                    .deploy_contract('paper', skill_system::TEST_CLASS_HASH.try_into().unwrap())
            },
            map_system: IMapSystemDispatcher {
                contract_address: world
                    .deploy_contract('paper', map_system::TEST_CLASS_HASH.try_into().unwrap())
            },
            match_system: IMatchSystemDispatcher {
                contract_address: world
                    .deploy_contract('paper', match_system::TEST_CLASS_HASH.try_into().unwrap())
            },
            action_system: IActionSystemDispatcher {
                contract_address: world
                    .deploy_contract('paper', action_system::TEST_CLASS_HASH.try_into().unwrap())
            },
            move_system: IMoveSystemDispatcher {
                contract_address: world
                    .deploy_contract('paper', move_system::TEST_CLASS_HASH.try_into().unwrap())
            },
            turn_system: ITurnSystemDispatcher {
                contract_address: world
                    .deploy_contract('paper', turn_system::TEST_CLASS_HASH.try_into().unwrap())
            },
            ranking_system: IRankingSystemDispatcher {
                contract_address: world
                    .deploy_contract('paper', ranking_system::TEST_CLASS_HASH.try_into().unwrap())
            },
        };

        // let character_system_address = deploy_contract(
        //     character_system::TEST_CLASS_HASH, array![].span()
        // );
        // let skill_system_address = deploy_contract(skill_system::TEST_CLASS_HASH, array![].span());
        // let map_system_address = deploy_contract(map_system::TEST_CLASS_HASH, array![].span());
        // let match_system_address = deploy_contract(match_system::TEST_CLASS_HASH, array![].span());
        // let action_system_address = deploy_contract(
        //     action_system::TEST_CLASS_HASH, array![].span()
        // );
        // let move_system_address = deploy_contract(move_system::TEST_CLASS_HASH, array![].span());
        // let turn_system_address = deploy_contract(turn_system::TEST_CLASS_HASH, array![].span());

        // let systems = Systems {
        //     character_system: ICharacterSystemDispatcher {
        //         contract_address: character_system_address
        //     },
        //     skill_system: ISkillSystemDispatcher { contract_address: skill_system_address },
        //     map_system: IMapSystemDispatcher { contract_address: map_system_address },
        //     match_system: IMatchSystemDispatcher { contract_address: match_system_address },
        //     action_system: IActionSystemDispatcher { contract_address: action_system_address },
        //     move_system: IMoveSystemDispatcher { contract_address: move_system_address },
        //     // turn_system: ITurnSystemDispatcher { contract_address: turn_system_address },
        // };

        // [Return]
        set_contract_address(PLAYER());
        (world, systems)
    }
}
