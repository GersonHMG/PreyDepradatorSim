#include <SFML/Graphics.hpp>
#include <iostream>
#include "config.hpp"
#include "world_aos.cuh"
#include "world_shared.cuh"
#include "world_cpu.cuh"

void renderGrid(sf::RenderWindow* window, int size_x, int size_y){
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

void renderPrey(sf::RenderWindow* window, int x, int y){
    sf::CircleShape sprite(50, 4);
    sprite.rotate(45);
    sprite.scale(sf::Vector2f(0.1f,0.1f));
    sf::Color prey_color = sf::Color::Green;
    sprite.setFillColor( prey_color );
    // Local to global
    float center = (SCREEN_WIDTH/WORLD_DIMENSION)*0.5;
    float x_f = (SCREEN_WIDTH/WORLD_DIMENSION)*x + center;
    float y_f = (SCREEN_HEIGHT/WORLD_DIMENSION)*y + center;
    sprite.setPosition( sf::Vector2f( x_f, y_f ) );
    window->draw(sprite);
}

void renderPredator(sf::RenderWindow* window, int x, int y){
    sf::CircleShape sprite(50, 4);
    sprite.rotate(45);
    sprite.scale(sf::Vector2f(0.1f,0.1f));
    sf::Color prey_color = sf::Color::Red;
    sprite.setFillColor( prey_color );
    // Local to global
    float center = (SCREEN_WIDTH/WORLD_DIMENSION)*0.5;
    float x_f = (SCREEN_WIDTH/WORLD_DIMENSION)*x + center;
    float y_f = (SCREEN_HEIGHT/WORLD_DIMENSION)*y + center;
    sprite.setPosition( sf::Vector2f( x_f, y_f ) );
    window->draw(sprite);
}

void render(Agent* world, sf::RenderWindow* window){
    int size = WORLD_DIMENSION*WORLD_DIMENSION;
    renderGrid(window, WORLD_DIMENSION,WORLD_DIMENSION);

    for (int i = 0; i < size; i++){
        switch (world[i].cell_type){
        case PREY:
            renderPrey(window, i%WORLD_DIMENSION , i/WORLD_DIMENSION );
            break;
        case PREDATOR:
            renderPredator(window, i%WORLD_DIMENSION , i/WORLD_DIMENSION );
            break;
        }
    }
}

void mainLoop(){
    sf::RenderWindow WINDOW;
    
    WINDOW.create( sf::VideoMode( SCREEN_WIDTH, SCREEN_HEIGHT, 32), "PredatorPrey" );
    WINDOW.setFramerateLimit( 30 );
    CudaWorld::init();
    while (WINDOW.isOpen()) {
        
        sf::Event event;    
        while (WINDOW.pollEvent(event)) {
            if (event.type == sf::Event::Closed) { WINDOW.close(); }
        }
        // Process
        CudaWorld::process();

        // Draw
        WINDOW.clear( sf::Color(105,105,105) );
        
        render( CudaWorld::getWorld() , &WINDOW);

        WINDOW.display();
    }
     CudaWorld::end();
}

void testCudaWorld(){

    float time;
    cudaEvent_t start, stop;
    CudaWorld::init();

    cudaEventCreate(&start) ;
    cudaEventCreate(&stop) ;
    cudaEventRecord(start, 0) ;

    for(int i = 0; i < 5000; i++){
        CudaWorld::process();
    }

    cudaEventRecord(stop, 0) ;
    cudaEventSynchronize(stop) ;
    cudaEventElapsedTime(&time, start, stop) ;

    printf("Time to generate:  %3.1f ms \n", time);
}


void testCudaWorldShared(){

    float time;
    cudaEvent_t start, stop;
    CudaWorldShared::init();

    cudaEventCreate(&start) ;
    cudaEventCreate(&stop) ;
    cudaEventRecord(start, 0) ;

    for(int i = 0; i < 5000; i++){
        CudaWorldShared::process();
    }

    cudaEventRecord(stop, 0) ;
    cudaEventSynchronize(stop) ;
    cudaEventElapsedTime(&time, start, stop) ;

    printf("Time to generate:  %3.1f ms \n", time);
}


void testCPUWorld(){

    CPUWorld::init();
    clock_t t;
    t = clock();

    for(int i = 0; i < 5000; i++){
        CPUWorld::process();
    }

    
    t = clock() - t;
    double time_taken = ((double)t); // in seconds

    
    printf("CPU %f [ms] \n", time_taken);
    CPUWorld::end();
}


void test(int version){
    switch (version){
    case 0:
        testCudaWorld();
        break;
    case 1:
        testCudaWorldShared();
        break;
    case 2:
        testCPUWorld();
        break;

    }

}



int main(){
    std::cout<< "Running..." << std::endl;
    //mainLoop();
    test(0);

    return 0;
}