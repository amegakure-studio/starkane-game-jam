use starkane::constants;

#[derive(Model, Copy, Drop, Serde)]
struct Map {
    #[key]
    id: u32,
    width: u128,
    height: u128,
}

#[derive(Model, Copy, Drop, Serde)]
struct Tile {
    #[key]
    map_id: u32,
    #[key]
    id: u32,
    walkable: bool,
    terrain_type: u8
}

#[derive(Serde, Copy, Drop, PartialEq)]
enum TerrainType {
    Grass,
    Build,
    Water,
    Montain,
}

const DEFAULT_MAP_WIDTH: u128 = 25;
const DEFAULT_MAP_HEIGHT: u128 = 25;

trait MapTrait {
    fn new(id: u32) -> (Map, Array<Tile>);
    fn is_inside(position: (u128, u128)) -> bool;
}

impl MapImpl of MapTrait {
    fn new(id: u32) -> (Map, Array<Tile>) {
        // if id == 1 
        // Map { id: id, width: DEFAULT_MAP_WIDTH, height: DEFAULT_MAP_HEIGHT }
        create_map_1()
    }

    fn is_inside(position: (u128, u128)) -> bool {
        let (x, y) = position;
        x >= 0 && x < DEFAULT_MAP_WIDTH && y >= 0 && y < DEFAULT_MAP_HEIGHT
    }
}

fn create_map_1() -> (Map, Array<Tile>) {
    let map = Map { id: 1, width: DEFAULT_MAP_WIDTH, height: DEFAULT_MAP_HEIGHT };
    let tiles = create_tiles_by_array(map, constants::MAP_1());
    (map, tiles)
}

fn create_tiles(map: Map) -> Array<Tile> {
    let mut tiles = array![];

    let mut x = 0;
    let mut y = 0;
    loop {
        if y == map.height {
            break;
        }
        let index = (y * map.width) + x;
        // TODO: for now, all tiles are walkeables
        tiles.append(Tile { map_id: map.id, id: index.try_into().unwrap(), walkable: true, terrain_type: TerrainType::Grass.into() });
        x += 1;
        if x == map.width {
            y += 1;
            x = 0;
        }
    };
    tiles
}

fn create_tiles_by_array(map: Map, array: Array<felt252>) -> Array<Tile> {
    let mut tiles = array![];

    let mut index: u32 = 0;
    let len: u32 = (map.height * map.width).try_into().unwrap();
    loop {
        if index == len {
            break;
        }
        let terrain_type: TerrainType = (*array.at(index)).try_into().unwrap();
        // TODO: for now, all tiles are walkeables
        let walkable = true;

        tiles.append(Tile { map_id: map.id, id: index.into(), walkable, terrain_type: terrain_type.into() });
        index += 1;
    };
    tiles
}

impl TerrainTypeIntoU8 of Into<TerrainType, u8> {
    #[inline(always)]
    fn into(self: TerrainType) -> u8 {
        match self {
            TerrainType::Grass => 'G',
            TerrainType::Build => 'B',
            TerrainType::Water => 'W',
            TerrainType::Montain => 'M',
        }
    }
}

impl Felt252TryIntoTerrainType of TryInto<felt252, TerrainType> {
    #[inline(always)]
    fn try_into(self: felt252) -> Option<TerrainType> {
        if self == 'G' {
            Option::Some(TerrainType::Grass)
        } else if self == 'B' {
            Option::Some(TerrainType::Build)
        } else if self == 'W' {
            Option::Some(TerrainType::Water)
        } else if self == 'M' {
            Option::Some(TerrainType::Montain)
        } else {
            Option::None(())
        }
    }
}