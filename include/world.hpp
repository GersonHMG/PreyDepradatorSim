#pragma once

#include "prey.hpp"
#include "config.hpp"


class Prey;

class World{
    private:
        int* world;
        int n_preys;
        Prey* preys;
        // Render functions
    public:
        World();
        void process();
        void spawnPrey(Vector2 pos);  
        int dimension_x;
        int dimension_y;
        Vector2* getPreysPos();
        int getNPreys();
};