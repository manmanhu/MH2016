cl__1 = 0.05;
Point(1) = {0, 0, 0, 0.05};
Point(2) = {0.05, 0, 0, 0.05};
Point(3) = {0, 0.05, 0, 0.05};
Point(4) = {-0.05, 0, 0, 0.05};
Point(5) = {1, 0, 0, 0.05};
Point(6) = {0, 1, 0, 0.05};
Point(7) = {-1, 0, 0, 0.05};
Circle(1) = {2, 1, 3};
Transfinite Line {1} = 30Using Progression 1;
Circle(2) = {3, 1, 4};
Transfinite Line {2} = 30Using Progression 1;
Circle(3) = {5, 1, 6};
Transfinite Line {3} = 30Using Progression 1;
Circle(4) = {6, 1, 7};
Transfinite Line {4} = 30Using Progression 1;
Line(5) = {2, 5};
Transfinite Line {-5} = 41Using Progression 0.8;
Line(6) = {3, 6};
Transfinite Line {-6} = 41Using Progression 0.8;
Line(7) = {4, 7};
Transfinite Line {-7} = 41Using Progression 0.8;
Line Loop(9) = {1, 6, -3, -5};
Ruled Surface(9) = {9};
Transfinite Surface {9};
Recombine Surface {9};
Line Loop(11) = {2, 7, -4, -6};
Ruled Surface(11) = {11};
Transfinite Surface {11};
Recombine Surface {11};
lc = 0;
Physical Line(lc) = {1, 2};
nb_layers_z = 1;
Physical Line(nb_layers_z) = {3, 4};
Physical Line(2) = {5};
Physical Line(3) = {7};
lc = 0;
Physical Surface(lc) = {9, 11};
