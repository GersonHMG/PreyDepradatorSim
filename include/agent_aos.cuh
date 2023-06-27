#pragma once

#include <iostream>
#include "config.hpp"
#include "cuda_runtime.h"
#include "utils.hpp"

__host__ __device__ int mod(int a, int b) { 
    return (a % b + b) % b; 
}

enum CELL_TYPE { EMPTY, PREDATOR, PREY };

struct Agent{
    CELL_TYPE cell_type; // 0 empty, 1 predator, 2 prey
    int t_reproduce; //
    int hungry; //predator hungry
};





