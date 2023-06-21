#pragma once
#include <SFML/Graphics.hpp>
#include "config.hpp"
#include "utils.hpp"
#include "world.hpp"

namespace World{
    void spawnPrey(Vector2 pos);
};

class Prey{
    private:
        sf::CircleShape sprite;
        Vector2 pos;
        int reproduce_t; // Reproduce timestep
        void randomWalk();
        void inseminarLogic();
    public:
        Prey( Vector2 spawn_pos );
        void process(float delta); // Process agent
        void render(sf::RenderWindow *window); // Visualize
        void kill();
};


Prey::Prey( Vector2 spawn_pos ){
    // Physic config
    Prey::pos = spawn_pos;

    Prey::reproduce_t = 0;

    // Render config
    Prey::sprite = sf::CircleShape(50);
    Prey::sprite.scale(sf::Vector2f(0.2f,0.2f));
    sf::Color prey_color = sf::Color::Green;
    prey_color.a = 100; // Transparency
    Prey::sprite.setFillColor( prey_color );
}


void Prey::process(float delta){
    Prey::randomWalk();
    Prey::inseminarLogic();
}

void Prey::kill(){
    
}


void Prey::inseminarLogic(){
    reproduce_t += 1;
    if(reproduce_t > 150){
        // Inseminar otros individuos
        reproduce_t = 0;
        // Multiply
        int range = 10;
        Vector2 random_pos = { Prey::pos.x + (rand()%2 - 1)*range, Prey::pos.y + (rand()%2 - 1)*range};
        World::spawnPrey( random_pos );
    }
}


void Prey::randomWalk(){
    Prey::pos.x += (float)rand()/RAND_MAX*2-1;
    Prey::pos.y +=  (float)rand()/RAND_MAX*2-1;
    Prey::pos.x = fmod(Prey::pos.x, Config::SCREEN_WIDTH);
    Prey::pos.y = fmod(Prey::pos.y, Config::SCREEN_WIDTH);
}


void Prey::render(sf::RenderWindow *window){
    Prey::sprite.setPosition( sf::Vector2f(pos.x, pos.y) );
    window->draw(sprite);
}


