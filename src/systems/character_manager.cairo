use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use starkane::models::entities::character::CharacterType;

#[starknet::interface]
trait IActions<TContractState> {
    fn initialize(self: @TContractState, world: IWorldDispatcher);
    fn mint(
        self: @TContractState,
        world: IWorldDispatcher,
        character_type: CharacterType,
        owner: felt252,
        skin_id: u32
    );
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
            owner: felt252,
            skin_id: u32
        ) {
            // [Setup] Datastore
            let mut store: Store = StoreTrait::new(world);

            assert(owner.is_non_zero(), 'owner cannot be zero');
            assert(store.get_character(character_type.into()).character_type != 0, 'character id doesnt exists');

            // TODO: sending character_type as character_id
            let character_progress = store.get_character_player_progress(owner, character_type.into());
            assert(!character_progress.owned, 'ERR: character already owned');

            let character_player_progress = CharacterPlayerProgress {
                owner: owner, character_id: character_type.into(), skin_id: skin_id, owned: true, level: 1
            };
            store.set_character_player_progress(character_player_progress);
        }
    }
}
