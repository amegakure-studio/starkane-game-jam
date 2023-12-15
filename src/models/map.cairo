#[derive(Model, Copy, Drop, Serde)]
struct Position {
    #[key]
    key: u32,
    id: u32,
    x: u128,
    y: u128,
    index: u128,
}

#[derive(Model, Copy, Drop, Serde)]
struct Tile {
    #[key]
    map_id: u32,
    #[key]
    key: u32,
    id: u32,
    position: Position,
    walkable: bool,
}

#[derive(Model, Copy, Drop, Serde)]
struct Map {
    #[key]
    key: u32,
    id: u32,
    width: u128,
    height: u128,
}
