#include "agent.hpp"
#include "config.hpp"

Vector2 randomCell(int x, int y){
    int world_size = Config::WORLD_DIMENSION;
    x += rand()%(3) - 1;
    y += rand()%(3) - 1;
    
    x = mod(x,  world_size  );
    y = mod(y,  world_size );

    return Vector2{x,y};
}

void moveAgent(Agent* world, Agent agent, Vector2 from, Vector2 to){
    int dimension_x = Config::WORLD_DIMENSION;
    if(world[ to.x + to.y*dimension_x ].cell_type == EMPTY){
        // Copy
        world[ to.x + to.y*dimension_x ] = world[ from.x + from.y*dimension_x ];
        // Delete
        world[ from.x + from.y*dimension_x ].cell_type = EMPTY;

    }

}
void processPrey(Agent* world, Agent* prey, Vector2 pos){
    prey->t_reproduce += 1;
    if(prey->t_reproduce > 200){
        prey->t_reproduce = 0;
        Agent new_prey = {PREY, 0, 0};
        spawnAgent( world , new_prey, randomCell(pos.x, pos.y) );
    }
    Vector2 to = randomCell(pos.x, pos.y);
    moveAgent(world, *prey, pos, to);
}
void processPredator(Agent* world, Agent* predator, Vector2 pos){
    predator->t_reproduce += 1;
    predator->hungry -=1;
    if(predator->hungry <= 0){
        predator->cell_type = EMPTY;
        predator->t_reproduce = 0;
        predator->hungry = 0;

    }
    if(predator->t_reproduce > 260 && predator->hungry > 200){
        predator->t_reproduce = 0;
        Agent new_predator = {PREDATOR, 0, 500};
        spawnAgent( world , new_predator, randomCell(pos.x, pos.y) );
    }

    Vector2 to = randomCell(pos.x, pos.y);
    int dimension_x = Config::WORLD_DIMENSION;
    moveAgent(world, *predator, pos, to);
    if (world[ to.x + to.y*dimension_x ].cell_type == PREY){
         world[ to.x + to.y*dimension_x ] = {EMPTY, 0, 0};
         predator->hungry = 500;
    }

    
}


bool spawnAgent(Agent* world, Agent new_agent, Vector2 to){
    int dimension_x = Config::WORLD_DIMENSION;
    if(world[ to.x + to.y*dimension_x ].cell_type == EMPTY){
        world[ to.x + to.y*dimension_x ] = new_agent;
        return true;
    }
    return false;
}