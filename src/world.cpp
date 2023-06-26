#include "world.hpp"


World::World(){
    World::dimension_x = Config::WORLD_DIMENSION; 
    World::dimension_y = Config::WORLD_DIMENSION;

    // Generate world
    world = (int*) malloc( sizeof(int)*dimension_x*dimension_y );
    for (int i = 0; i < dimension_x*dimension_y ; i++){
        world[i] = 0;
    } 

    // Spawn preys
    n_preys = 1;
    preys = (Prey*) malloc( sizeof(Prey)*n_preys );
    new ( &preys[0] ) Prey(Vector2{50,50}, this);
}

void World::process(){
    for (int i = 0; i < World::n_preys; i++){
        preys[i].process(0);
    }
} 

void World::spawnPrey(Vector2 pos){
    World::preys = (Prey*) realloc(World::preys, sizeof(Prey)*(World::n_preys + 1) );
    new ( &preys[World::n_preys] ) Prey(pos, this);
    n_preys += 1;
}

int World::getNPreys(){
    return n_preys;
}

Vector2* World::getPreysPos(){
    Vector2* pos = (Vector2*) malloc( sizeof(Vector2)*n_preys );
    for (int i = 0; i < n_preys; i++){
        pos[i] = Vector2{ preys[i].pos.x, preys[i].pos.y}; 
    }
    return pos;
}

/*
void World::render(sf::RenderWindow *window){
    drawGrid(window);
    for (int i = 0; i < n_preys; i++){
        preys[i].render(window);
    }
    drawStates(window);
}
*/
