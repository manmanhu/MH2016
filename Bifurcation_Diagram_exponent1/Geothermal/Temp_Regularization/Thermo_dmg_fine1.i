[Mesh]
  type = FileMesh
  file = Cylinder_hollow_noperturb_2D_thin.msh
  boundary_name = 'bottom top inside outside'
  boundary_id = '109 110 112 111'
  displacements = 'disp_x disp_y'
[]

[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
  porepressure = porepressure
  block = 0
[]

[MeshModifiers]
  [./top]
    type = AddExtraNodeset
    new_boundary = 101
    coord = '0 0.25'
  [../]
  [./bottom]
    type = AddExtraNodeset
    new_boundary = 102
    coord = '0 -0.25'
  [../]
  [./left]
    type = AddExtraNodeset
    new_boundary = 103
    coord = '-0.25 0'
  [../]
  [./right]
    type = AddExtraNodeset
    new_boundary = 104
    coord = '0.25 0'
  [../]
[]

[Variables]
  active = 'temperature disp_y disp_x porepressure damage'
  [./disp_x]
  [../]
  [./disp_y]
  [../]
  [./disp_z]
    block = 0
  [../]
  [./porepressure]
    scaling = 1E9 # Notice the scaling, to make porepressure's kernels roughly of same magnitude as disp's kernels
  [../]
  [./damage]
  [../]
  [./temperature]
  [../]
[]

[AuxVariables]
  [./strain_r_r]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./strain_r_theta]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./strain_theta_theta]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./stress_r_r]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./stress_r_theta]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./stress_theta_theta]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[Functions]
  active = 'timestep_function inner_pressure_fct outer_pressure_fct'
  [./temp_ic]
    type = ParsedFunction
    value = 'sqrt(x*x+y*y)/0.9 - 1/9' # -sqrt(x*x+y*y)/0.9 + 10/9
  [../]
  [./inner_pressure_fct]
    # 1.5e-3
    type = ParsedFunction
    value = 0.1+4*t # 1e-3+4e-2*t
  [../]
  [./timestep_function]
    # max(1e-7,min(1e1, dt*max(0.2,1-5*(T-T_old-0.2))))
    # 
    # max(1e-7,min(1e-2, dt*max(0.1,0.1-5*(T-T_old-0.2))))
    # 
    # if(T>3.5, 1e-5, max(1e-7,min(1e-2, dt*max(0.2,1-5*(T-T_old-0.2)))))
    # if(t>0.0169, 1e-7, if(t>0.0168, 2e-6, max(1e-7,min(1e-2, dt*max(0.2, 1-5*(T-T_old-0.2))))))
    type = ParsedFunction
    value = 1e-3 # 1e-3
  [../]
  [./outer_pressure_fct]
    type = ParsedFunction
    value = 0.1
  [../]
[]

[Kernels]
  active = 'damage_dt dt_temp damage_kernel dp_dt mass_diff'
  [./dp_dt]
    type = TimeDerivative
    variable = porepressure
  [../]
  [./mass_diff]
    type = RedbackMassDiffusion
    variable = porepressure
  [../]
  [./poromech]
    type = RedbackPoromechanics
    variable = porepressure
    block = '0 1'
  [../]
  [./damage_dt]
    type = TimeDerivative
    variable = damage
  [../]
  [./damage_kernel]
    type = RedbackDamage
    variable = damage
  [../]
  [./dt_temp]
    type = TimeDerivative
    variable = temperature
  [../]
  [./diff_temp]
    type = RedbackThermalDiffusion
    variable = temperature
    time_factor = 1e-3
  [../]
  [./mech_dissip]
    type = RedbackMechDissip
    variable = temperature
    block = '0 1'
  [../]
  [./Thermal_press]
    type = RedbackThermalPressurization
    variable = porepressure
    block = '0 1'
  [../]
[]

[AuxKernels]
  [./strain_r_theta]
    type = RedbackPolarTensorMaterialAux
    variable = strain_r_theta
    rank_two_tensor = plastic_strain
    index_j = 1
    index_i = 0
  [../]
  [./strain_r_r]
    type = RedbackPolarTensorMaterialAux
    variable = strain_r_r
    rank_two_tensor = plastic_strain
    index_j = 0
    index_i = 0
  [../]
  [./strain_theta_theta]
    type = RedbackPolarTensorMaterialAux
    variable = strain_theta_theta
    rank_two_tensor = plastic_strain
    index_j = 1
    index_i = 1
  [../]
  [./stress_r_r]
    type = RedbackPolarTensorMaterialAux
    variable = stress_r_r
    rank_two_tensor = stress
    index_j = 0
    index_i = 0
  [../]
  [./stress_r_theta]
    type = RedbackPolarTensorMaterialAux
    variable = stress_r_theta
    rank_two_tensor = stress
    index_j = 1
    index_i = 0
  [../]
  [./stress_theta_theta]
    type = RedbackPolarTensorMaterialAux
    variable = stress_theta_theta
    rank_two_tensor = stress
    index_j = 1
    index_i = 1
  [../]
[]

[BCs]
  active = 'Pressure confine_y confine_x'
  [./Pressure]
    [./press_inner]
      function = inner_pressure_fct
      boundary = 0
      disp_y = disp_y
      disp_x = disp_x
    [../]
    [./press_outer]
      function = outer_pressure_fct
      boundary = 1
      disp_y = disp_y
      disp_x = disp_x
    [../]
  [../]
  [./Temp_borehole]
    type = DirichletBC
    variable = temperature
    boundary = 1
    value = 0
  [../]
  [./Temp_outside]
    type = DirichletBC
    variable = temperature
    boundary = 1
    value = 1
  [../]
  [./fixed_outer_x]
    type = PresetBC
    variable = disp_x
    boundary = '2 3'
    value = 0
  [../]
  [./fixed_outer_y]
    type = PresetBC
    variable = disp_y
    boundary = '1 2'
    value = 0
  [../]
  [./confine_x]
    type = PresetBC
    variable = disp_x
    boundary = '101 102'
    value = 0
  [../]
  [./confine_y]
    type = PresetBC
    variable = disp_y
    boundary = '103 104'
    value = 0
  [../]
[]

[Materials]
  active = 'no_mech plastic_material'
  [./no_mech]
    type = RedbackMaterial
    disp_y = disp_y
    disp_x = disp_x
    pore_pres = porepressure
    total_porosity = 0.1
    phi0 = 0.1
    pressurization_coefficient = 1e-7
    gr = 1e5 # 20000
    ar = 10
    solid_compressibility = 1000
    is_mechanics_on = true
    temperature = temperature
  [../]
  [./elastic_material]
    type = RedbackMechMaterialElastic
    disp_z = disp_z
    disp_y = disp_y
    disp_x = disp_x
    poisson_ratio = 0.25
    youngs_modulus = 100
    outputs = all
  [../]
  [./plastic_material]
    # 0 0.001 0.1 0.0008
    type = RedbackMechMaterialDP
    disp_y = disp_y
    disp_x = disp_x
    outputs = all
    pore_pres = porepressure
    yield_stress = '0 0.001 0.1 0.0008' # 0 0.006 1 0.006
    poisson_ratio = 0.25
    youngs_modulus = 100
    damage = damage
    damage_coefficient = 3e3 # 1e4
    damage_method = BrittleDamage
    exponent = 10
    temperature = temperature
  [../]
[]

[Postprocessors]
  active = 'nnli max_r_theta new_timestep nli old_timestep'
  [./max_temp]
    type = NodalMaxValue
    variable = temperature
  [../]
  [./new_timestep]
    type = FunctionValuePostprocessor
    function = timestep_function
  [../]
  [./max_temp_old]
    type = NodalMaxValue
    variable = temperature
    execute_on = timestep_begin
  [../]
  [./old_timestep]
    type = TimestepSize
    execute_on = timestep_begin
  [../]
  [./max_r_theta]
    type = ElementExtremeValue
    variable = strain_r_theta
  [../]
  [./nli]
    type = NumLinearIterations
  [../]
  [./nnli]
    type = NumNonlinearIterations
  [../]
[]

[Preconditioning]
  active = 'andy'
  [./andy]
    # gmres asm 1E0 1E-10 200 500 lu NONZERO
    type = SMP
    full = true
    solve_type = NEWTON
    petsc_options = '-snes_monitor -snes_linesearch_monitor -ksp_monitor'
    petsc_options_iname = '-ksp_type -pc_type  -snes_atol -snes_rtol -snes_max_it -ksp_max_it -ksp_atol -sub_pc_type -sub_pc_factor_shift_type'
    petsc_options_value = 'gmres        asm        1E-10          1E-5        200                500                  1e-8        lu                      NONZERO'
    line_search = basic
  [../]
  [./manolis]
    type = SMP
    solve_type = NEWTON
    petsc_options_iname = '-ksp_type -pc_type -snes_atol -snes_rtol -snes_max_it'
    petsc_options_value = 'bcgs bjacobi 1E-14 1E-10 10000'
  [../]
  [./default]
    type = SMP
    solve_type = NEWTON
  [../]
  [./Manman]
    type = SMP
    solve_type = NEWTON
    petsc_options_iname = '-ksp_type -pc_type -snes_atol -snes_rtol -snes_max_it'
    petsc_options_value = 'bcgs bjacobi 1E-14 1E-10 10000'
  [../]
[]

[Executioner]
  # [./TimeStepper]
  # type = PostprocessorDT
  # postprocessor = dt
  # dt = 0.003
  # [../]
  type = Transient
  l_max_its = 100
  end_time = 0.5
  dt = 1e-3 # 1e-5
  l_tol = 1e-5 # 1e-05
  [./TimeStepper]
    type = PostprocessorDT
    postprocessor = new_timestep
  [../]
[]

[Outputs]
  exodus = true
  execute_on = 'timestep_end initial'
  file_base = Thermo_dmg_5_test
[]

[RedbackMechAction]
  [./mechanics]
    pore_pres = porepressure
    disp_y = disp_y
    disp_x = disp_x
    temp = temperature
  [../]
[]

[ICs]
  active = 'random_temp_ic'
  [./random_dmg_ic]
    variable = damage
    max = 0.01
    type = RandomIC
  [../]
  [./random_temp_ic]
    max = 0.01
    type = RandomIC
    variable = temperature
    boundary = 0
  [../]
  [./random_dmg_test]
    variable = damage
    max = 0.05
    boundary = 0
    type = RandomIC
  [../]
  [./random_func_temp_ic]
    function = temp_ic
    max = 0.1
    type = FunctionWithRandomIC
    variable = temperature
  [../]
[]

