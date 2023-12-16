use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

#[starknet::interface]
trait IActions<TContractState> {
    fn action(
        self: @TContractState,
        world: IWorldDispatcher,
        match_id: u32,
        player: felt252,
        player_character_id: u32,
        skill_id: u32,
        receiver: felt252,
        receiver_character_id: u32
    );
}

#[starknet::contract]
mod actions {
    use super::IActions;

    //CharacterPlayerProgress
    use starkane::models::entities::character::{Character, CharacterTrait};
    use starkane::models::entities::skill::{
        Skill, SkillType, SkillTypeIntoU8, U8TryIntoSkillType
    };
    use starkane::models::states::match_state::MatchState;
    use starkane::models::states::character_state::CharacterState;
    use starkane::store::{Store, StoreTrait};

    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

    #[storage]
    struct Storage {}

    #[external(v0)]
    impl Actions of IActions<ContractState> {
        // Character -> Character
        fn action(
            self: @ContractState,
            world: IWorldDispatcher,
            match_id: u32,
            player: felt252,
            player_character_id: u32,
            skill_id: u32,
            receiver: felt252,
            receiver_character_id: u32
        ) {
            // [Setup] Datastore
            let mut store: Store = StoreTrait::new(world);

            // let match_state = get!(world, (match_id), (MatchState));
            let match_state = store.get_match_state(match_id);

            let player_character = get!(world, (player_character_id), (Character));
            let player_character_state = get!(
                world, (match_id, player_character_id, player), (CharacterState)
            );

            let receiver_character = get!(world, (receiver_character_id), (Character));
            let receiver_character_state = get!(
                world, (match_id, receiver_character_id, receiver), (CharacterState)
            );

            // obtener skill
            let skill = get!(world, (player_character_id, skill_id), (Skill));

            // fijarse que tenga el skill el que ataca
            let skill_type: SkillType = skill.skill_type.try_into().unwrap();

            match skill_type {
                SkillType::MeeleAttack => attack(
                    world, player_character, player_character_state, skill, receiver_character, receiver_character_state
                ),
                SkillType::RangeAttack => attack(
                    world, player_character, player_character_state, skill, receiver_character, receiver_character_state
                ),
                SkillType::Fireball => attack(
                    world, player_character, player_character_state, skill, receiver_character, receiver_character_state
                ),
                SkillType::Heal => heal(world, player_character_state, skill, receiver_character, receiver_character_state)
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
    ) { // si es heal que sea aliado
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
