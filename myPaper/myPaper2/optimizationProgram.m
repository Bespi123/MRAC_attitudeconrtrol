no_var = 6;  %number of variables
lb = [0 0 0 0 0 0]; % lower bound
up = [Inf Inf Inf Inf Inf Inf]; % high bound
initial = [1E-1 1E-1 1E-1 1E-1 1E-1 1E-1];
%initial = [2.5 2.5 2.5 2.5 2.5 2.5]*1E1;

global initialConditions parameters 
initialConditions = [];
parameters        = [];

%GA OPTIONS
%try
ga_opt = gaoptimset('Display','off','Generations',10,'PopulationSize',100, ...
    'InitialPopulation',initial,'PlotFcns',@gaplotbestf);
obj_fun = @(k)myObjectiveFunction(k);

[k,bestblk] = ga((obj_fun),no_var,[],[],[],[],lb,up,[],ga_opt);

disp(k);