use starkane::models::entities::character::CharacterType;

#[starknet::interface]
trait ICharacterSystem<TContractState> {
    fn init(self: @TContractState);
    fn mint(self: @TContractState, character_type: CharacterType, owner: felt252, skin_id: u32);
}

#[dojo::contract]
mod character_system {
    use super::ICharacterSystem;
    use starkane::models::data::starkane::CharacterPlayerProgress;
    use starkane::models::entities::character::{Character, CharacterTrait, CharacterType};
    use starkane::store::{Store, StoreTrait};

    #[storage]
    struct Storage {}

    #[external(v0)]
    impl CharacterSystem of ICharacterSystem<ContractState> {
        fn init(self: @ContractState) {
            // [Setup] Datastore
            let world = self.world();
            let mut store: Store = StoreTrait::new(world);

            store.set_character(CharacterTrait::new(CharacterType::Archer));
            store.set_character(CharacterTrait::new(CharacterType::Cleric));
            store.set_character(CharacterTrait::new(CharacterType::Warrior));
            store.set_character(CharacterTrait::new(CharacterType::Pig));
            store.set_character(CharacterTrait::new(CharacterType::Peasant));
        }

        fn mint(self: @ContractState, character_type: CharacterType, owner: felt252, skin_id: u32) {
            // [Setup] Datastore
            let world = self.world();
            let mut store: Store = StoreTrait::new(world);

            assert(owner.is_non_zero(), 'owner cannot be zero');
            assert(
                store.get_character(character_type.into()).character_type != 0,
                'character id doesnt exists'
            );

            // TODO: sending character_type as character_id
            let character_progress = store
                .get_character_player_progress(owner, character_type.into());
            assert(!character_progress.owned, 'ERR: character already owned');

            let character_player_progress = CharacterPlayerProgress {
                owner: owner,
                character_id: character_type.into(),
                skin_id: skin_id,
                owned: true,
                level: 1
            };
            store.set_character_player_progress(character_player_progress);
        }
    }
}
