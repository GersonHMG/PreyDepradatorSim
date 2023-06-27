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

void processPrey(Agent* world, Agent* prey, Vector2 pos){
    prey->t_reproduce += 1;
    if(prey->t_reproduce > 200){
        prey->t_reproduce = 0;
        Agent new_prey = {PREY, 0, 0};
        spawnAgent( world , new_prey, randomCell(pos.x, pos.y) );
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