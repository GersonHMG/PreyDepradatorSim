@echo off
setlocal
set "ruta=build\Debug"
set "nombre_archivo=PreyDepredatorSim"

del /Q "%ruta%\%nombre_archivo%.exe"
del /Q "%ruta%\%nombre_archivo%.exp"
del /Q "%ruta%\%nombre_archivo%.lib"
del /Q "%ruta%\%nombre_archivo%.pdb"

endlocal
exit /B