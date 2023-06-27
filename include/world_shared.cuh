#pragma once

#include <iostream>
#include "cuda_runtime.h"
#include "agent_aos.cuh"
#include "config.hpp"


namespace CudaWorldShared{

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


        int n_predator = 100;
        for (int i = 450; i < 450 + n_predator ; i++){
            int random_coord = rand()%(WORLD_DIMENSION*WORLD_DIMENSION );
            // Initialize 
            t_world[i].cell_type = PREDATOR;
            t_world[i].t_reproduce = 0;
        }

        cudaMalloc(&d_old_world, sizeof(Agent)*WORLD_DIMENSION*WORLD_DIMENSION );
        cudaMemcpy( d_old_world, t_world, sizeof(Agent)*WORLD_DIMENSION*WORLD_DIMENSION, cudaMemcpyHostToDevice);
        

        cudaMalloc(&d_new_world, sizeof(Agent)*WORLD_DIMENSION*WORLD_DIMENSION );
        cudaMemcpy( d_new_world, t_world, sizeof(Agent)*WORLD_DIMENSION*WORLD_DIMENSION, cudaMemcpyHostToDevice);
        free(t_world);
    }

    __device__ void processCell(Agent* old_world, Agent* new_world, Vector2 cell_pos){

        __shared__ int ad_cells[9];
        __shared__ int ad_preds[9];
        __shared__ int ad_preys[9];
        int tId = threadIdx.x;
    
        ad_cells[tId] = old_world[cell_pos.x + cell_pos.y*WORLD_DIMENSION].cell_type != EMPTY;
        ad_preds[tId] = old_world[cell_pos.x + cell_pos.y*WORLD_DIMENSION].cell_type == PREDATOR;
        ad_preys[tId] = old_world[cell_pos.x + cell_pos.y*WORLD_DIMENSION].cell_type != PREY;

        if(tId == 4){
            ad_cells[tId] = 0;
            ad_preds[tId] = 0;
            ad_preys[tId] = 0;
        }
        
        
        __syncthreads();

        // Reduction
        int N = 9;

        for(int i = N/2;i>=1;i/=2){
                if(tId < i){
                    ad_cells[tId] += ad_cells[tId+i];
                    ad_preds[tId] += ad_preds[tId+i];
                    ad_preys[tId] += ad_preys[tId+i];
                }
            __syncthreads();   
        }
        if(tId == 4){
        
        ad_cells[tId] += ad_cells[9];
        ad_preds[tId] += ad_preds[9];
        ad_preys[tId] += ad_preys[9];

        new_world[cell_pos.x + cell_pos.y*WORLD_DIMENSION].cell_type = EMPTY;

        if(old_world[cell_pos.x + cell_pos.y*WORLD_DIMENSION].cell_type == EMPTY ){
                // Reproduction
            if(ad_cells[0] >= 3){
                if(ad_preys[0] == ad_cells[0] ){
                    new_world[cell_pos.x + cell_pos.y*WORLD_DIMENSION].cell_type = PREY;
                }else if( ad_preds[0] == ad_cells[0] ) {
                    new_world[cell_pos.x + cell_pos.y*WORLD_DIMENSION].cell_type = PREDATOR;
                }
                
            }
        }
        
        if(old_world[cell_pos.x + cell_pos.y*WORLD_DIMENSION].cell_type == PREY ){
                // Rules prey
                if(ad_cells[0] == 2){
                    // Stasis
                    new_world[cell_pos.x + cell_pos.y*WORLD_DIMENSION].cell_type = PREY;
                }
                else if(ad_cells[0] < 2){
                    // Die Loliness
                    new_world[cell_pos.x + cell_pos.y*WORLD_DIMENSION].cell_type = EMPTY;
                }
                else if( ad_cells[0] > 3){
                    // Overcrowding
                    new_world[cell_pos.x + cell_pos.y*WORLD_DIMENSION].cell_type = EMPTY;
                }
            }
        else if(old_world[cell_pos.x + cell_pos.y*WORLD_DIMENSION].cell_type == PREDATOR ){
            // Rules predator
            if(ad_cells[0] == 2){
                    // Stasis
                    new_world[cell_pos.x + cell_pos.y*WORLD_DIMENSION].cell_type = PREDATOR;
                }
                else if(ad_cells[0] < 2){
                    // Die Loliness
                    new_world[cell_pos.x + cell_pos.y*WORLD_DIMENSION].cell_type = EMPTY;
                }
                else if( ad_cells[0] > 3){
                    // Overcrowding
                    new_world[cell_pos.x + cell_pos.y*WORLD_DIMENSION].cell_type = EMPTY;
                }
        }

        }

    }


    __global__ void device_process(Agent* old_world, Agent* new_world){
        int tId = threadIdx.x + blockIdx.x * blockDim.x ;
        if(tId < WORLD_DIMENSION*WORLD_DIMENSION){
            Vector2 from = {tId%WORLD_DIMENSION, tId/WORLD_DIMENSION };
            processCell(old_world, new_world, from);
        }
    }

    int i = 0;
    void process(){
        i +=1 ;
        if(i%2 == 1){
            device_process<<<WORLD_DIMENSION*WORLD_DIMENSION, 9>>>(d_old_world, d_new_world);
        }else{
            device_process<<<WORLD_DIMENSION*WORLD_DIMENSION, 9>>>(d_new_world, d_old_world);
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





}