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

    let mut x = 0;
    let mut y = 0;
    loop {
        if y == map.height {
            break;
        }
        let index = (y * map.width) + x;
        // TODO: for now, all tiles are walkeables
        tiles.append(Tile { map_id: map.id, id: index.try_into().unwrap(), walkable: true });
        x += 1;
        if x == map.width {
            y += 1;
            x = 0;
        }
    };
    tiles
}
