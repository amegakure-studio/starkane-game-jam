#[starknet::interface]
trait IActionSystem<TContractState> {
    fn action(
        self: @TContractState,
        match_id: u32,
        player: felt252,
        player_character_id: u32,
        skill_id: u32,
        level: u32,
        receiver: felt252,
        receiver_character_id: u32
    );
}

#[dojo::contract]
mod action_system {
    use super::IActionSystem;

    use starkane::models::entities::character::{Character, CharacterTrait};
    use starkane::models::entities::skill::{Skill, SkillType, SkillTypeIntoU8, U8TryIntoSkillType};
    use starkane::models::states::match_state::MatchState;
    use starkane::models::states::character_state::{CharacterState, ActionState, ActionStateTrait};
    use starkane::systems::stadistics_system::stadistics_system;
    use starkane::store::{Store, StoreTrait};
    use starkane::utils::random::{Random, RandomImpl, RandomTrait};

    use debug::PrintTrait;

    #[storage]
    struct Storage {}

    #[abi(embed_v0)]
    impl ActionSystem of IActionSystem<ContractState> {
        // Character -> Character
        fn action(
            self: @ContractState,
            match_id: u32,
            player: felt252,
            player_character_id: u32,
            skill_id: u32,
            level: u32,
            receiver: felt252,
            receiver_character_id: u32
        ) {
            // [Setup] Datastore
            let world = self.world();
            let mut store: Store = StoreTrait::new(world);

            let match_state = store.get_match_state(match_id);
            assert(match_state.winner == 0, 'this match is over');
            assert(match_state.player_turn == player, 'wait for your turn');

            let last_action_state = store.get_action_state(match_id, player_character_id, player);
            assert(!last_action_state.action, 'already took action this turn');

            let player_character = store.get_character(player_character_id);
            let mut player_character_state = store
                .get_character_state(match_state.id, player_character_id, player);

            let receiver_character = store.get_character(receiver_character_id);
            let receiver_character_state = store
                .get_character_state(match_state.id, receiver_character_id, receiver);

            // obtener skill
            let skill = store.get_skill(skill_id, player_character_id, level);

            // fijarse que tenga el skill el que ataca
            let skill_type: SkillType = skill
                .skill_type
                .try_into()
                .expect('char doesnt possess that skill');

            match skill_type {
                SkillType::MeeleAttack => {
                    attack(
                        world,
                        player_character,
                        player_character_state,
                        skill,
                        receiver_character,
                        receiver_character_state
                    );
                    check_and_update_game_state_winner(
                        world, ref store, match_id, player, receiver_character_id, receiver
                    );
                },
                SkillType::RangeAttack => {
                    attack(
                        world,
                        player_character,
                        player_character_state,
                        skill,
                        receiver_character,
                        receiver_character_state
                    );
                    check_and_update_game_state_winner(
                        world, ref store, match_id, player, receiver_character_id, receiver
                    );
                },
                SkillType::Fireball => {
                    attack(
                        world,
                        player_character,
                        player_character_state,
                        skill,
                        receiver_character,
                        receiver_character_state
                    );

                    check_and_update_game_state_winner(
                        world, ref store, match_id, player, receiver_character_id, receiver
                    );
                },
                SkillType::Heal => heal(
                    world,
                    player_character,
                    player_character_state,
                    skill,
                    receiver_character,
                    receiver_character_state
                ),
                SkillType::SpecialMeeleAttack => {
                    attack(
                        world,
                        player_character,
                        player_character_state,
                        skill,
                        receiver_character,
                        receiver_character_state
                    );
                    check_and_update_game_state_winner(
                        world, ref store, match_id, player, receiver_character_id, receiver
                    );
                },
                SkillType::SpecialRangeAttack => {
                    attack(
                        world,
                        player_character,
                        player_character_state,
                        skill,
                        receiver_character,
                        receiver_character_state
                    );
                    check_and_update_game_state_winner(
                        world, ref store, match_id, player, receiver_character_id, receiver
                    );
                },
            }

            // character can do the action, so we have to save that
            let action_state = ActionStateTrait::new(
                match_id, player_character_id, player, true, last_action_state.movement
            );
            store.set_action_state(action_state);
        }
    }

    fn check_and_update_game_state_winner(
        world: IWorldDispatcher,
        ref store: Store,
        match_id: u32,
        attacker: felt252,
        receiver_character_id: u32,
        receiver: felt252
    ) {
        let receiver_state = store.get_character_state(match_id, receiver_character_id, receiver);

        if receiver_state.remain_hp.is_zero() {
            let mut match_player_characters_len = store
                .get_match_player_characters_len(match_id, receiver);
            if match_player_characters_len.remain_characters == 1 {
                match_player_characters_len.remain_characters = 0;
                store.set_match_player_character_len(match_player_characters_len);

                // Set attacker as winner
                let mut match_state = store.get_match_state(match_id);
                match_state.winner = attacker;
                store.set_match_state(match_state);
                stadistics_system::record_match_stadistics(world, match_id);
            } else {
                match_player_characters_len.remain_characters -= 1;
                store.set_match_player_character_len(match_player_characters_len);
            }
        }
    }

    fn attack(
        world: IWorldDispatcher,
        attacker: Character,
        attacker_state: CharacterState,
        skill: Skill,
        receiver: Character,
        receiver_state: CharacterState
    ) {
        assert(attacker_state.player != receiver_state.player, 'Cannot attack yourself');
        assert(attacker_state.remain_mp >= skill.mp_cost, 'out of mana to cast that skill');
        assert(receiver_state.remain_hp > 0, 'Character already dead');

        let distance_to = distance(
            (attacker_state.x, attacker_state.y), (receiver_state.x, receiver_state.y)
        );
        assert(distance_to <= skill.range, 'character cannot attk that far');

        // Check if the receiver evades the attack
        let mut randomizer = RandomImpl::new(world);
        randomizer.next_seed();
        let receiver_evade_attack = randomizer.between::<u64>(0, 100) < receiver.evasion;

        if !receiver_evade_attack {
            let mut receiver_state = receiver_state;
            let mut damage = attacker.attack + skill.power;

            randomizer.next_seed();
            let attacker_crit_attack = randomizer.between::<u64>(0, 100) < attacker.crit_chance;

            if attacker_crit_attack {
                damage = damage * attacker.crit_rate;
            }

            receiver_state
                .remain_hp =
                    if receiver_state.remain_hp < damage {
                        0
                    } else {
                        receiver_state.remain_hp - damage
                    };
            set!(world, (receiver_state));
        }
    }

    fn heal(
        world: IWorldDispatcher,
        player_character: Character,
        player_character_state: CharacterState,
        skill: Skill,
        receiver: Character,
        receiver_state: CharacterState
    ) {
        assert(player_character_state.player == receiver_state.player, 'cannot heal an enemy');
        assert(player_character_state.remain_mp >= skill.mp_cost, 'out of mana to cast that skill');
        assert(receiver_state.remain_hp > 0, 'character already dead');

        let distance_to = distance(
            (player_character_state.x, player_character_state.y),
            (receiver_state.x, receiver_state.y)
        );
        assert(distance_to <= skill.range, 'character cannot heal that far');

        let mut receiver_state = receiver_state;
        receiver_state
            .remain_hp =
                if receiver.hp < receiver_state.remain_hp + skill.power {
                    receiver.hp
                } else {
                    receiver_state.remain_hp + skill.power
                };

        set!(world, (receiver_state));
    }

    fn distance(from: (u64, u64), to: (u64, u64)) -> u64 {
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
