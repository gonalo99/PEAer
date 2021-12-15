function [T, a, p, rho]=atmosphere_relations(h)
    
    l=length(h);
    p0=101325;
    rho0=1.225;
    t0=288.15*ones(l,1);
    T0=288.15;
    AUX=ones(l,1);
    gamma=1.4;
    R=287.052874;
    
    T=t0-0.0065.*h;
    p=p0.*(AUX-0.0065.*h/T0).^5.25588;
    rho=rho0.*(AUX-0.0065.*h/T0).^4.25588;
    a=sqrt(gamma*R.*T);
    
end