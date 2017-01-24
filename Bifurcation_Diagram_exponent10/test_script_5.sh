#!/bin/sh
for PARAM_SLOPE in 1.05 1.2
do
    echo $PARAM_SLOPE
for PARAM_SIGMA_IN in 0.5 0.4
do
    echo $PARAM_SLOPE $PARAM_SIGMA_IN
    mpiexec -n 1 /Users/manman/projects/redback/redback-opt -i Thin_test_slope0.1.i --n-threads=2 Outputs/csv=true Functions/inner_pressure_fct/value=1e-3*$PARAM_SIGMA_IN Materials/plastic_material/slope_yield_surface=$PARAM_SLOPE Outputs/file_base=bifur_slope_${PARAM_SLOPE}_sigmain_${PARAM_SIGMA_IN}

done
done