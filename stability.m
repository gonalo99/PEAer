function [vehicle] = stability(vehicle, mission)
%% Constants
    g = 9.81; % m/s^2

%% Longitudinal stability
    [wing, ~] = find_by_type(vehicle.components, 'wing.main');
    [htail, ~] = find_by_type(vehicle.components, 'wing.htail');
    
    de_da = 0.25;
    cl_a_w = wing.airfoil.lift_slope_coefficient / (1 + wing.airfoil.lift_slope_coefficient/(pi * wing.oswald_efficiency * wing.aspect_ratio));
    cl_a_ht = htail.airfoil.lift_slope_coefficient / (1 + htail.airfoil.lift_slope_coefficient/(pi * htail.oswald_efficiency * htail.aspect_ratio));
    
    Sht = htail.aspect_ratio * htail.mean_chord^2;
    Sw = wing.aspect_ratio * wing.mean_chord^2;
    
    Cm_alpha_wing = cl_a_w * wing.x_w / wing.mean_chord;
    Cm_alpha_tail = cl_a_ht * (1 - de_da) * (htail.l_ht + wing.x_w) * Sht / (Sw * wing.mean_chord);
    
    vehicle.Cm_alpha = Cm_alpha_wing - Cm_alpha_tail;
    
%% Directional stability
    [fus, ~] = find_by_type(vehicle.components, 'fuselage');
    [vs, ~] = find_by_type(vehicle.components, 'wing.vtail');
    
    c_L = 2 * vehicle.mass* g/ ((wing.aspect_ratio * wing.mean_chord^2) * mission.segments{3}.density * mission.segments{3}.velocity^2);
    estimate = 0.724 + 3.06 *  vs.aspect_ratio * vs.mean_chord^2 / ((wing.aspect_ratio * wing.mean_chord)^2*wing.mean_chord) / 2 + 0.4 * wing.z_w/(fus.diameter/2) + 0.009*wing.aspect_ratio; 
    
    cn_b_fus = -1.3 * (fus.diameter/2)^2*pi*fus.length / ((wing.aspect_ratio * wing.mean_chord)^2*wing.mean_chord);
    cn_b_wing = c_L^2 * (1/(4*pi*wing.aspect_ratio));
    cn_b_vs = htail.l_ht * vs.aspect_ratio * vs.mean_chord^2 / ((wing.aspect_ratio * wing.mean_chord)^2*wing.mean_chord) * vs.airfoil.lift_slope_coefficient * estimate;
    
    vehicle.Cn_b = cn_b_fus + cn_b_wing + cn_b_vs;
end

