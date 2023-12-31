#include "draw.hpp"


Draw::Draw(sf::RenderWindow *w){
    Draw::window = w;
}

void Draw::renderPrey(int x, int y){
    sf::CircleShape sprite(50);
    sprite.scale(sf::Vector2f(0.1f,0.1f));
    sf::Color prey_color = sf::Color::Green;
    sprite.setFillColor( prey_color );
    // Local to global
    float center = (Config::SCREEN_WIDTH/Config::WORLD_DIMENSION)*0.5;
    float x_f = (Config::SCREEN_WIDTH/Config::WORLD_DIMENSION)*x + center;
    float y_f = (Config::SCREEN_HEIGHT/Config::WORLD_DIMENSION)*y + center;
    sprite.setPosition( sf::Vector2f( x_f, y_f ) );
    Draw::window->draw(sprite);
}

void Draw::renderPredator(int x, int y){
    sf::CircleShape sprite(50);
    sprite.scale(sf::Vector2f(0.2f,0.2f));
    sf::Color prey_color = sf::Color::Red;
    sprite.setFillColor( prey_color );
    // Local to global
    float center = (Config::SCREEN_WIDTH/Config::WORLD_DIMENSION)*0.5;
    float x_f = (Config::SCREEN_WIDTH/Config::WORLD_DIMENSION)*x + center;
    float y_f = (Config::SCREEN_HEIGHT/Config::WORLD_DIMENSION)*y + center;
    sprite.setPosition( sf::Vector2f( x_f, y_f ) );
    Draw::window->draw(sprite);
}

void Draw::renderGrid(int size_x, int size_y){
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
    for (int i = 0; i < 2*(num_lines); i++){ // Color
        grid[i].color = sf::Color(169,169,169);
    } 
    Draw::window->draw(grid);
}


void Draw::render(Agent* world){
    int size = Config::WORLD_DIMENSION*Config::WORLD_DIMENSION;
    renderGrid(Config::WORLD_DIMENSION, Config::WORLD_DIMENSION);

    for (int i = 0; i < size; i++){
        switch (world[i].cell_type){
        case PREY:
            renderPrey( i%Config::WORLD_DIMENSION , i/Config::WORLD_DIMENSION );
            break;
        case PREDATOR:
            renderPredator( i%Config::WORLD_DIMENSION , i/Config::WORLD_DIMENSION );
            break;
        }
    }
}