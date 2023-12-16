use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

#[starknet::interface]
trait IActions<TContractState> {
    fn attack(
        self: @TContractState,
        world: IWorldDispatcher,
        game_id: u32,
        player_address: felt252,
        attacker_id: u32,
        skill_id: u32,
        receiver_id: u32
    );
}

#[starknet::contract]
mod actions {
    use super::IActions;
    // use core::option::OptionTrait;

    use starkane::models::character::{CharacterOwned, Character, CharacterImpl, CharacterTrait};
    use starkane::models::game::{GameState, CharacterState};
    use starkane::models::skill::{Skill, SkillType, SkillTypeIntoU8, U8TryIntoSkillType};
    use starkane::store::{Store, StoreTrait};

    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

    #[storage]
    struct Storage {}

    #[external(v0)]
    impl Actions of IActions<ContractState> {
        // Character -> Character
        fn attack(
            self: @ContractState,
            world: IWorldDispatcher,
            game_id: u32,
            player_address: felt252,
            attacker_id: u32,
            skill_id: u32,
            receiver_id: u32
        ) {
            // [Setup] Datastore
            let mut store: Store = StoreTrait::new(world);

            // let game_state = get!(world, (game_id), (GameState));
            let game_state = store.get_game_state(game_id);

            let attacker = get!(world, (attacker_id), (Character));
            let attacker_state = get!(
                world, (game_id, attacker_id, game_state.turn), (CharacterState)
            );

            let receiver = get!(world, (receiver_id), (Character));
            let receiver_state = get!(
                world, (game_id, receiver_id, game_state.turn), (CharacterState)
            );

            // obtener skill
            let skill = get!(world, (attacker_id, skill_id), (Skill));

            // fijarse que tenga el skill el que ataca
            let skill_type: SkillType = skill.skill_type.try_into().unwrap();

            match skill_type {
                SkillType::MeeleAttack => attack(
                    world, attacker, attacker_state, skill, receiver, receiver_state
                ),
                SkillType::RangeAttack => attack(
                    world, attacker, attacker_state, skill, receiver, receiver_state
                ),
                SkillType::Fireball => attack(
                    world, attacker, attacker_state, skill, receiver, receiver_state
                ),
                SkillType::Heal => heal(world, attacker_state, skill, receiver, receiver_state)
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
        // save
        set!(world, (receiver_state));
    }

    fn heal(
        world: IWorldDispatcher,
        attacker_state: CharacterState,
        skill: Skill,
        receiver: Character,
        receiver_state: CharacterState
    ) {// si es heal que sea aliado

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
