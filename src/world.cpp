#include "world.hpp"


World::World(){
    World::dimension_x = Config::WORLD_DIMENSION; 
    World::dimension_y = Config::WORLD_DIMENSION;

    // Generate world
    world = (Agent*) malloc( sizeof(Agent)*dimension_x*dimension_y );
    for (int i = 0; i < dimension_x*dimension_y ; i++){
        // Initialize 
        world[i].cell_type = EMPTY;
    } 

    // Spawn preys
    int n_preys = 50;
    for (int i = 0; i < n_preys ; i++){
        int random_coord = rand()%(dimension_x*dimension_y);
        // Initialize 
        world[random_coord].cell_type = PREY;
        world[random_coord].t_reproduce = 0;
    }

    int n_predator = 3;
    for (int i = 0; i < n_predator ; i++){
        int random_coord = rand()%(dimension_x*dimension_y);
        // Initialize 
        world[random_coord] = { PREDATOR, 0, 500 };
        
    }
}

void World::process(){
    // For each cell
    for (int i = 0; i < dimension_x*dimension_y; i++){
        Vector2 from = {i%dimension_x, i/dimension_x };
        switch (world[i].cell_type){
            case PREDATOR:
                processPredator(world, &world[i],  from);
                //moveAgent(world, world[i], from, randomCell(from.x, from.y) );
                break;
            case PREY:
                processPrey(world, &world[i],  from);
                //moveAgent(world, world[i], from, randomCell(from.x, from.y) );
                break;
        }
    }
}


bool World::moveAgent(Agent* world, Agent agent, Vector2 from, Vector2 to){
    if(world[ to.x + to.y*dimension_x ].cell_type == EMPTY){
        // Copy
        world[ to.x + to.y*dimension_x ] = world[ from.x + from.y*dimension_x ];
        // Delete
        world[ from.x + from.y*dimension_x ].cell_type = EMPTY;
        return true;
    }
    return false;
}




Agent* World::getWorld(){
    return world;
}
