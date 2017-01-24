''' Script to run 2 simulations

for PARAM_SIGMA_IN in 0.5 1
do
    echo $PARAM_SIGMA_IN
    mpiexec -n  1 $EXEC -i Thin_test.i --n-threads=2 Outputs/csv=true Functions/inner_pressure_fct/value=1e-3*$PARAM_SIGMA_IN
    mv Thin_test.csv bifur_sigmain_${PARAM_SIGMA_IN}.csv
    mv Thin_test.e bifur_sigmain_${PARAM_SIGMA_IN}.e
done

'''
print 'hello'
x =2
print x
