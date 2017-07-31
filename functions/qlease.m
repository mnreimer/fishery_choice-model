%% Quota lease price function
% * Filename: qlease.m
% * Authors: Matt Reimer
% * Created: 07/08/17
% * Purpose: Function that returns the expected lease price for a given set
% of state variables.
%
%% Description
% The function |qlease| returns the expected end-of-season quota lease
% price given a common set of exogenous state variables.
%
% In any period $t$, fishers are assumed to form a common forecast of the 
% end-of-season quota prices, and based on that forecast, the fishery that 
% is optimal is chosen. We assume that forecasts are based on fleet-wide 
% information that is observed at the beginning of the period prior to 
% making a fishery decision. In this sense, fishers observe the aggregate 
% state of the world and update their expectations over future quota 
% prices. 
%
% Suppose the information vector ${\mathbf{I}_{t}}$ is composed of $d$ 
% variables, so that we want to approximate $\mathbf{w} \left( 
% {\mathbf{I}_{t}}; \eta \right)$ over a $d$-dimensional interval:
%
% $$ {\mathbf{I}} = \left\{ \left(I_1,...,I_d \right) | {a_i \geq I_i 
% \geq b_i}, i=1,...,d \right\}.$$ 
%
% Let $\phi_{s,i} (I_i) = \left[\phi_{s,i,1}(I_i),...,\phi_{s,i,n_{i}}(I_i)
% \right]$ for $i=1,...,d$ and $s=1,...,S$ be an $n_i$-degree row vector of
% univariate basis functions defined on $\left[ a_i,b_i \right]$ for 
% approximating $w_s$. Then an approximant for $w_s$ can be written as:
%
% $$ \hat{w}_s\left(I_1,...,I_d \right) = \left[ \phi_{s,1}(I_1) \otimes 
% \cdot \cdot \cdot \otimes \phi_{s,d}(I_d)  \right]\eta_s, \quad 
% \forall s=1,...,S, $$
%
% where $\eta_s$ is an $N \times 1$ column vector of collocation 
% coefficients and $N=\prod_{i=1}^{d}n_i$.
%
% To start, we assume that $I_t = [Z_t, t]$, where $Z_t$ denotes 
% fleet-wide cumulative catch up to period $t$;
%
function w = qlease(eta,I,m)
%% Input arguments:
% * |eta| = a $N \times S$ matrix of collocation coefficients;
% * |I| = a $NS \times d$ matrix of collocation nodes;
% * |m| = a structural array containing parameter values
%
%% Output arguments:
% * |w| = a $N \times S$ matrix of expected quota lease price;
%
%% Notes:
% * The vector $\eta$ will be provided by a Matlab solver (e.g., |fsolve|).
% * See the CompEcon toolbox documentation for details on the function
% |funeval| (Miranda and Fackler, 2005).
%
%% Calculate price for each species
    w = zeros(size(I,1),m.model.S);
    for s = 1:m.model.S
        % Evaluate approximated quota price for species s at collocation nodes
        w(:,s) = funeval(eta(:,s),m.fspace,I);  
    end        
end



