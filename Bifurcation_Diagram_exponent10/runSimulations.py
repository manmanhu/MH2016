''' Script to run 6 simulations (to compare with Oka's experiments)

for CONFINEMENT in 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8
do
    echo $CONFINEMENT
    mpiexec -n  1 $EXEC -i Oka.i --n-threads=2 Outputs/csv=true BCs/confinement_left/value=$CONFINEMENT BCs/confinement_right/value=-$CONFINEMENT BCs/confinement_front/value=-$CONFINEMENT BCs/confinement_back/value=$CONFINEMENT
    python create_postprocess_pics_from_csv.py
    mv Oka.csv oka_confinement_${CONFINEMENT}.csv
    mv Oka.e oka_confinement_${CONFINEMENT}.e
    mv pics_postprocess/P-Q/P-Q_00050.png pics_postprocess/P-Q/confinement_${CONFINEMENT}.png
done

'''
import os, sys, random, logging, subprocess, shutil, math

def getLogger(name, log_file='log.txt', level=logging.INFO):
    ''' Creates logger with given name and level.
        @param[in]   name     - string, logger name
        @param[in]   log_file - string, file name for log file
        @param[in]   level    - int, logging level
        @return[out] logger   - logger instance built
    '''
    logger_name = '{0}_{1}'.format(name, random.random())
    logger = logging.getLogger(logger_name)
    hdlr1 = logging.FileHandler(log_file)
    hdlr2 = logging.StreamHandler(sys.stdout)
    formatter = logging.Formatter('%(asctime)s %(levelname)-8s %(message)s')
    hdlr1.setFormatter(formatter)
    hdlr2.setFormatter(formatter)
    logger.addHandler(hdlr1)
    logger.addHandler(hdlr2)
    logger.setLevel(level)
    return logger

def runSimulations(output_subdir='batch_test', nb_procs=8):
    ''' Run 6 simulations (varying confining pressure) for given parameters '''
    equil_input_file = 'Oka_initialisation.i'
    input_file = 'Oka.i'
    cp_folder = 'Oka_initialised_cp'
    xda_root_filename0 = 'Oka_initialised_0000'
    xda_root_filename1 = 'Oka_initialised_0001'
    
    normalising_stress = 2.26e6 # Pa
    output_root_dir = 'results'
    output_dir = os.path.join(output_root_dir, output_subdir)
    confining_pressures = {
        1:0.25e6/normalising_stress, # 0.11
        2:0.5e6/normalising_stress,  # 0.221
        3:0.75e6/normalising_stress, # 0.332
        4:1.0e6/normalising_stress,  # 0.442
        5:1.5e6/normalising_stress,  # 0.664
        6:2.0e6/normalising_stress,  # 0.885
    }
    # For the expression exp(-(K1+K2*p_f)) from the Excel spreadsheet
    K1 = {1:-0,
          2:-0,
          3:-0,
          4:-2, # OK (kinda) for press_coeff = 1, alpha3=1
          5:-1,
          6:0.3, # OK (kinda) for press_coeff = 1, alpha3=100
          }
    K2 = {1:-8.1,
          2:-1.53,
          3:2.3,
          4:5.7, # OK (kinda) for press_coeff = 1, alpha3=1
          5:9,
          6:8, # OK (kinda) for press_coeff = 1, alpha3=100
          }
    if not os.path.isdir(output_dir):
        os.makedirs(output_dir)
    logger = getLogger('sim', os.path.join(output_dir, 'log.txt'), logging.INFO)
    logger.info('='*20)
    shutil.copy(input_file, os.path.join(output_dir, input_file))
    for i in sorted(confining_pressures.keys()):
        logger.info('Running simulation CD{0}...'.format(i))
        exec_loc = '~/projects/redback/redback-opt'
        alpha_1 = K1[i] # K1 (see Excel spreadsheet)
        alpha_2 = K2[i] # K2 (see Excel spreadsheet)
        alpha_3 = 1e2 #1e2 # multiplying the volumetric plastic flow increment
        ref_pe_rate = 1.5e3 #1.5e3
        press_coeff = 1e-5 # 1e-5
        solid_compress = 0.25
        E = 100 # Young's modulus
        yield_stress = "'0. 1 1 1'"
        biot_coefficient = 1
        nx = 4#16,#4
        ny = 8#32,#8
        nz = 4#16,#4
        #command1 = 'mpiexec -n {nb_procs} {exec_loc} '\ # MPI version
        command1 = '{exec_loc} --n-threads={nb_procs} '\
        '-i {input_i} Outputs/csv=true Functions/confinement_fct/value={confinement__value} '\
        'Mesh/nx={nx} Mesh/ny={ny} Mesh/nz={nz} '\
        'Materials/mat_nomech/confining_pressure={confinement__value} '\
        'Materials/mat_nomech/solid_compressibility={solid_compress} '\
        'Materials/mat_nomech/biot_coefficient={biot_coefficient} '\
        'Materials/mat_mech/ref_pe_rate={ref_pe_rate} '\
        'Materials/mat_mech/youngs_modulus={E} '\
        'Materials/mat_mech/yield_stress={yield_stress} '\
        'Materials/mat_nomech/alpha_1={alpha_1} Materials/mat_nomech/alpha_2={alpha_2} '\
        'Materials/mat_nomech/alpha_3={alpha_3} Materials/mat_nomech/pressurization_coefficient={press_coeff}'.\
        format(nb_procs=nb_procs, input_i=equil_input_file, exec_loc=exec_loc, confinement__value=confining_pressures[i],
               nx=nx, ny=ny, nz=nz, alpha_1=alpha_1, alpha_2=alpha_2, alpha_3=alpha_3, ref_pe_rate = ref_pe_rate, 
               biot_coefficient=biot_coefficient,
               press_coeff=press_coeff, solid_compress=solid_compress, E=E, yield_stress=yield_stress)
        #command2 = 'mpiexec -n {nb_procs} {exec_loc} '\
        command2 = '{exec_loc} --n-threads={nb_procs} '\
        '-i {input_i} Outputs/csv=true Functions/confinement_fct/value={confinement__value} '\
        'Materials/mat_nomech/confining_pressure={confinement__value} Executioner/end_time=0.12 '\
        'Materials/mat_nomech/solid_compressibility={solid_compress} '\
        'Materials/mat_nomech/biot_coefficient={biot_coefficient} '\
        'Materials/mat_mech/ref_pe_rate={ref_pe_rate} '\
        'Materials/mat_mech/youngs_modulus={E} '\
        'Materials/mat_mech/yield_stress={yield_stress} '\
        'Materials/mat_nomech/alpha_1={alpha_1} Materials/mat_nomech/alpha_2={alpha_2} '\
        'Materials/mat_nomech/alpha_3={alpha_3}  Materials/mat_nomech/pressurization_coefficient={press_coeff} '\
        'Executioner/end_time=0.12'.\
        format(nb_procs=nb_procs, input_i=input_file, exec_loc=exec_loc, confinement__value=confining_pressures[i],
               ref_pe_rate = ref_pe_rate, E=E, yield_stress=yield_stress, biot_coefficient=biot_coefficient,
               alpha_1=alpha_1, alpha_2=alpha_2, alpha_3=alpha_3, press_coeff=press_coeff, solid_compress=solid_compress)
        # Executioner/num_steps=50  Executioner/end_time=0.06
        try:
            # clean previous files
            if os.path.isdir(cp_folder):
                logger.debug('Deleting cp_folder "{0}"'.format(cp_folder))
                shutil.rmtree(cp_folder)
            for xda_filename in [xda_root_filename0, xda_root_filename1]:
                for tmp_xda_filename in [xda_filename + '_mesh.xda', xda_filename + '.xda']:
                    if os.path.isfile(tmp_xda_filename):
                        logger.debug('Deleting file "{0}"'.format(tmp_xda_filename))
                        os.remove(tmp_xda_filename)
            # copy input file (unaltered!)
            shutil.copy(input_file, os.path.join(output_dir, input_file))
            # Run equilibration step
            logger.info(command1)
            retcode = subprocess.call(command1, shell=True)
            if retcode < 0:
                error_msg = 'Child process was terminated by signal {0}'.format(retcode)
                logger.error(error_msg)
            # Run simulation
            logger.info(command2)
            retcode = subprocess.call(command2, shell=True)
            if retcode < 0:
                error_msg = 'Child process was terminated by signal {0}'.format(retcode)
                logger.error(error_msg)
            # Rename output file
            #continue
            shutil.move('Oka.csv', os.path.join(output_dir, 'oka_CD{0}.csv'.format(i)))
            shutil.move('Oka.e',   os.path.join(output_dir, 'oka_CD{0}.e'.format(i)))
            logger.info('\tOutput files moved to {0}'.format(output_dir))
        except:
            logger.error('Execution failed!')
    logger.info('Finished')

if __name__ == '__main__':
    runSimulations(output_subdir='batch_test', nb_procs=8)
    #runSimulations(output_subdir='batch_Ar8_manual_0.5__16_32_16', nb_procs=16)
