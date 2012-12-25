function dxdt=NEW5_funsys(t,x)
a=0.9;
dxdt=zeros(2, 1);
dxdt(1)=16*x(2);
dxdt(2)=256*a*(1/16-x(1)^2)*x(2)-1/16*x(1);

