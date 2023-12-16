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
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

    #[storage]
    struct Storage {}

    #[external(v0)]
    impl Actions of IActions<ContractState> {
        fn initialize(self: @ContractState, world: IWorldDispatcher) {
            let archer = CharacterTrait::new(CharacterType::Archer);
            let cleric = CharacterTrait::new(CharacterType::Cleric);
            let warrior = CharacterTrait::new(CharacterType::Warrior);
            let pig = CharacterTrait::new(CharacterType::Pig);

            set!(world, (archer));
            set!(world, (cleric));
            set!(world, (warrior));
            set!(world, (pig));
        }

        fn mint(
            self: @ContractState,
            world: IWorldDispatcher,
            character_type: CharacterType,
            owner_address: felt252
        ) {
            assert(owner_address.is_non_zero(), 'owner cannot be zero');
            // assert(CharacterTrait::character_exists(character_type.into()), 'character id doesnt exists');
            assert(
                !self.has_character_owned(world, character_type.into(), owner_address),
                'character already owned'
            );

            set!(
                world,
                (CharacterPlayerProgress {
                    owner: owner_address, character_id: character_type.into(), owned: true, level: 1
                })
            );
        }

        fn has_character_owned(
            self: @ContractState,
            world: IWorldDispatcher,
            character_type: CharacterType,
            player_address: felt252
        ) -> bool {
            let character_id: u32 = character_type.into();
            let character_owned_key = (character_id, player_address);
            get!(world, character_owned_key.into(), (CharacterPlayerProgress)).owned
        }
    }
}
