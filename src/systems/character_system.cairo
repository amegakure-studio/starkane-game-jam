use starkane::models::entities::character::CharacterType;

#[starknet::interface]
trait ICharacterSystem<TContractState> {
    fn init(self: @TContractState);
    fn mint(self: @TContractState, character_type: CharacterType, owner: felt252, skin_id: u32);
    fn mint_recommendation(self: @TContractState, owner: felt252);
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

            let mut player_stadistics = store.get_player_stadistics(owner);
            player_stadistics.characters_owned += 1;

            store.set_player_stadistics(player_stadistics);
            store.set_character_player_progress(character_player_progress);
        }


        fn mint_recommendation(self: @ContractState, owner: felt252) {
            // [Setup] Datastore
            let world = self.world();
            let mut store: Store = StoreTrait::new(world);

            assert(owner.is_non_zero(), 'owner cannot be zero');

            // Check if owner has enough recommendations
            let player_stadistics = store.get_player_stadistics(owner);
            assert(player_stadistics.recommendation_score >= 15, 'you need 15 recommendations');

            let character_progress = store
                .get_character_player_progress(owner, CharacterType::Cleric.into());
            assert(!character_progress.owned, 'ERR: character already owned');

            let character_player_progress = CharacterPlayerProgress {
                owner: owner,
                character_id: CharacterType::Cleric.into(),
                skin_id: 1,
                owned: true,
                level: 1
            };

            let mut player_stadistics = store.get_player_stadistics(owner);
            player_stadistics.characters_owned += 1;

            store.set_player_stadistics(player_stadistics);
            store.set_character_player_progress(character_player_progress);
        }
    }
}
