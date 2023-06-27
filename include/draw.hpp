#pragma once
#include <SFML/Graphics.hpp>
#include "config.hpp"
#include "utils.hpp"
#include "agent.hpp"

class Draw{
    private:
        sf::RenderWindow* window;
        void renderPrey(int x, int y);
        void renderPredator(int x, int y);
        void renderGrid(int size_x, int size_y);
        void renderState();
    public:
        Draw(sf::RenderWindow *w);
        void render(Agent* world);
};