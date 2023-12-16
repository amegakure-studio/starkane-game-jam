use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use starkane::models::entities::character::CharacterType;

#[starknet::interface]
trait IActions<TContractState> {
    fn initialize(self: @TContractState, world: IWorldDispatcher);
    fn mint(
        self: @TContractState,
        world: IWorldDispatcher,
        character_type: CharacterType,
        owner_address: felt252
    );
    fn has_character_owned(
        self: @TContractState,
        world: IWorldDispatcher,
        character_type: CharacterType,
        player_address: felt252
    ) -> bool;
}

#[starknet::contract]
mod actions {
    use super::IActions;
    use starkane::models::data::starkane::CharacterPlayerProgress;
    use starkane::models::entities::character::{Character, CharacterTrait, CharacterType};
    use starkane::store::{Store, StoreTrait};
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

    #[storage]
    struct Storage {}

    #[external(v0)]
    impl Actions of IActions<ContractState> {
        fn initialize(self: @ContractState, world: IWorldDispatcher) {
            // [Setup] Datastore
            let mut store: Store = StoreTrait::new(world);

            let archer = CharacterTrait::new(CharacterType::Archer);
            let cleric = CharacterTrait::new(CharacterType::Cleric);
            let warrior = CharacterTrait::new(CharacterType::Warrior);
            let pig = CharacterTrait::new(CharacterType::Pig);

            store.set_character(archer);
            store.set_character(cleric);
            store.set_character(warrior);
            store.set_character(pig);
        }

        fn mint(
            self: @ContractState,
            world: IWorldDispatcher,
            character_type: CharacterType,
            owner_address: felt252
        ) {
            // [Setup] Datastore
            let mut store: Store = StoreTrait::new(world);

            assert(owner_address.is_non_zero(), 'owner cannot be zero');
            // assert(CharacterTrait::character_exists(character_type.into()), 'character id doesnt exists');
            assert(
                !self.has_character_owned(world, character_type.into(), owner_address),
                'character already owned'
            );

            let character_player_progress = CharacterPlayerProgress {
                owner: owner_address, character_id: character_type.into(), owned: true, level: 1
            };
            store.set_character_player_progress(character_player_progress);
        }

        fn has_character_owned(
            self: @ContractState,
            world: IWorldDispatcher,
            character_type: CharacterType,
            player_address: felt252
        ) -> bool {
            let character_id: u32 = character_type.into();
            let character_owned_key = (character_id, player_address);
            // TODO: revisar
            // get!(world, character_owned_key.into(), (CharacterPlayerProgress)).owned
            true
        }
    }
}
