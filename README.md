# Dynamic Mediation with Time Trend Effect based on Bayesian Inference
This project propose a dynamic mediation effect of
is based on a rstan package to do parameter estimate.
The data that we can observe combines X(Dependent Variable), Y(Independent Variable), M(Mediator). And the rest of coeffients need to be estimated.
## Three Models
1. time trend in the a path
    - formula   
      $M_{it} = a_tX_{it} + e_{1it} $    
      $Y_{it} = c_tX_{it} + b_tM_{it} + e_{2it} $   
      $a_t = \alpha_0 + \alpha_1a_{t-1} + \alpha_2t +v_{1t} $  
      $b_t = \beta_0 + \beta_1a_{t-1} +v_{2t} $  
      $c_t = \gamma_0 + \gamma_1a_{t-1} +v_{3t} $ 

    i means every participant, t means every timestamp. The effect of a/b/c just have variances from time while M and Y have variances from both time and individuals. We first generate data with R and then establish a model in a stan file. And this model contains two layers of loops.

2. time trend in the b path
   
3. time trend in the both a and b path


