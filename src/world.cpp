#include "world.hpp"


World::World(){
    World::dimension_x = Config::WORLD_DIMENSION; 
    World::dimension_y = Config::WORLD_DIMENSION;

    // Generate world
    world = (int*) malloc( sizeof(int)*dimension_x*dimension_y );
    for (int i = 0; i < dimension_x*dimension_y ; i++){
        world[i] = 0;
    } 

    // Spawn preys
    n_preys = 1;
    preys = (Prey*) malloc( sizeof(Prey)*n_preys );
    new ( &preys[0] ) Prey(Vector2{50,50}, this);

    // Init render
    font.loadFromFile("../res/font.ttf");
}


void World::process(){
    for (int i = 0; i < World::n_preys; i++){
        preys[i].process(0);
    }
} 


void World::spawnPrey(Vector2 pos){
    World::preys = (Prey*) realloc(World::preys, sizeof(Prey)*(World::n_preys + 1) );
    new ( &preys[World::n_preys] ) Prey(pos, this);
    n_preys += 1;
}


// Render functions
void World::drawGrid(sf::RenderWindow *window){
    int size_x = World::dimension_x;
    int size_y = World::dimension_y;
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
    window->draw(grid);
}

void World::render(sf::RenderWindow *window){
    drawGrid(window);
    for (int i = 0; i < n_preys; i++){
        preys[i].render(window);
    }
    drawStates(window);
}

void World::drawStates( sf::RenderWindow *window ){
    std::string s = std::to_string( n_preys );
    sf::Text text("Preys: " + s , font, 30);
    text.setFillColor(sf::Color::White);
    window->draw(text);
}