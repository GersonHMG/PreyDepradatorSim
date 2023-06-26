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
        sf::Font font;
        void drawStates(sf::RenderWindow *window);
        void drawGrid(sf::RenderWindow *window);
    public:
        World();
        void process();
        void spawnPrey(Vector2 pos);  
        void render(sf::RenderWindow *window);
        int dimension_x;
        int dimension_y;
};