mod constants;
mod store;

mod models {
    mod entities {
        mod character;
        mod map;
        mod skill;
    }
    mod data {
        mod starkane;
    }
    mod states {
        mod character_state;
        mod match_state;
    }
}

mod systems {
    mod action_system;
    mod character_system;
    mod match_system;
    mod move_system;
    mod skill_system;
    mod map_system;
}

#[cfg(test)]
mod tests {
    mod setup;
    mod test_character_system;
    mod test_skill_system;
    mod test_map_system;
}

