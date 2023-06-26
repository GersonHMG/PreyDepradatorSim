#include <SFML/Graphics.hpp>
#include <iostream>

#include "config.hpp"
#include "world.hpp"
#include "draw.hpp"

void mainLoop(){
    sf::RenderWindow WINDOW;
    
    WINDOW.create( sf::VideoMode( Config::SCREEN_WIDTH, Config::SCREEN_HEIGHT, 32), "PredatorPrey" );
    WINDOW.setFramerateLimit( Config::FPS );
    World new_world = World();
    Draw draw(&WINDOW);
    while (WINDOW.isOpen()) {
        
        sf::Event event;    
        while (WINDOW.pollEvent(event)) {
            if (event.type == sf::Event::Closed) { WINDOW.close(); }
        }
        // Process
        new_world.process();
        
        // Draw
        WINDOW.clear( sf::Color(105,105,105) );
        draw.render( new_world.getPreysPos(), new_world.getNPreys() );

        WINDOW.display();
    }
}


int main(){
    std::cout<< "Running..." << std::endl;
    mainLoop();
    return 0;
}