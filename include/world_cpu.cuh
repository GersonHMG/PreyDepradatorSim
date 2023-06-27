#pragma once

#include <iostream>
#include "cuda_runtime.h"
#include "agent_aos.cuh"
#include "config.hpp"

namespace CPUWorld{


Agent* h_old_world;
Agent* h_new_world;


void init(){
    h_old_world = (Agent*) malloc( sizeof(Agent)*WORLD_DIMENSION*WORLD_DIMENSION );
    h_new_world = (Agent*) malloc( sizeof(Agent)*WORLD_DIMENSION*WORLD_DIMENSION );
    printf("Initializing... \n");
    //Init world
    // Generate world
    for (int i = 0; i < WORLD_DIMENSION*WORLD_DIMENSION ; i++){
        // Initialize 
        h_old_world[i].cell_type = EMPTY;
        h_new_world[i].cell_type = EMPTY;
    } 
    
    // Preys
    int n_preys = 20;
    for (int i = 0; i < n_preys ; i++){
        int random_coord = rand()%(WORLD_DIMENSION*WORLD_DIMENSION );
        h_old_world[i].cell_type = PREY;
    }
    
    int offset = 5050;
    h_old_world[offset+ 1].cell_type = PREY;
    h_old_world[offset+ WORLD_DIMENSION + 2].cell_type = PREY;
    h_old_world[offset+ WORLD_DIMENSION*2].cell_type = PREY;
    h_old_world[offset+ WORLD_DIMENSION*2 + 1].cell_type = PREY;
    h_old_world[offset+ WORLD_DIMENSION*2 + 2].cell_type = PREY;

    // Predator
    int n_predator = 100;
    for (int i = 450; i < 450 + n_predator ; i++){
        int random_coord = rand()%(WORLD_DIMENSION*WORLD_DIMENSION );
        // Initialize 
        h_old_world[i].cell_type = PREDATOR;
    }

}

void processCell(Agent* old_world, Agent* new_world, Vector2 cell_pos){
    int neighboors_cells = 0;
    int ad_pred = 0;
    int ad_prey = 0;
    // For each neighboor
    for (int x = -1; x < 2; x++){
        for (int y = -1; y < 2; y++){
            Vector2 ad_cell = { cell_pos.x + x , cell_pos.y + y }; 
            ad_cell.x = mod(ad_cell.x, WORLD_DIMENSION);
            ad_cell.y = mod(ad_cell.y, WORLD_DIMENSION);
            if( (x != 0 || y != 0) &&
                old_world[ad_cell.x + ad_cell.y*WORLD_DIMENSION].cell_type != EMPTY){
                neighboors_cells += 1;
                if( old_world[ad_cell.x + ad_cell.y*WORLD_DIMENSION].cell_type == PREDATOR){
                    ad_pred += 1;
                }else if( old_world[ad_cell.x + ad_cell.y*WORLD_DIMENSION].cell_type == PREY){
                    ad_prey += 1;
                }
            }
        }
    }
    new_world[cell_pos.x + cell_pos.y*WORLD_DIMENSION].cell_type = EMPTY;

    if(old_world[cell_pos.x + cell_pos.y*WORLD_DIMENSION].cell_type == EMPTY ){
            // Reproduction
        if(neighboors_cells >= 3){
            if(ad_prey == neighboors_cells){
                new_world[cell_pos.x + cell_pos.y*WORLD_DIMENSION].cell_type = PREY;
            }else if( ad_pred == neighboors_cells) {
                new_world[cell_pos.x + cell_pos.y*WORLD_DIMENSION].cell_type = PREDATOR;
            }
            
        }
    }

    //new_world[cell_pos.x + cell_pos.y*WORLD_DIMENSION].cell_type = old_world[cell_pos.x + cell_pos.y*WORLD_DIMENSION].cell_type;
    
    if(old_world[cell_pos.x + cell_pos.y*WORLD_DIMENSION].cell_type == PREY ){
            // Rules prey
            if(neighboors_cells == 2){
                // Stasis
                new_world[cell_pos.x + cell_pos.y*WORLD_DIMENSION].cell_type = PREY;
            }
            else if(neighboors_cells < 2){
                // Die Loliness
                new_world[cell_pos.x + cell_pos.y*WORLD_DIMENSION].cell_type = EMPTY;
            }
            else if( neighboors_cells > 3){
                // Overcrowding
                new_world[cell_pos.x + cell_pos.y*WORLD_DIMENSION].cell_type = EMPTY;
            }
        }
    else if(old_world[cell_pos.x + cell_pos.y*WORLD_DIMENSION].cell_type == PREDATOR ){
        // Rules predator
        if(neighboors_cells == 2){
                // Stasis
                new_world[cell_pos.x + cell_pos.y*WORLD_DIMENSION].cell_type = PREDATOR;
            }
            else if(neighboors_cells < 2){
                // Die Loliness
                new_world[cell_pos.x + cell_pos.y*WORLD_DIMENSION].cell_type = EMPTY;
            }
            else if( neighboors_cells > 3){
                // Overcrowding
                new_world[cell_pos.x + cell_pos.y*WORLD_DIMENSION].cell_type = EMPTY;
            }
    }
}


void host_process(Agent* old_world, Agent* new_world, int cell_index){
    if(cell_index < WORLD_DIMENSION*WORLD_DIMENSION){
        Vector2 from = {cell_index%WORLD_DIMENSION, cell_index/WORLD_DIMENSION };
        processCell(old_world, new_world, from);
    }
}

int i = 0;
void process(){

    for(int x = 0; x < WORLD_DIMENSION; x ++ ){
        for(int y = 0; y < WORLD_DIMENSION; y++ ){
            i +=1 ;
            if(i%2 == 1){
                host_process(h_old_world, h_new_world, x + y*WORLD_DIMENSION);
            }else{
                host_process(h_old_world, h_new_world, x + y*WORLD_DIMENSION);
            }
        }
    }
}


void end(){
    free(h_old_world);
    free(h_new_world);
}


Agent* getWorld(){
    if(i%2 == 1){
        return h_old_world;
    }
    return h_new_world;
    
}




}