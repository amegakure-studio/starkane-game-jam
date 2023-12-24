use cc_starknet::utils::pack::{Pack, PackTrait};
use starknet::ContractAddress;

#[derive(Model, Copy, Drop, Serde)]
struct MapCC {
    #[key]
    id: u32,
    token_id: u64,
    size: u8,
    obstacles_1: felt252,
    obstacles_2: felt252,
    obstacles_3: felt252,
    owner: felt252,
    width: u64,
    height: u64,
}

trait MapCCTrait {
    fn is_inside(self: MapCC, position: (u64, u64)) -> bool;
    fn is_walkable(self: MapCC, position: (u64, u64)) -> bool;
    fn get_value(self: MapCC, position: (u64, u64)) -> ByteArray;
}

impl MapCCImpl of MapCCTrait {
    fn is_inside(self: MapCC, position: (u64, u64)) -> bool {
        let (x, y) = position;
        x >= 0 && x < self.width && y >= 0 && y < self.height
    }

    fn is_walkable(self: MapCC, position: (u64, u64)) -> bool {
        let mut pack = Pack {
            first: self.obstacles_1, second: self.obstacles_2, third: self.obstacles_3
        };
        let (x, y) = position;
        !PackTrait::get_bit(ref pack, (y * 25 + x).into())
    }

    fn get_value(self: MapCC, position: (u64, u64)) -> ByteArray {
        let mut pack = Pack {
            first: self.obstacles_1, second: self.obstacles_2, third: self.obstacles_3
        };
        let (x, y) = position;
        if PackTrait::get_bit(ref pack, (y * 25 + x).into()) {
            "X"
        } else {
            "_"
        }
    }
}

