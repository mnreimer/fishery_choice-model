%% EXPECTED CATCH DATA
% * Filename: ExpCatch.m
% * Authors: Matt Reimer
% * Created: 07/07/17
% * Purpose: Generate expected catch data that is used in the fishery choice 
% model. 
% 
% *Description*: This file generates simulated expected catch data to be 
% used in place of the empirical estimates of expected catch that will be used 
% in the final model.
% 
% *Model*: Let $e_{j,s,t}$ denote a normally-distributed random variable 
% associated with fishery $j$, species $s$, and time $t$. Let $\mu_{j,s,t}$ and 
% $\sigma_s$ denote the mean and variance, respectively. We model catch as:
% 
% $$C_{j,s,t} = exp\{ e_{j,s,t} \} $$
% 
% so that catch has a lognormal distribution with mean:
% 
% $$EC_{j,s,t} = exp\{ \mu_{j,s,t} + \sigma_s/2 \} $$
% 
% For simplicity, I assume that the variance $\sigma_s$ is constant over 
% time and across fisheries, while the mean $\mu_{j,s,t}$ for each species and 
% fishery is assumed to evolve exogenously and independently according to a continuous-valued 
% Markov process:
% 
% $$\mu_{j,s,t+1} = \bar{\mu}_{j,s} + \gamma(\mu_{j,s,t} -\bar{\mu}_{j,s}) 
% + \varepsilon_{j,s,t}$$
% 
% where $\bar{\mu}_{j,s}$ is a fishery and species time-invariant mean, $\gamma$ 
% is a parameter that dictates how fast the time series will revert to its overall 
% mean, and $\varepsilon$ is a normally-distributed random variable.
%
%% Arguments
% * |fish| = Number of fisheries, excluding fishery 1 (port)
% * |S| = Number of species
% * |T| = Time horizon  
% * |mubar| = Mean of $e$ in each fishery 
% * |var| = Variance of $e$, assumed to be constant across fisheries 
% * |epspar| = Mean and std of random shock (epsilon)
% * |mu0| = Initial values for mu
% * |gamma| = Mean reversion parameter
% * |N| = Number of vessels
% * |shocks| = Number of shocks to catch for calculating mean
%
%% Preliminaries
    clc, clear
    close all
    directory = 'C:\Users\mnrei\Dropbox\Projects\nprb\fishery_choice-model';
    cd(directory)
    addpath(genpath(directory))
    
%% Parameters
    m = parameters;             % Model parameters (see function file: parameters)
    
%% Generate random shocks $(\varepsilon_{j,s,t})$
    rng(3,'twister');                   % set seed to reproduce results
    seed = rng;   
    rng(seed);
    % Vector of random shocks
    eps = m.catch.epspar(1) + m.catch.epspar(2)*...
        randn(m.model.fish,m.model.S,m.model.T);   
    
%% Generate means $(\mu_{j,s,t})$
    % Preallocate mu matrix (for speed)
    mu = zeros(m.model.fish,m.model.S,m.model.T+1); 
    % Initial value of mu
    mu(:,:,1)=m.catch.mu0; 
    % mu follows a Markov process
    for t=1:m.model.T
        mu(:,:,t+1) = m.catch.mubar + m.catch.gamma*(mu(:,:,t) - ...
            m.catch.mubar) + eps(:,:,t);
    end
    mu(:,:,1)=[];               % Drop "burn-in" initial values
    
%% Generate expected catch $(EC_{j,s,t})$
    EC = exp(mu + m.catch.var/2);
    EC = [zeros(1,m.model.S,m.model.T) ; EC];  % Zero catch at fishery=1 (port)

%% Generate catchability coefficients, by vessel and species
    rng(1), q = rand(m.model.S,m.model.N);            

%% Generate random catch errors
    e = err(mu,m);

%% Save data
    save('data\ExpCatch.mat','EC','q','e');
    
%% Plots
    % Expected Catch
    figure(1)
        for i=1:m.model.fish
            subplot(m.model.fish,1,i)
            plot(1:m.model.T,squeeze(EC(i+1,:,:)));
            title(['Fishery ',num2str(i+1)]);
            ylabel('Expected Catch'); xlabel('Time Period');
            legend('Species 1','Species 2');
            xticks(1:m.model.T); xlim([1 m.model.T]); grid on
        end
        
    % Random Catch
    figure(2)
        k=1;
        for i=1:m.model.fish
            for j=1:m.model.S
                subplot(m.model.fish,m.model.S,k)
                x=exp(squeeze(e(i+1,j,:,:))');
                boxplot(x);
                title(['Fishery ',num2str(i+1), '; Species ', num2str(j)]);
                ylabel('Catch'); xlabel('Time Period'); grid on
                k = k+1;
            end
        end

    % Catchability coefficients
    figure(3)
        boxplot(q);
        title('Catchability Coefficients, by vessel');
        ylabel('q'); xlabel('Vessel'); 
        yticks(0:0.1:1); ylim([0 1]); grid on

%% Functions
function [e] = err(mu,m)
% err returns a vector of shocks to catch (e) for each fishery, time, and
% species. Purpose is for approximating the expectation of the value
% function, using Monte Carlo quadrature.

% n = sample size from distribution (i.e. number of values to compute
% expectation)
% mu = mean for each species in each fishery 

% Parameters %
    mean = repmat(mu,[1 1 1 m.model.N]);  % Mean of random variable e
    std = m.catch.var^0.5;        % Stdv of random variable e

% Generate random catch %
    rng(4,'twister');           % set seed to reproduce results
    seed = rng;   
    rng(seed);
    e = zeros(m.model.fish,m.model.S,m.model.T,m.model.N,m.model.shocks);
    for j=1:m.model.shocks
        e(:,:,:,:,j)= normrnd(mean,std);   
    end
    % Shock=-Inf (Catch==0) at fishery=1 (port)
    e = [-Inf*ones(1,m.model.S,m.model.T,m.model.N,m.model.shocks) ; e];         
end

    