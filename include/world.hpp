#pragma once

#include <iostream>

#include "config.hpp"
#include "agent.hpp"

class World{
    private:
        Agent* world;
        // Render functions
    public:
        World();
        void process();
        int dimension_x;
        int dimension_y;
        bool moveAgent(Agent* world, Agent agent, Vector2 from, Vector2 to);
        bool spawnAgent(Agent* world, Agent new_agent, Vector2 to);
        Agent* getWorld();
};