#pragma once
#include <math.h>

struct Vector2
{
    float x;
    float y;
    void normalize(){
        float w = sqrt( x*x + y*y );
        x /= w;
        y /= w;
    }
};