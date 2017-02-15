// Gmsh project created on Wed Feb 24 14:27:50 2016

lc = 0.05;
R_out = 1.; // radius of outer circle
R_in = 0.05; // radius of inner circle 
H = 0.1; // height of cylinder
nb_layers_quarter_circle = 30; //number of layers in one THIRD OF CIRCLE
nb_rings = 40; // number of concentric cell rings
nb_layers_z = 1; // number of vertical layers
angle_crack = Pi/36;
nb_layers_crack = 10;
nb_rings_crack = nb_rings*2;

Point(1) = {0,0,0,lc}; // Center

Point(2) = {R_in*Cos(angle_crack/2),R_in*Sin(angle_crack/2),0,lc};
Point(3) = {R_out*Cos(angle_crack/2),R_out*Sin(angle_crack/2),0,lc};
Point(4) = {R_out*Cos(angle_crack/2),R_out*Sin(angle_crack/2),H,lc};
Point(5) = {R_in*Cos(angle_crack/2),R_in*Sin(angle_crack/2),H,lc};

Line(6) = {2,3};
Line(7) = {3,4};
Line(8) = {4,5};
Line(9) = {5,2};
Line Loop(10) = {6,7,8,9};

Transfinite Line{-6,8} = nb_rings+1 Using Progression 0.8;
Transfinite Line {7,9} = nb_layers_z+1;

Ruled Surface(11) = {10};
Transfinite Surface{11} = {2,3,4,5};
Recombine Surface(11);

out1[] = Extrude{ {0,0,1}, {0,0,0}, Pi/2-angle_crack/2}{ Surface{11};  Layers{nb_layers_quarter_circle}; Recombine;};
Printf("surface index at the end = out1[0] = %g", out1[0]);
Printf("volume index = out1[1] = %g", out1[1]);
Printf("surface index bottom = out1[2] = %g", out1[2]);
Printf("surface index oustside = out1[3] = %g", out1[3]);
Printf("surface index top = out1[4] = %g", out1[4]);
Printf("surface index inside = out1[5] = %g", out1[5]);

out2[] = Extrude{ {0,0,1}, {0,0,0}, Pi}{ Surface{out1[0]};  Layers{nb_layers_quarter_circle*2}; Recombine;};
out3[] = Extrude{ {0,0,1}, {0,0,0}, Pi/2-angle_crack/2}{ Surface{out2[0]};  Layers{nb_layers_quarter_circle}; Recombine;};


Transfinite Volume(out1[1]);
Transfinite Volume(out2[1]);
Transfinite Volume(out3[1]);

Physical Surface (0) = {out1[4],out2[4],out3[4]}; // top
Physical Surface (1) = {out1[2],out2[2],out3[2]}; // bottom
Physical Surface (2) = {out1[3],out2[3],out3[3]}; // outer boundary
Physical Surface (3) = {out1[5],out2[5],out3[5]}; // inner boundary


Physical Surface (8) = {11}; // interface theta=0
Physical Surface (9) = {out3[0]}; // the other interface

Physical Volume(0) = {out1[1],out2[1],out3[1]};
