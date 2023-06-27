#pragma once

#include <iostream>
#include "cuda_runtime.h"
#include "agent_aos.cuh"
#include "config.hpp"

Agent* d_old_world; // device old world
Agent* d_new_world; // device new world
Agent* h_world; //host world


void init(){
    h_world = (Agent*) malloc( sizeof(Agent)*WORLD_DIMENSION*WORLD_DIMENSION );
    printf("Initializing... \n");
    //Init world
    // Generate world
    Agent* t_world = (Agent*) malloc( sizeof(Agent)*WORLD_DIMENSION*WORLD_DIMENSION );
    for (int i = 0; i < WORLD_DIMENSION*WORLD_DIMENSION ; i++){
        // Initialize 
        t_world[i].cell_type = EMPTY;
    } 
    
    int n_preys = 20;
    for (int i = 0; i < n_preys ; i++){
        int random_coord = rand()%(WORLD_DIMENSION*WORLD_DIMENSION );
        // Initialize 
        t_world[i].cell_type = PREY;
        t_world[i].t_reproduce = 0;
    }
    
    int offset = 5050;
    t_world[offset+ 1].cell_type = PREY;
    t_world[offset+ WORLD_DIMENSION + 2].cell_type = PREY;
    t_world[offset+ WORLD_DIMENSION*2].cell_type = PREY;
    t_world[offset+ WORLD_DIMENSION*2 + 1].cell_type = PREY;
    t_world[offset+ WORLD_DIMENSION*2 + 2].cell_type = PREY;

    cudaMalloc(&d_old_world, sizeof(Agent)*WORLD_DIMENSION*WORLD_DIMENSION );
    cudaMemcpy( d_old_world, t_world, sizeof(Agent)*WORLD_DIMENSION*WORLD_DIMENSION, cudaMemcpyHostToDevice);
    

    cudaMalloc(&d_new_world, sizeof(Agent)*WORLD_DIMENSION*WORLD_DIMENSION );
    cudaMemcpy( d_new_world, t_world, sizeof(Agent)*WORLD_DIMENSION*WORLD_DIMENSION, cudaMemcpyHostToDevice);
    free(t_world);
}

__device__ void processCell(Agent* old_world, Agent* new_world, Vector2 cell_pos){
    int neighboors_cells = 0;
    // For each neighboor
    for (int x = -1; x < 2; x++){
        for (int y = -1; y < 2; y++){
            Vector2 ad_cell = { cell_pos.x + x , cell_pos.y + y }; 
            ad_cell.x = mod(ad_cell.x, WORLD_DIMENSION);
            ad_cell.y = mod(ad_cell.y, WORLD_DIMENSION);
            if( (x != 0 || y != 0) &&
                old_world[ad_cell.x + ad_cell.y*WORLD_DIMENSION].cell_type != EMPTY){
                neighboors_cells += 1;
            }
        }
    }
    //new_world[cell_pos.x + cell_pos.y*WORLD_DIMENSION].cell_type = old_world[cell_pos.x + cell_pos.y*WORLD_DIMENSION].cell_type;
    new_world[cell_pos.x + cell_pos.y*WORLD_DIMENSION].cell_type = EMPTY;

    // Rules
    if(old_world[cell_pos.x + cell_pos.y*WORLD_DIMENSION].cell_type == EMPTY ){
        // Reproduction
        if(neighboors_cells >= 3){
            new_world[cell_pos.x + cell_pos.y*WORLD_DIMENSION].cell_type = PREY;
        }
    }else{
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
    
}


__global__ void device_process(Agent* old_world, Agent* new_world){
    int tId = threadIdx.x + blockIdx.x * blockDim.x ;
    if(tId < WORLD_DIMENSION*WORLD_DIMENSION){
        Vector2 from = {tId%WORLD_DIMENSION, tId/WORLD_DIMENSION };
        processCell(old_world, new_world, from);
        /*
        Agent* temp_world = *old_world;
        *old_world = *new_world;
        *new_world = temp_world;
        */
        /*
            switch (world[tId].cell_type){
                case PREDATOR:
                    //processPredator(world, &world[i],  from);
                    //moveAgent(world, world[i], from, randomCell(from.x, from.y) );
                    break;
                case PREY:
                    printf(" THREAD PREY \n");
                    processPrey(world, &world[tId], from);
                    break;
        }
        */
    }
}

int i = 0;
void process(){
    i +=1 ;
    if(i%2 == 1){
        device_process<<<WORLD_DIMENSION*WORLD_DIMENSION, 1>>>(d_old_world, d_new_world);
    }else{
         device_process<<<WORLD_DIMENSION*WORLD_DIMENSION, 1>>>(d_new_world, d_old_world);
    }
    
}


void end(){
    cudaFree(d_old_world);
    cudaFree(d_new_world);
    free(h_world);
}


Agent* getWorld(){
    cudaMemcpy(h_world, d_old_world, sizeof(Agent)*WORLD_DIMENSION*WORLD_DIMENSION , cudaMemcpyDeviceToHost);
    return h_world;
}




