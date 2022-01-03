clear;
clc;
close all

%% Constants
global constants;
constants.g = 9.81; % m/s^2

%% Load project file
data = load_project('examples/project-01.json');

data.mission.segments{2}.velocity = 8;

%% Add missing mission segment and vehicle component parameters
data.mission = build_mission(data.mission);
data.vehicle = build_vehicle(data.mission, data.vehicle);

%% Plot mission profile
%plot_mission(data.mission);

%% Mission analyses
data.vehicle = aero_analysis(data.mission, data.vehicle);
[data.mission, data.vehicle] = mass_analysis(data.mission, data.vehicle, data.energy);
%data.vehicle = design_space_analysis(data.mission, data.vehicle, data.energy);

%% Stability analysis
data.vehicle = stability(data.vehicle, data.mission);

%%
disp("MTOW = " + data.vehicle.mass);
disp("Battery = " + data.vehicle.components{8}.mass);
