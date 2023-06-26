#pragma once
#include <iostream>
#include "config.hpp"
#include "utils.hpp"
#include "world.hpp"

class World;

class Prey{
    private:
        
        World *world;
        int reproduce_t; // Reproduce timestep
        void randomWalk();
        void inseminarLogic();
    public:
        Vector2 pos;
        Prey( Vector2 spawn_pos , World *world );
        void process(float delta); // Process agent
};


