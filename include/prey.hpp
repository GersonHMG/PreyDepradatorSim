#pragma once
#include <SFML/Graphics.hpp>
#include <iostream>
#include "config.hpp"
#include "utils.hpp"
#include "world.hpp"

class World;

class Prey{
    private:
        Vector2 pos;
        World *world;
        int reproduce_t; // Reproduce timestep
        void randomWalk();
        void inseminarLogic();
        
        void renderInit();
        sf::CircleShape sprite;
    public:
        Prey( Vector2 spawn_pos , World *world );
        void process(float delta); // Process agent
        void render(sf::RenderWindow *window); // Visualize
};


