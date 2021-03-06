# RERUM Data
### Contains data for Monte Carlo analysis and policy simulations.

***
Note that data files are too big to be hosted on GitHub. Data files can be produced by the scripts `monte_carlo_data` and `policy_simulations`.

***

Data             | Description
-----------------|-------------
estimates random multi_start 1-200 28-Oct-2019    | Data, estimates, and parameter values from 200 samples from the dgp with random draws from the parameter space. Produced in Part 1 of `monte_carlo_data.m`.
estimates scenarios 1-500 01-Nov-2019             | Data and estimates from 500 samples from the dgp with predetermined values of the parameter space. Produced in Part 2 of `monte_carlo_data.m`.
numerical policy simulations 1-200 04-Nov-2019    | Numerical simulation results for TAC reduction and hot-spot closure policies from 200 samples of the dgp, per policy scenario. Produced in `policy_simulations.m`.

***
