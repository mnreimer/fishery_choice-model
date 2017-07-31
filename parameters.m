function [m] = parameters()
%% Parameters
% This function contains the default parameter values that are used in the 
% fishery choice simulation.

    m = struct('model',{},'signal',{},'state',{},'fspace',{},'catch',{});
    
% Model Parameters %
    N = 5;                              % Number of vessels
    S = 2;                             % Number of species
    fish = 4;                           % Number of fisheries, excluding "no fishing" (i.e., port)
    p = ones(S,1);                      % Exvessel Price vector, by species
    c = [0; 5*ones(fish,1)];            % Cost of fishing, by fishery (fish=1 is no fishing, no cost)
    T = 10;                             % Model horizon
    shocks = 1;                        % Number of shock realizations to average over in forward simulation
    m(1).model = struct('N',N,'S',S,'fish',fish,'p',p,'c',c,'T',T,'shocks',shocks,'actions',(1:1:fish+1));
    
% Signalling errors %
    % For the extreme value distribution (e): Mean(e) = u + sigma*Euler's constant; Var(e) = sigma^2*(pi^2/6) %
    u = 0;                          % u is the location parameter
    sigma = 5;                      % sigma is the scale parameter
    rng(1), signal = evrnd(u,sigma,fish+1,T,N);
    m(1).signal = signal;

% State and action space %
    TAC = 1*ones(1,S);                         % Fleetwide TACs for each species
    Imax = [TAC, T];                            % Initial remaining fleet allocation--i.e., TACs--and last time period
    Imin = [zeros(1,S), 1];                     % Lower bound for remaining allocation and first time period
    n = 5*ones(1,S+1);                          % Number of interpolation nodes (for each species-specific quota prices)                   
    fspace = fundefn('cheb',n,Imin,Imax);       % Function approximation structure
    Icoord = funnode(fspace);                   % Collocation nodes (structure)
    m(1).state = struct('Imax',Imax,'Imin',Imin,'n',n,'TAC',TAC);
    m.state(1).Icoord = Icoord;
    m(1).fspace = fspace;

    % Expected Catch %
    mubar = ones(fish,S);              % Mean of e in each fishery (manually adjust based on # of fisheries & species)
    var = 3;                            % variance of e 
    epspar = [0 1];                     % Mean and std of random shock (epsilon)--assumed to be the same for all species
    mu0 = mubar;                        % Initial values for mu
    gamma = 0.7;                        % Mean reversion parameter
    m(1).catch = struct('mubar',mubar,'var',var,'epspar',epspar,'mu0',mu0,'gamma',gamma);
    
% % Pack parameter structure %
% %--------------------------%
%     m.actions = (1:1:fish+1)';          % Action space
%     m.state = {Icoord I Imax};          % State space          
%     m.space = {fish sp};                % Spatial/species parameters 
%     m.params = {p c signal};            % Reward parameters
%     m.horizon = {T};                    % Time/Error horizon parameters
%     m.vessels = {N};
%     m.expcatch = {mubar var epspar mu0 gamma shocks};   % Expected catch parameters
end