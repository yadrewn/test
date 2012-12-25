function NEW5_ode()
tspan=[0:0.0039:0.99];
x0=[0.5;-0.5];
[t,x]=ode45(@NEW5_funsys,tspan,x0);
f = figure('Visible','off');
plot (t,x(:,[1,2]),'lineWidth',3);
grid on;
legend('x`1','x`2','x`3');
print('-dbmp','-r80','graf.bmp');

