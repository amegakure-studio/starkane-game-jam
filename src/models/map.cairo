#[derive(Model, Copy, Drop, Serde)]
struct Map {
    #[key]
    key: u32,
    id: u32,
    width: u128,
    height: u128,
}

#[derive(Model, Copy, Drop, Serde)]
struct Tile {
    #[key]
    map_id: u32,
    #[key]
    key: u32,
    position: Position,
    walkable: bool,
}

#[derive(Model, Copy, Drop, Serde)]
struct Position {
    #[key]
    key: u32,
    x: u128,
    y: u128,
    index: u128,
}

const DEFAULT_MAP_WIDTH: u128 = 30;
const DEFAULT_MAP_HEIGHT: u128 = 30;

trait MapTrait {
    fn new(key: u32, id: u32) -> Map;
}

impl MapImpl of MapTrait {
    fn new(key: u32, id: u32) -> Map {
        Map {
            key: key,
            id: id,
            width: DEFAULT_MAP_WIDTH,
            height: DEFAULT_MAP_HEIGHT
        }
    }
}

fn create_tiles(map: Map) -> Array<Tile> {
    let mut tiles = array![];

    let mut i = 0;
    let mut j = 0;
    loop {
        if j == map.height {
            break;
        }
        let index =  (j * map.width) + i;
        let position = Position { key: index.try_into().unwrap(), x: i, y: j, index: index };
        // TODO: for now, all tiles are walkeables
        tiles.append(Tile { map_id: map.id, key: position.key, position: position, walkable: true });
        i += 1;
        if i == map.width {
            j += 1;
            i = 0;
        }
    };
    tiles
}
