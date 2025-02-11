%**************************************************************************
% AUTHOR: Brayan Espinoza 22/10/2020
% DESCRIPTION: 
% This program perform the parameter estimation for a brushless motor.
% IMPORTANT: This program is based by the idnlgreydemol developed by 
% Mathworks. The comand to open this example and see in more detail is 
% shown:
%       openExample('ident/idnlgreydemo1')
% 
% *************************************************************************

% 1. Read data from experiments
ProcessData;
close all;

%Constant values
kt = 5.83627000;
J  = 0.01057160;
B  = 0.14193000;
Kc = 0.35576200;
L  = 0.00282862;
R  = 0.35397200;
Ke = 0.01995400;

% 2. Represent the estimation data as an |iddata| object. 
z = iddata(y, u, 0.1, 'Name', 'Reaction-Wheel');

%%
% 3. Specify input and output signal names, start time and time units. 
z.InputName = 'Voltage';
z.InputUnit =  'V';
z.OutputName = {'Angular velocity','current'};
z.OutputUnit = {'rad/s','A'};
z.Tstart = 0;
z.TimeUnit = 's';

%%
% 4. Plot the data.
%
% The data is shown in two plot windows.
figure('Name', [z.Name ': Voltage input -> Angular velocity']);
plot(z(:, 1, 1));   % Plot first input-output pair (Voltage -> Angular position).
figure('Name', [z.Name ': Voltage input -> Current']);
plot(z(:, 2, 1));   % Plot first input-output pair (Voltage -> Angular position).

%% Linear Modeling of the DC-Motor
% 1. Represent the DC motor structure in a function
% The BrushlessModel function is called and described below.
%
% 2. Represent the Brushless motor dynamics using an |idnlgrey| object.
FileName      = 'BrushelessModel';         % File describing the model structure.
Order         = [2 1 2];                   % Model orders [ny nu nx].
Parameters    = [kt; J; B; Kc; L; R; Ke];  % Initial parameters. Np = 7.
InitialStates = [0; 0];                    % Initial initial states.
Ts            = 0;                         % Time-continuous system.
nlgr = idnlgrey(FileName, Order, Parameters, InitialStates, Ts, ...
                'Name', 'Reaction-wheel');
% In practice, there are disturbances that affect the outputs. An
% |idnlgrey| model does not explicitly model the disturbances, but assumes
% that these are just added to the output(s). Thus, |idnlgrey| models are
% equivalent to Output-Error (OE) models. Without a noise model, past
% outputs do not influence prediction of future outputs, which means that
% predicted output for any prediction horizon k coincide with simulated
% outputs.

%%
% 3. Specify input and output names, and units.
set(nlgr, 'InputName', 'Voltage', 'InputUnit', 'V',    ...
          'OutputName',{'Angular velocity','current'}, ...
          'OutputUnit', {'rad/s','A'},'TimeUnit', 's');

%%
% 4. Specify names and units of the initial states and parameters.
nlgr = setinit(nlgr, 'Name', {'Angular velocity' 'Current'});
nlgr = setinit(nlgr, 'Unit', {'rad/s' 'A'});
nlgr = setpar(nlgr, 'Name', {'kt' 'J' 'B' 'Kc' 'L' 'R' 'Ke'});
nlgr = setpar(nlgr, 'Unit', {'Nm/A' 'Kgm^2' 'N*m*s' 'N*m*s' 'H' 'R' 'V/(Rad/s)'});

%% 
% 5. View the initial model.
size(nlgr)   % Get basic information about the model.

% b. View the initial states and parameters
nlgr.InitialStates(1)
nlgr.Parameters(2)

% c. Retrieve information for all initial states or model parameters in one
% call.
getinit(nlgr, 'Fixed')
getpar(nlgr, 'Min')

% d. Obtain basic information about the object:
nlgr

% Use |get| to obtain more information about the model properties. The
% |idnlgrey| object shares many properties of parametric linear model
% objects.
get(nlgr)

%% Performance Evaluation of the Initial DC-Motor Model
%
% Before estimating the parameters |tau| and |k|, simulate the output of
% the system with the parameter guesses using the default differential
% equation solver (a Runge-Kutta 45 solver with adaptive step length
% adjustment). The simulation options are specified using the
% "SimulationOptions" model property.
%
% 1. Set the absolute and relative error tolerances to
% small values (|1e-6| and |1e-5|, respectively).
nlgr.SimulationOptions.AbsTol = 1e-6;
nlgr.SimulationOptions.RelTol = 1e-5;

%%
% 2. Compare the simulated output with the measured data.
%
% |compare| displays both measured and simulated outputs of one or more
% models, whereas |predict|, called with the same input arguments, displays
% the simulated outputs.
%
% The simulated and measured outputs are shown in a plot window.
compare(z, nlgr);

%% Parameter Estimation
% Estimate the parameters and initial states using |nlgreyest|, which is a
% prediction error minimization method for nonlinear grey box models. The
% estimation options, such as the choice of estimation progress display,
% are specified using the "nlgreyestOptions" option set.
nlgr = setinit(nlgr, 'Fixed', {true true}); % Estimate the initial states.
opt = nlgreyestOptions('Display', 'on');
nlgr = nlgreyest(z, nlgr, opt);

%% Performance Evaluation of the Estimated DC-Motor Model
% 1. Review the information about the estimation process.
%
% This information is stored in the |Report| property of the
% |idnlgrey| object. The property also contains information about how the
% model was estimated, such as solver and search method, data set, and why
% the estimation was terminated.
nlgr.Report
fprintf('\n\nThe search termination condition:\n')
nlgr.Report.Termination

%%
% 2. Evaluate the model quality by comparing simulated and measured
% outputs.
compare(z, nlgr);

%%
%
% 3. Compare the performance of the |idnlgrey| model with a second-order
% ARX model.
na = [2 2; 2 2];
nb = [2; 2];
nk = [1; 1];
dcarx = arx(z, [na nb nk]);
compare(z, nlgr, dcarx);

%%
% 4. Check the prediction errors.
%
% The prediction errors obtained are small and are centered around zero
% (non-biased).
pe(z, nlgr);

%%
%
% 5. Check the residuals ("leftovers").
%
% Residuals indicate what is left unexplained by the model and are small
% for good model quality. Use the |resid| command to view the correlations
% among the residuals. The first column of plots shows the autocorrelations
% of the residuals for the two outputs. The second column shows the
% cross-correlation of these residuals with the input "Voltage". The
% correlations are within acceptable bounds (blue region).
%
figure('Name',[nlgr.Name ': residuals of estimated model']);
resid(z,nlgr);

%%
% 6. Plot the step response.
%
% A unit input step results in an angular position showing a ramp-type 
% behavior and to an angular velocity that stabilizes at a constant level.
figure('Name', [nlgr.Name ': step response of estimated model']);
step(nlgr);

%%
%
% 7. Examine the model covariance.
%
% You can assess the quality of the estimated model to some extent by
% looking at the estimated covariance matrix and the estimated noise
% variance. A "small" value of the |(i, i)| diagonal element of the
% covariance matrix indicates that the |i|:th model parameter is important
% for explaining the system dynamics when using the chosen model structure.
% Small noise variance (covariance for multi-output systems) elements are
% also a good indication that the model captures the estimation
% data in a good way.
getcov(nlgr)
nlgr.NoiseVariance

%%
%
% For more information about the estimated model, use |present| to
% display the initial states and estimated parameter values, and 
% estimated uncertainty (standard deviation) for the parameters.
present(nlgr);
