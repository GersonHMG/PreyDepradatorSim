# PreyDepradatorSim

Proyecto de la universidad, el objetivo era implementar la simulacion de presa vs depredador con cuda y automatas celulares. Se implementaron versiones en cpu y dos en gpu. 

Requisitos

- SFML 2.6.0 >=
  - https://www.youtube.com/watch?v=Ptw1KKI9_Sg&ab_channel=AhmedSamir
- CMAKE 3.0 >=
- Compilador Visual C++ 2017 (64 o 32)

## Antes de ejecutar:
Verificar si se tiene los 3 dll (sfml-graphics-d-2.dll, sfml-window-d-2.dll, sfml-system-d-2.dll) en la misma carpeta de los binarios

## Como correrlo

``` mkdir build
cd build
cmake ..
cmake --build .
```
Mover el ejecutable PreyDepredatorSim.exe (build/Debug/PreyDepredatorSim.exe ) a la carpeta build (donde estan los .dll de sfml)