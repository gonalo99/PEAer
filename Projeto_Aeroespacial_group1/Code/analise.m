% ANALYSIS TOOL, GROUP 1 PAER 2020/21
% NEEDS TO BE IN THE SAME FOLDER/PATH AS adt.m, flightenvelope.m and
% noise.m
%% Run adt function
clear;
close all;
data=adt("BASE_10_01.json");

%% Design point results
WL=data.vehicle.mass*9.81/data.vehicle.components{6,1}.area_ref;
S=data.vehicle.components{6,1}.area_ref;
%% Print results
fprintf("---------\n");
fprintf("   New Iteration:\n");
fprintf("MTOW:%f\n",data.vehicle.mass);
fprintf("WL:%f\n",WL);
fprintf("Span:%f m^2\n",data.vehicle.components{6,1}.span);
fprintf("Mean chord:%f m\n",data.vehicle.components{6,1}.mean_chord);
fprintf("Area:%f m^2\n",S);


%% Flight envelope
AR=data.vehicle.components{6,1}.aspect_ratio;
CLaa=5.7296/( 1+(5.7296/(pi*0.8*AR)) );
c=data.vehicle.components{6,1}.mean_chord;
vc=84;
MTOW=round(data.vehicle.mass);
flightenvelope(CLaa,c,WL,vc,MTOW);%if this fails, its because Vc is too low



%% Co2 emissions
% battery specs
spec_energy=300;
cycles=714;
recharge_emissions=295.8; %gCO2-eq/(kWh) 
spec_prod_emissions=24.36;

% fuel specs
spec_fuel_emissions=30.4;
spec_fuel_energy=43.7;
% battery emission computations
battery_mass=data.vehicle.components{10,1}.mass;
battery_energy=battery_mass*spec_energy/1000; %kwh
prod_emissions=battery_energy*spec_prod_emissions/1000; %ton CO2
use_emissions=battery_energy*cycles*recharge_emissions/1e6;

% fuel emissions computations
fuel_mass=data.vehicle.components{11,1}.mass;
fuel_emissions=fuel_mass*spec_fuel_energy*spec_fuel_emissions/1000000*cycles;
fprintf("---------\n");
fprintf("   Co2 emissions:\n");
fprintf("Battery mass: %f kg\n",battery_mass);
fprintf("Battery production: %f ton CO2\n",prod_emissions);
fprintf("Battery use: %f ton Co2\n",use_emissions);
fprintf("Fuel emissions: %f ton Co2\n",fuel_emissions);
fprintf("Total emissions: %f ton Co2\n",fuel_emissions+prod_emissions+use_emissions);

%% Drag
rho=1.0555825;
CD0=data.vehicle.components{4, 1}.segments{4, 1}.base_drag_coefficient+data.vehicle.components{6, 1}.segments{4, 1}.base_drag_coefficient;
CL=(MTOW*9.81)/(0.5*rho*vc^2*S);
CDi=CL^2/(pi*0.8*AR);
CD=CD0+CDi;
D=0.5*rho*vc^2*S*CD;
LD=(MTOW*9.81)/D;
fprintf("---------\n");
fprintf("   DRAG:\n");
fprintf("CD0:%f\n",CD0);
fprintf("CDi:%f\n",CDi);
fprintf("Drag:%f N\n",D);
fprintf("L/D:%f\n",LD);

%% Rotor and Rotor blade sizing

DL=891;%disk loading W/A
V_tip=0.4*340;
N_rotors=8;
total_rotor_area=MTOW*9.81/DL;
R_rotor=sqrt(total_rotor_area/N_rotors/pi);

fprintf("---------\n");
fprintf("   Rotor sizing:\n");
fprintf("Rotor Radius:%f\n",R_rotor);
fprintf("Rotor Diameter:%f\n",2*R_rotor);
fprintf("Rotor RPM:%f\n",60*V_tip/pi/R_rotor/2);

 
NB=6;
sigma=0.1;
c_blade=sigma*total_rotor_area/NB/R_rotor/N_rotors;
fprintf("Blade chord:%f\n",c_blade);


%% Noise emission
t_c_max=0.12;
Phr=170; %power per rotor



% run function
SPL=noise(NB,V_tip,R_rotor,c_blade,t_c_max,N_rotors,Phr,MTOW,sigma);


fprintf("---------\n");
fprintf("   Noise emissions:\n");
fprintf("SPL at 500 ft: %f db\n",SPL);















