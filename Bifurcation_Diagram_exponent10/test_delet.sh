#!/bin/sh

for PARAM_SIGMA_IN in 4 2 1.333 1 0.8 0.667
do
    echo $PARAM_SIGMA_IN
    mpiexec -n 1 /Users/manman/projects/redback/redback-opt -i Thin_test_slope0.1.i --n-threads=2 Outputs/csv=true Functions/inner_pressure_fct/value=1e-3*$PARAM_SIGMA_IN Materials/plastic_material/slope_yield_surface=0.9 Outputs/file_base=bifur_slope_0.9_sigmain_${PARAM_SIGMA_IN}

done
