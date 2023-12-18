use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

#[starknet::interface]
trait IActionSystem<TContractState> {
    fn action(
        self: @TContractState,
        world: IWorldDispatcher,
        match_id: u32,
        player: felt252,
        player_character_id: u32,
        skill_id: u32,
        level: u32,
        receiver: felt252,
        receiver_character_id: u32
    );
}

#[starknet::contract]
mod action_system {
    use super::IActionSystem;

    use starkane::models::entities::character::{Character, CharacterTrait};
    use starkane::models::entities::skill::{
        Skill, SkillType, SkillTypeIntoU8, U8TryIntoSkillType
    };
    use starkane::models::states::match_state::MatchState;
    use starkane::models::states::character_state::{CharacterState, ActionState};
    use starkane::store::{Store, StoreTrait};

    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

    use debug::PrintTrait;

    #[storage]
    struct Storage {}

    #[external(v0)]
    impl ActionSystem of IActionSystem<ContractState> {
        // Character -> Character
        fn action(
            self: @ContractState,
            world: IWorldDispatcher,
            match_id: u32,
            player: felt252,
            player_character_id: u32,
            skill_id: u32,
            level: u32,
            receiver: felt252,
            receiver_character_id: u32
        ) {
            // [Setup] Datastore
            let mut store: Store = StoreTrait::new(world);

            let match_state = store.get_match_state(match_id);

            let action_key = (match_id, player_character_id, player);
            let last_action_state = get!(world, action_key, (ActionState));
            assert(!last_action_state.action, 'already do action in this turn');

            let player_character = store.get_character(player_character_id);
            let mut player_character_state = store
                .get_character_state(match_state, player_character_id, player);

            let receiver_character = store.get_character(receiver_character_id);
            let receiver_character_state = store
                .get_character_state(match_state, receiver_character_id, receiver);

            // obtener skill
            let skill = store.get_skill(player_character_id, skill_id, level);

            // fijarse que tenga el skill el que ataca
            'antes skilltpye'.print();
            skill.skill_type.print();
            let skill_type: SkillType = skill.skill_type.try_into().unwrap();
            'me re pego'.print();

            match skill_type {
                SkillType::MeeleAttack => attack(
                    world,
                    player_character,
                    player_character_state,
                    skill,
                    receiver_character,
                    receiver_character_state
                ),
                SkillType::RangeAttack => attack(
                    world,
                    player_character,
                    player_character_state,
                    skill,
                    receiver_character,
                    receiver_character_state
                ),
                SkillType::Fireball => attack(
                    world,
                    player_character,
                    player_character_state,
                    skill,
                    receiver_character,
                    receiver_character_state
                ),
                SkillType::Heal => heal(
                    world,
                    player_character,
                    player_character_state,
                    skill,
                    receiver_character,
                    receiver_character_state
                )
            }

            // character can do the action, so we have to save that

            let action_state = ActionState {
                match_id,
                character_id: player_character_id,
                player,
                action: true,
                movement: last_action_state.movement
            };
            set!(world, (action_state));
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

        let mut receiver_state = receiver_state;
        receiver_state
            .remain_hp =
                if receiver_state.remain_hp < (attacker.attack + skill.power) {
                    0
                } else {
                    receiver_state.remain_hp - (attacker.attack + skill.power)
                };
        // TODO: revisar
        set!(world, (receiver_state));
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
