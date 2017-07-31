%% Excess Demand Function
% * Filename: xdemand.m
% * Authors: Matt Reimer
% * Created: 07/08/17
% * Purpose: Function that returns the fleet-wide annual excess demand for
% species-specific quota.
%
%% Description
% The function |xdemand| computes the fleet-wide annual excess demand for
% quota, defined as the sum of all annual catches minus the sum of all
% quota allocations. 
%
% Specifically, $e_{i,s}(\mathbf{w})=q_{i,s}(\mathbf{w})-
% \omega_{i,s}$ is individual $i$'s excess-demand function for species 
% $s$ for a given quota-price vector $\mathbf{w}$, which is comprised of
% $q_{i,s}$ and $\omega_{i,s}$: $i$'s annual catch and allocation, 
% respectively. Annual catch is calculated as
%
% $$ q_{i,s} = \sum_{t \in T} C_{i,t}(a_{i,t}^*(\mathbf{w})) $$
%
% where $C_{i,t}(a)$ is $i$'s catch in period $t$ for fishery $a$, and
% $a_{i,t}^*(\mathbf{w})$ is $i$'s optimal fishery choice given quota price
% $\mathbf{w}$.
%
function [out1,out2] = xdemand(eta,I0,m)
%% Input arguments:
% * |eta| = a $NS \times 1$ vector of collocation coefficients;
% * |I0| = a $NS \times d$ matrix of collocation nodes;
% * |m| = a structural array containing parameter values
%
%% Output arguments:
% * |out1| = a $S \times 1$ vector of average excess demand values.
% * |out2| = a vector of average end-of-season quota prices
%
%
%% Notes:
% The vector $\eta$ will be provided by a Matlab solver (e.g., |fsolve|).
%
%% Preliminaries   
    c = zeros(m.model.N,m.model.S);     % Catch
    t0 = I0(end);       % Starting time period
    out1 = zeros(1,m.model.S);          % Excess demand
    out2 = zeros(1,m.model.S);          % End-of-season quota price
    
%% Calculate 
    for k = 1:m.model.shocks
        % Initial vector of information
        I = I0;             
        for t=t0:m.model.T
            % Forecast of quota prices $w$ given $I$
            w = qlease(eta,I,m);
            % Obtain annual catch for each individual
            for i=1:m.model.N
                % Find optimal fishery
                fstar = vmax(t,i,w,m);           
                % Obtain catch associated with optimal fishery choice
                c(i,:) = func('g',fstar,t,i,k,[],m);
            end
            % Update next period's I:
            I = I + [(sum(c(:,:),1)),1];
        end
        out1 = I(:,1:end-1) + out1;
        out2 = qlease(eta,I,m) + out2;
    end
    % Average excess demand: catch minus allocation
    out1 = (out1/m.model.shocks) - m.state.TAC;
    % Average end-of-season quota prices
    out2 = out2/m.model.shocks;                       
end


