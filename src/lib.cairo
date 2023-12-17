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
    mod attack;
    mod character_system;
    mod match_factory;
    mod move;
    mod skill_system;
}

#[cfg(test)]
mod tests {
    mod setup;
    mod test_character_system;
    mod test_skill_system;
}

