%% MAIN FILE
% * Filename: main.m
% * Authors: Matt Reimer
% * Created: 07/07/17
% * Purpose: Execute code to solve the rational expectations fishery choice
% model.


%% Preliminaries
    clc, clear
    close all
    directory = 'C:\Users\mnrei\Dropbox\Projects\nprb\fishery_choice-model';
    cd(directory)
    addpath(genpath(directory))
    delete(gcp('nocreate'))
    parpool(2)
    
%% Parameters and Data 
    m = parameters;                    % Model parameters (see function file: parameters)
    load('data/ExpCatch.mat','EC','q','e')      % Expected catch, catchability, and catch (shocks) data 
    m.catch(1).data = struct('EC',EC,'q',q,'e',e);
    %[fish,sp,T] = size(EC);                     % Number of fisheries (including port), species, and periods

%% Evaluate (for testing)
    eta0 = zeros(m.model.S*prod(m.fspace.n),1);         % Arbitrary collocation coefficients
    I0 = gridmake(m.state.Icoord);                       % Collocation nodes in grid form (matrix)
    I0(:,end) = floor(I0(:,end));                       % Round t to lowest integer
    
    % Equilibrium
    tic;
    out = equil(eta0,I0,m);
    toc;
    % Quota price
    I0 = I0(2,:);
    n = prod(m.fspace.n);               % Total # of nodes to evaluate
    eta0 = reshape(eta0,n,m.model.S); 
    w = qlease(eta0,I0,m);
    
%%  Solve for collocation nodes
    options = optimset('Display','iter');
    f = @(eta)equil(eta,I0,m);
    % Find the values of eta such that f=0 by minimizing least squares
    eta = fminsearch(f,eta0,options); 
    
    
    
    