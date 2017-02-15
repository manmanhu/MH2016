[Mesh]
  type = FileMesh
  file = meshes/Cylinder_hollow_perturb_2D.msh
  boundary_name = 'bottom top inside outside'
  boundary_id = '109 110 112 111'
  displacements = 'disp_x disp_y'
[]

[GlobalParams]
  displacements = 'disp_x disp_y disp_z'
  porepressure = porepressure
  block = 0
[]

[Variables]
  active = 'temperature disp_y disp_x porepressure damage'
  [./disp_x]
    block = 0
  [../]
  [./disp_y]
    block = 0
  [../]
  [./disp_z]
    block = 0
  [../]
  [./porepressure]
    scaling = 1E9 # Notice the scaling, to make porepressure's kernels roughly of same magnitude as disp's kernels
    block = 0
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
[]

[Functions]
  [./temp_ic]
    type = ParsedFunction
    value = 'sqrt(x*x+y*y)/0.9 - 1/9' # -sqrt(x*x+y*y)/0.9 + 10/9
  [../]
  [./inner_pressure_fct]
    type = ParsedFunction
    value = 0.01+1000*t
  [../]
  [./inner_displacement]
    type = ParsedFunction
    value = 1e-4+10*t
  [../]
[]

[Kernels]
  [./dp_dt]
    type = TimeDerivative
    variable = porepressure
    block = 0
  [../]
  [./mass_diff]
    type = RedbackMassDiffusion
    variable = porepressure
  [../]
  [./poromech]
    type = RedbackPoromechanics
    variable = porepressure
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
    type = Diffusion
    variable = temperature
  [../]
  [./mech_dissip]
    type = RedbackMechDissip
    variable = temperature
  [../]
  [./Thermal_press]
    type = RedbackThermalPressurization
    variable = porepressure
    temperature = temperature
  [../]
[]

[AuxKernels]
  [./plastic_strain_r_r]
    type = RedbackPolarTensorMaterialAux
    variable = strain_r_r
    rank_two_tensor = plastic_strain
    index_j = 0
    index_i = 0
  [../]
  [./strain_r_theta]
    type = RedbackPolarTensorMaterialAux
    variable = strain_r_theta
    rank_two_tensor = plastic_strain
    index_j = 1
    index_i = 0
  [../]
[]

[Materials]
  active = 'no_mech plastic_material'
  [./no_mech]
    type = RedbackMaterial
    disp_y = disp_y
    disp_x = disp_y
    pore_pres = porepressure
    total_porosity = 0.1
    phi0 = 0.1
    pressurization_coefficient = 1e-7
    temperature = temperature
    gr = 10
    ar = 10
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
    type = RedbackMechMaterialDP
    disp_y = disp_y
    disp_x = disp_x
    outputs = all
    pore_pres = porepressure
    yield_stress = '0 0.001 0.1 0.0008' # 0 0.006 1 0.006
    poisson_ratio = 0.25
    youngs_modulus = 100
    damage = damage
    damage_coefficient = 1e4
    damage_method = BrittleDamage
    temperature = temperature
    exponent = 10
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
    petsc_options_value = 'gmres        asm        1E-2          1E-8        200                500                  1e-4        lu                      NONZERO'
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
  end_time = 0.3
  dt = 2e-6 # 1e-5
  l_tol = 1e-5 # 1e-05
[]

[Outputs]
  active = ''
  exodus = true
  execute_on = 'timestep_end initial'
  file_base = borehole_dmg_2D_test1
  [./csv_p]
    file_base = borehole_highres_p
    type = CSV
  [../]
  [./csv_s]
    file_base = borehole_highres_s
    type = CSV
  [../]
  [./csv_t]
    file_base = borehole_highres_t
    type = CSV
  [../]
  [./exodus]
    type = Exodus
    elemental_as_nodal = true
  [../]
[]

[RedbackMechAction]
  [./mechanics]
    pore_pres = porepressure
    disp_y = disp_y
    disp_x = disp_x
  [../]
[]

[ICs]
  [./random_dmg_ic]
    variable = damage
    max = 0.01
    type = RandomIC
  [../]
  [./random_temp_ic]
    function = temp_ic
    max = 0.1
    type = FunctionWithRandomIC
    variable = temperature
  [../]
[]

