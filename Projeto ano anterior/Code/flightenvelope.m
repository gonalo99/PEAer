function [va,vb,vd,n_max,n_min,delta_n,K,miu]=flightenvelope(CLaa,c,WS,vc,MTOW)


%% defs
v_max=160;
%va=91;
rho=1.05816;

CLMAX=1.83;

vd=1.5*vc;
step=.01;


MTOW=MTOW/0.45359237;
n_max=2.1+(24000/(MTOW+10000));
n_min=-0.4*n_max;
va=sqrt(n_max/(0.5*rho*CLMAX/WS));
va=round(va);
vb=sqrt(abs(n_min)/(0.5*rho*CLMAX/WS));
vb=round(vb);
%% contas (flight env)
x1=[0:step:va];
x2=[0:step:vb];
x3=linspace(va,vd,(vd-va)/step);
x4=[vb:step:vc];
x5=[vd,vd];
x6=[vc:step:vd];
%y1=0.000431*x1.^2;
y1=(0.5*rho*CLMAX/WS)*x1.^2;
y2=-(0.5*rho*CLMAX/WS)*x2.^2;
y3=n_max*ones(size(x3));
y4=n_min*ones(size(x4));
y5=[0,n_max];
y6= vd*n_min/(vd-vc)+x6*(-n_min/(vd-vc));

%% contas (gust envelope)

miu=2*WS/(rho*c*CLaa*9.81);
K=0.88*miu/(5.3+miu);
delta_n=0.5*rho*CLaa*K/WS;
%delta_n=0.001371

%0 a va
u=[20.12,-20.12,15.24,-15.24,7.62,-7.62];
%x_gust=zeros(6,vd/step);

for i=1:6
    if i<3
         x_gust_1(i,:)=linspace(0,va,va/step);
         y_gust_1(i,1:va/step)=1+delta_n*u(i)*x_gust_1(i,1:va/step); 
         
    elseif i<5
        x_gust_2(i-2,:)=linspace(0,vc,vc/step);
        y_gust_2(i-2,1:vc/step)=1+delta_n*u(i)*x_gust_2(i-2,1:vc/step); 
        
    else
        x_gust_3(i-4,:)=linspace(0,vd,vd/step);
        y_gust_3(i-4,:)=1+delta_n*u(i)*x_gust_3(i-4,:);
        
    end
end

%% Final gust lines 
v0=[va va vc vc vd];
n0=[y_gust_1(1,va/step) y_gust_1(2,va/step) y_gust_2(1,vc/step) y_gust_2(2,vc/step) y_gust_3(1,vd/step) ];
v1=[vc vc vd vd vd];
n1=[y_gust_2(1,vc/step) y_gust_2(2,vc/step) y_gust_3(1,vd/step) y_gust_3(2,vd/step) y_gust_3(2,vd/step)];

x_final_gust=zeros(4,(vd-va)/step);

for i=1:4
    x_final_gust(i,1:(v1(i)-v0(i))/step)=linspace(v0(i),v1(i),(v1(i)-v0(i))/step);
    m(i)=(n1(i)-n0(i))/(v1(i)-v0(i));
    y_final_gust(i,1:length(x_final_gust(i,:)))= m(i) .* x_final_gust(i,:) + n0(i)-m(i)*v0(i) ;
end

%% plots
figure();
plot(x1,y1,'r','LineWidth',2);
hold on;
plot(x2,y2,'r','LineWidth',2);
hold on;
plot(x3,y3,'b');
hold on;
plot(x4,y4,'b');
hold on;
plot(x5,y5,'r','LineWidth',2);
hold on;
plot(x6,y6,'b');
hold on;

for i=1:2
    hold on;
    plot(x_gust_1(i,:),y_gust_1(i,:),'k');
    plot(x_gust_2(i,:),y_gust_2(i,:),'k');
    plot(x_gust_3(i,:),y_gust_3(i,:),'k');
end

for i=1:5
    hold on;
    plot([v0(i) v1(i)],[n0(i) n1(i)],'k');
    
end

%% Combined envelope (UP)
VN_X=linspace(va,vd,(vd-va)/step);
VN_Y=zeros(1,(vd-va)/step);

% candidate vectors
candidates=zeros(5,(vd-va)/step);
% x3 - nmax
candidates(1,:)=y3;

% x_gust_2
if y_gust_2(1,va/step)<n_max
    candidates(2,1:(vc-va)/step)=y_gust_2(1,va/step+1:vc/step);
else
    candidates(2,1:(vc-va)/step)=zeros(1,vc/step-va/step);
end

% x_gust_3
candidates(3,:)=y_gust_3(1,va/step+1:vd/step);
% x_final_gust 1
if y_gust_1(1,va/step)<n_max
    candidates(4,(va-va)/step+1:(vc-va)/step)=y_final_gust(1,1:(vc-va)/step);
    candidates(5,(vc-va)/step+1:(vd-va)/step)=y_final_gust(3,1:(vd-vc)/step);
else
    candidates(4,(va-va)/step+1:(vc-va)/step)=zeros(1,(vc-va)/step);
    candidates(5,(vc-va)/step+1:(vd-va)/step)=zeros(1,(vd-vc)/step);
end

for i=1:(vd-va)/step
     VN_Y(i)=candidates(1,i);
    for j=2:5
       if VN_Y(i)<candidates(j,i)
           VN_Y(i)=candidates(j,i);       
       end
    end
    
end

Y_END(1)=VN_Y(i);
plot(VN_X,VN_Y,'r','LineWidth',2);

%% %% Combined envelope (DOWN)
VN_X=linspace(vb,vd,(vd-vb)/step);
VN_Y=zeros(1,(vd-vb)/step);

% candidate vectors
candidates_down=zeros(6,(vd-vb)/step);
% x4 - nmin
candidates_down(1,1:(vc-vb)/step+1)=y4;
% x6 vc-vd
candidates_down(1,(vc-vb)/step+2:(vd-vb)/step)=y6(3:length(y6));
% x_gust_1
candidates_down(2,1:(va-vb)/step)=y_gust_1(2,vb/step+1:va/step);
% x_gust_2
candidates_down(3,1:(vc-vb)/step)=y_gust_2(2,vb/step+1:vc/step);
% x_gust_3
candidates_down(4,:)=y_gust_3(2,vb/step+1:vd/step);
% x_final_gust 2
candidates_down(5,(va-vb)/step+1:(vc-vb)/step)=y_final_gust(2,1:(vc-va)/step);
% x_final_gust 4
candidates_down(6,(vc-vb)/step+1:(vd-vb)/step)=y_final_gust(4,1:(vd-vc)/step);


for i=1:(vd-vb)/step
     VN_Y(i)=candidates_down(1,i);
    for j=2:6
       if VN_Y(i)>=candidates_down(j,i)
           VN_Y(i)=candidates_down(j,i);             
       end
    end
    
end
Y_END(2)=VN_Y(i);
plot(VN_X,VN_Y,'r','LineWidth',2)
plot([vd vd],Y_END,'r','LineWidth',2);

axis([0 v_max -2 4.5]);
xlabel("V (m/s)");
ylabel("n");
title("Combined Flight and Gust envelope");
end
