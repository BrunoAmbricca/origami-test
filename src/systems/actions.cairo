use dojo_starter::models::{Direction, Position};

// define the interface
#[starknet::interface]
trait IActions<T> {
    fn spawn(ref self: T);
    fn move(ref self: T);
}

// dojo decorator
#[dojo::contract]
pub mod actions {
    use super::{IActions, Direction, Position, next_position};
    use starknet::{ContractAddress, get_caller_address};
    use dojo_starter::models::{Vec2, Moves, DirectionsAvailable};

    use dojo::model::{ModelStorage, ModelValueStorage};
    use dojo::event::EventStorage;

    use origami_map::map::MapTrait;

    #[derive(Copy, Drop, Serde)]
    #[dojo::event]
    pub struct Moved {
        #[key]
        pub player: ContractAddress,
        pub direction: Direction,
    }

    #[abi(embed_v0)]
    impl ActionsImpl of IActions<ContractState> {
        fn spawn(ref self: ContractState) {
            // Get the default world.
            let mut world = self.world_default();

            // Get the address of the current caller, possibly the player's address.
            let player = get_caller_address();
            // Retrieve the player's current position from the world.
            let position: Position = world.read_model(player);

            // Update the world state with the new data.

            // 1. Move the player's position 10 units in both the x and y direction.
            let new_position = Position {
                player, vec: Vec2 { x: position.vec.x + 10, y: position.vec.y + 10 }
            };

            // Write the new position to the world.
            world.write_model(@new_position);

            // 2. Set the player's remaining moves to 100.
            let moves = Moves {
                player, remaining: 100, last_direction: Direction::None(()), can_move: true
            };

            // Write the new moves to the world.
            world.write_model(@moves);
        }

        // Implementation of the move function for the ContractState struct.
        fn move(ref self: ContractState) {
            
            let width = 5;
            let height = 4;
            let order = 0;
            let seed = 'SEED';
            let maze_map = MapTrait::new_maze(width, height, order, seed);

            println!("MAZE ACA");
            println!("WIDTH: {}", maze_map.width);
            println!("HEIGHT: {}", maze_map.height);
            println!("GRID: {}", maze_map.grid);
        }
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        /// Use the default namespace "dojo_starter". This function is handy since the ByteArray
        /// can't be const.
        fn world_default(self: @ContractState) -> dojo::world::WorldStorage {
            self.world(@"dojo_starter")
        }
    }
}

// Define function like this:
fn next_position(mut position: Position, direction: Direction) -> Position {
    match direction {
        Direction::None => { return position; },
        Direction::Left => { position.vec.x -= 1; },
        Direction::Right => { position.vec.x += 1; },
        Direction::Up => { position.vec.y -= 1; },
        Direction::Down => { position.vec.y += 1; },
    };
    position
}
