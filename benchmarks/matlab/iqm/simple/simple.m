%% Below you find a template script, allowing to run parameter estimation
% using command-line arguments. It is constructed in such a way that you can
% use the "cell-mode" of the MATLAB editor, increasing the ease of use.
% The cell-model can be enabled by choosing in the menu "Cell->Enable Cell Mode".
% Once enabled, you can execute the yellow cells in this script (assuming you
% opened it in the MATLAB editor) by selecting them and pressing "Ctrl-Enter".
clc; clear all;close all
run ../../src/'IQMtools V1.2.2.2'/IQMlite/installIQMlite.m;
run ../../src/'IQMtools V1.2.2.2'/IQMpro/installIQMpro.m;
run ../../src/'IQMtools V1.2.2.2'/installIQMtools.m;

%% LOAD THE PROJECT
lv = IQMprojectSB('project');

%% DISPLAY INFORMATION ABOUT THE PROJECT
IQMinfo(lv);

%% KEEP THE ORIGINAL PROJECT UNCHANGED
lvopt = lv;

%% COMPARE MEASUREMENTS WITH MODEL
IQMcomparemeasurements(lv);

%% SELECT PARAMETERS/STATES TO ESTIMATE AND CORRESPONDING BOUNDS
% Global parameters
% Names         Lower bounds  Upper bounds
paramdata = {
'a' 0.0 10.0
'b' 0.0 3.0
};

% Local (experiment dependend) parameters
% Names         Lower bounds  Upper bounds
paramdatalocal = {
};

% Initial conditions (always experiment dependend)
% Names         Lower bounds  Upper bounds
icdata = {
    'x1'  0.0 1.5
    'x2'  0.0 1.5
};


%% DEFINE THE ESTIMATION INFORMATION (STRUCTURE)
estimation = [];

% Model and experiment settings
estimation.modelindex = 1;
estimation.experiments.indices = [2];%, 2, 3, 4];
estimation.experiments.weight = [1];%, 1, 1, 1];

% Optimization settings
estimation.optimization.method = 'simplexIQM';
estimation.optimization.options.maxfunevals = 2000;

% Integrator settings
estimation.integrator.options.abstol = 1e-006;
estimation.integrator.options.reltol = 1e-006;
estimation.integrator.options.minstep = 0;
estimation.integrator.options.maxstep = Inf;
estimation.integrator.options.maxnumsteps = 1000;

% Flags
estimation.displayFlag = 2; % show iterations and final message
estimation.scalingFlag = 2; % scale by mean values
estimation.timescalingFlag = 0; % do not apply time-scaling
estimation.initialconditionsFlag = 1; % do use initial conditions from measurement data (if available)

% Always needed (do not change ... unless you know what you do)
estimation.parameters = paramdata;
estimation.parameterslocal = paramdatalocal;
estimation.initialconditions = icdata;

% Run estimation
output = IQMparameterestimation(lvopt,estimation)
% Get optimized project
lvopt = output.projectopt;

%% COMPARE OPTIMIZED PROJECT WITH MEASUREMENTS
IQMcomparemeasurements(lvopt,estimation.modelindex);
display(lvopt);
% %% ANALYSIS OF RESIDUALS
% IQManalyzeresiduals(lvopt,estimation);

% %% RUN A-POSTERIORI IDENTIFIABILITY ANALYSIS (only considering global variables)
% IQMidentifiability(lvopt,paramdata(:,1));

%% RUN SOME FIT ANALYSIS
% (after completion click in lower figure to remove outliers, corresponding
%  to local minima. Finish with "Enter")
% output = IQMparameterfitanalysis(lvopt,estimation);

%% FITANALYSIS EVALUATION
% IQMfaboxplot(output);
% IQMfahist(output);
% IQMfacorr(output);
% IQMfaclustering(output);
% IQMfadetcorr(output);
% IQMfasigncorr(output);
