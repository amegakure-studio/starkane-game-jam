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
    x: u128,
    y: u128,
    walkable: bool,
}

const DEFAULT_MAP_WIDTH: u128 = 30;
const DEFAULT_MAP_HEIGHT: u128 = 30;

trait MapTrait {
    fn new(id: u32) -> Map;
    fn is_inside(position: (u128, u128)) -> bool;
}

impl MapImpl of MapTrait {
    fn new(id: u32) -> Map {
        Map {
            id: id,
            width: DEFAULT_MAP_WIDTH,
            height: DEFAULT_MAP_HEIGHT
        }
    }

    fn is_inside(position: (u128, u128)) -> bool {
        let (x, y) = position; 
        x >= 0 && x < DEFAULT_MAP_WIDTH &&
        y >= 0 && y < DEFAULT_MAP_HEIGHT 
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
        let index = (j * map.width) + i;
        // let position = Position { tile_id: index, id: index, x: i, y: j, index: index };
        // TODO: for now, all tiles are walkeables
        tiles.append(Tile { map_id: map.id, id: index.try_into().unwrap(), x: i, y: j, walkable: true });
        i += 1;
        if i == map.width {
            j += 1;
            i = 0;
        }
    };
    tiles
}
