#pragma once
#include <SFML/Graphics.hpp>
#include "config.hpp"
#include "utils.hpp"
#include "agent_aos.cuh"

class Draw{
    private:
        sf::RenderWindow* window;
        void renderPrey(int x, int y);
        void renderPredator(int x, int y);
        void renderGrid(int size_x, int size_y);
    public:
        Draw(sf::RenderWindow *w);
        void render(Agent* world);
};