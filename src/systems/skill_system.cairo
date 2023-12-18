use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

#[starknet::interface]
trait ISkillSystem<TContractState> {
    fn init(self: @TContractState, world: IWorldDispatcher);
    fn has_skill(
        self: @TContractState,
        world: IWorldDispatcher,
        character_id: u32,
        player: felt252,
        skill_id: u32
    ) -> bool;
    fn can_use_skill(
        self: @TContractState,
        world: IWorldDispatcher,
        character_id: u32,
        player: felt252,
        skill_id: u32,
        level: u32
    ) -> bool;
}

#[starknet::contract]
mod skill_system {
    use super::ISkillSystem;
    use starkane::models::entities::character::{Character, CharacterType};
    use starkane::models::entities::skill::{Skill, SkillTrait, SkillType};
    use starkane::store::{Store, StoreTrait};
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

    #[storage]
    struct Storage {}

    #[external(v0)]
    impl SkillSystem of ISkillSystem<ContractState> {
        fn init(self: @ContractState, world: IWorldDispatcher) {
            // [Setup] Datastore
            let mut store: Store = StoreTrait::new(world);

            // [Skill] MeeleAttack
            store
                .set_skill(
                    SkillTrait::new(SkillType::MeeleAttack, CharacterType::Warrior.into(), 1)
                );
            store
                .set_skill(
                    SkillTrait::new(SkillType::MeeleAttack, CharacterType::Cleric.into(), 1)
                );
            store.set_skill(SkillTrait::new(SkillType::MeeleAttack, CharacterType::Pig.into(), 1));

            // [Skill] RangeAttack
            store
                .set_skill(
                    SkillTrait::new(SkillType::RangeAttack, CharacterType::Archer.into(), 1)
                );

            // Currently we dont have a Sorcerer
            // [Skill] Fireball
            // store.set_skill(SkillTrait::new(SkillType::Fireball, CharacterType::Sorcerer.into(), 1));
            // store.set_skill(SkillTrait::new(SkillType::Fireball, CharacterType::Sorcerer.into(), 2));
            // store.set_skill(SkillTrait::new(SkillType::Fireball, CharacterType::Sorcerer.into(), 3));

            // [Skill] Heal
            store.set_skill(SkillTrait::new(SkillType::Heal, CharacterType::Cleric.into(), 1));
            store.set_skill(SkillTrait::new(SkillType::Heal, CharacterType::Cleric.into(), 2));
            store.set_skill(SkillTrait::new(SkillType::Heal, CharacterType::Cleric.into(), 3));
        }

        fn has_skill(
            self: @ContractState,
            world: IWorldDispatcher,
            character_id: u32,
            player: felt252,
            skill_id: u32
        ) -> bool {
            // TODO: Not implemented
            true
        }

        fn can_use_skill(
            self: @ContractState,
            world: IWorldDispatcher,
            character_id: u32,
            player: felt252,
            skill_id: u32,
            level: u32
        ) -> bool {
            // TODO: Not implemented
            true
        }
    }
}
