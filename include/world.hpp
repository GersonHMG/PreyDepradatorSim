#pragma once

#include "prey.hpp"
#include "config.hpp"


namespace World{

    void drawStates(sf::RenderWindow *window); 
    Vector2 toWorldCoordinates(Vector2 global);

    const int dimension_x = 100; 
    const int dimension_y = 100;
    int* world;
    int N_PREYS = 20;
    Prey* preys;
    sf::Font font;
    
    
    void init(){
        // Generate world
        world = (int*) malloc( sizeof(int)*dimension_x*dimension_y );
        for (int i = 0; i < dimension_x*dimension_y ; i++){
            world[i] = 0;
        } 

        // Spawn preys
        preys = (Prey*) malloc( sizeof(Prey)*N_PREYS );
        for (int i = 0; i < N_PREYS; i++){
            Vector2 random_pos = { rand()%Config::SCREEN_WIDTH , rand()%Config::SCREEN_HEIGHT };
            new (&preys[i]) Prey(random_pos);
            Vector2 local_coord = toWorldCoordinates( random_pos );
            world[ (int) floorf(local_coord.x + local_coord.y*dimension_x) ] += 1;
        } 
        font.loadFromFile("../res/font.ttf");
    }

    Vector2 toWorldCoordinates(Vector2 global){
        return Vector2{ floorf( global.x*(dimension_x/Config::SCREEN_WIDTH) ) , 
        floorf( global.y*(dimension_y/Config::SCREEN_HEIGHT) )};
    }
    
    void spawnPrey(Vector2 pos){
        preys = (Prey*) realloc(preys, sizeof(Prey)*(N_PREYS + 1) );
        new (&preys[N_PREYS]) Prey(pos);
        N_PREYS += 1;
    }


    void drawGrid(sf::RenderWindow *window, int size_x, int size_y){
        int num_lines = size_y + size_x - 2;

        sf::VertexArray grid(sf::Lines, 2*(num_lines));
        window->setView( window->getDefaultView() );
        auto size = window->getView().getSize();
        float rowH = size.y/size_y;
        float colW = size.x/size_x;
        // row separators
        for(int i=0; i < size_y-1; i++){
            int r = i+1;
            float rowY = rowH*r;
            grid[i*2].position = {0, rowY};
            grid[i*2+1].position = {size.x, rowY};
        }
        // column separators
        for(int i=size_y-1; i < num_lines; i++){
            int c = i-size_y+2;
            float colX = colW*c;
            grid[i*2].position = {colX, 0};
            grid[i*2+1].position = {colX, size.y};  
        }

        for (int i = 0; i < 2*(num_lines); i++){
            grid[i].color = sf::Color(169,169,169);
        }
        
        // draw it
        window->draw(grid);
}

    

    void removePrey(){
        
    }


    void process(){
        for (int i = 0; i < N_PREYS; i++){
            preys[i].process(0);
        }
    } 


    void render(sf::RenderWindow *window){
        drawGrid(window, dimension_x, dimension_y);
        for (int i = 0; i < N_PREYS; i++){
            preys[i].render(window);
        }
        drawStates(window);
        
    }

    
    void drawStates( sf::RenderWindow *window ){
        std::string s = std::to_string( N_PREYS );
        sf::Text text("Preys: " + s , font, 30);
        text.setFillColor(sf::Color::White);
        window->draw(text);
    }
    
}



