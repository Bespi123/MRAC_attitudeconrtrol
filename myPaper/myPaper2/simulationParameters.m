motor.Jrw = 2.55e-05;
motor.b   = 1.00023e-05;
motor.c   = 0.000435786;

sat.Jraw  = [3.084,0.082,0.054;
             0.082,3.132,0.016;
             0.054,0.016,3.540]*1E-3;
sat.Rcm   = [-1.44,-0.23,-2.58]*1E-3'; %mm
sat.Ms    = 2.86; %kg

J = sat.Jraw+sat.Ms*skew(sat.Rcm)*skew(sat.Rcm )'; 
sat.J     = [J(1,1),J(2,2),J(3,3),J(1,2),J(1,3),J(2,3)];
sat.G     = [0,0,-9.81]';
sat.alpha = 2.95E-2;
dist.satTorque = [0;0;-3.96]*1E-03;

init.q    = [1,0,0,0];
init.w    = [0,0,0];
init.W_rw = [0,0,0];

setPoint.angd = [10,0,0]';
setPoint.wd   = [0,0,0]';

%feedback.P = [1,1,1]*1E-4;
%feedback.K = [1,1,1]*1E-4;
%feedback.P = [5.96905656601576	6.48701365101876	8.85407661632956];
%feedback.K = [6.82183920772324	7.61096661085329	9.78296885219207];
% feedback.P = [17.212713101026280   14.277678164926066   16.568608615790430];    
% feedback.K = [3.131835209743309    2.615500003601612    1.810171272344507];
feedback.P = [15.4318650394591 16.7482612383003 7.91545474858242];    
feedback.K = [3.09672280852135 5.29871200300818 1.22819168358399];