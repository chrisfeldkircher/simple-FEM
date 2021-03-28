%% I) Create Geometry
% Construct a simple 3-D beam model with the help of SG Library
SG1 = SGbox([5 2 2]);
% SG2 = SGofCPLcommand('c 4,h 5');
% SG3 = SGofCPLcommand('sph 10');
% SG4 = SGofCPLcommand('scr 5 10');
% SG5 = SGofCPLcommand('b 10 10, c 4 3, h 4, cham 1 0.5');
SGplot(SG1);

h = 0.4;
E = 3e9;
nu= 0.03;
fixedface = 4;
loadingface = 3;
load = [0 0 -1e7];

%% II) Preprocessing the Geometry
% Importing Geometry (stl-file)
model = createpde('structural','static-solid');
filename = SGwriteSTL(SG1);
importGeometry(model,filename);
delete(filename);

% Discretize the model
generateMesh(model,'Hmax',h);
figure
pdeplot3D(model);

% Add the coefficients of the PDEs
structuralProperties(model,'Cell',1,'YoungsModulus',E,'PoissonsRatio',nu);


% Check the surface index and add the boundary conditions 
figure
pdegplot(model,'FaceLabels','on','CellLabels','on','FaceAlpha',0.5);
%pdegplot(model,'FaceLabels','on','FaceLabels','on','FaceAlpha',0.5);

%% III) Solving 

structuralBC(model,'Face',fixedface,'Constraint','fixed');
structuralBoundaryLoad (model,'Face',loadingface,'SurfaceTraction',load);

% Solve the problem and see the von Mises stress
result = solve(model);
figure
pdeplot3D(model,'ColorMapData',result.Displacement.uz)
title('z-displacement')
colormap('jet')

zdis = result.Displacement.uz;

assert((max(abs(zdis))-0.4597)<1e-4)