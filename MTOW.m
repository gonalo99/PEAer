clear
clc

data = adt('examples/project-01.json');
%data = adt('BASE_10_01.json');
disp("MTOW = " + data.vehicle.mass)

