#pragma once

#include <iostream>

#include "utils.hpp"

enum CELL_TYPE { EMPTY, PREDATOR, PREY };

struct Agent{
    CELL_TYPE cell_type; // 0 empty, 1 predator, 2 prey
    int t_reproduce; //
    int hungry; //predator hungry
};

Vector2 randomCell(int x, int y);

void processPrey(Agent* world, Agent* prey, Vector2 pos);

void processPredator(Agent* world, Agent* prey, Vector2 pos);

bool spawnAgent(Agent* world, Agent new_agent, Vector2 to);

#include "world.hpp"