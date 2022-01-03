%% Vertical climb
altitude = [100 150 200 250 300];
speed = [4 5 6 7 8];

%Speed changes rows and altitude changes columns
MTOW = [2551.6747 2568.0334 2584.6204 2601.4413 2618.5018;...
        2548.1782 2562.7184 2577.4381 2592.3412 2607.4316;...
        2545.8596 2559.1997 2572.6908 2586.336 2600.1382;...
        2544.2116 2556.7011 2569.3235 2582.0812 2594.9765;...
        2542.9813 2554.8375 2566.8138 2578.9125 2591.1356];
    
surf(altitude, speed, MTOW);

%% Cruise
velocity = [];