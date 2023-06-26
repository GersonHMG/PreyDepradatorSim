#include "prey.hpp"

Prey::Prey( Vector2 spawn_pos, World *world ){
    // Physic config
    Prey::pos = spawn_pos;
    Prey::world = world;
    Prey::reproduce_t = 0;
}

void Prey::process(float delta){
    Prey::randomWalk();
    Prey::inseminarLogic();
}

void Prey::inseminarLogic(){
    reproduce_t += 1;
    if(reproduce_t > 150){
        // Inseminar otros individuos
        reproduce_t = 0;
        // Multiply
        int range = 10;
        Vector2 random_pos = { Prey::pos.x + (rand()%2 - 1)*range, Prey::pos.y + (rand()%2 - 1)*range};

        
        world->spawnPrey( random_pos );
    }
}


void Prey::randomWalk(){
    Prey::pos.x += rand()%(3) - 1;
    Prey::pos.y += rand()%(3) - 1;
    
    Prey::pos.x = mod( Prey::pos.x, (Prey::world->dimension_x) );
    Prey::pos.y = mod( Prey::pos.y, (Prey::world->dimension_y) );
}