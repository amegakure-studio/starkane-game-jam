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
    mod character_manager;
    mod match_factory;
    mod move;
}

#[cfg(test)]
mod tests {
    mod setup;
    mod test_match_factory;
}

