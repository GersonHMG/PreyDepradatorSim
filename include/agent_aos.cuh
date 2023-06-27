#pragma once

#include <iostream>
#include "config.hpp"
#include "cuda_runtime.h"
#include "utils.hpp"

__device__ int mod(int a, int b) { 
    return (a % b + b) % b; 
}

enum CELL_TYPE { EMPTY, PREDATOR, PREY };

struct Agent{
    CELL_TYPE cell_type; // 0 empty, 1 predator, 2 prey
    int t_reproduce; //
    int hungry; //predator hungry
};

// Return random cell close to position 
__device__ Vector2 randomCell(int x, int y){
    int world_size = WORLD_DIMENSION;
   
    x +=  1;
    y +=  1;
    
    x = mod(x,  world_size );
    y = mod(y,  world_size );

    return Vector2{x,y};
}


__device__ Vector2 preyMovement(Agent* world, int x, int y){
    int world_size = WORLD_DIMENSION;
    
    int action_x = world[ mod(x + 1,  world_size ) ].cell_type%2 - 1;
    int action_y = world[ mod(y - 1,  world_size ) ].cell_type%2 - 1;
    //Look for neighboors
    
    x +=  1*action_x;
    y +=  1*action_y;
    
    x = mod(x,  world_size );
    y = mod(y,  world_size );

    return Vector2{x,y};
}

__device__ bool moveAgent(Agent* world, Agent agent, Vector2 from, Vector2 to){
    int dimension_x = WORLD_DIMENSION;
    if(world[ to.x + to.y*dimension_x ].cell_type == EMPTY){
        // Copy
        world[ to.x + to.y*dimension_x ] = world[ from.x + from.y*dimension_x ];
        // Delete
        world[ from.x + from.y*dimension_x ].cell_type = EMPTY;
    }
}

__device__ bool spawnAgent(Agent* world, Agent new_agent, Vector2 to){
    int dimension_x = WORLD_DIMENSION;
    if(world[ to.x + to.y*dimension_x ].cell_type == EMPTY){
        world[ to.x + to.y*dimension_x ] = new_agent;
        return true;
    }
    return false;
}

__device__ void processPrey(Agent* world, Agent* prey, Vector2 pos){
    prey->t_reproduce += 1;
    if(prey->t_reproduce > 200){
        prey->t_reproduce = 0;
        Agent new_prey = {PREY, 0, 0};
        spawnAgent( world , new_prey, randomCell(pos.x, pos.y) );
    }
    Vector2 to = preyMovement(world, pos.x, pos.y); //randomCell(pos.x, pos.y);
    moveAgent(world, *prey, pos, to);
}


__device__ void processPredator(Agent* world, Agent* prey, Vector2 pos);



