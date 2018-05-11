function [ output_args ] = Untitled( input_args )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

Eta_plus = .95;
Eta_minus=.95;
Eta_epsilon=.95;
Eta_g=.95;
Kappa_plus_max=200;
Kappa_plus_min=50;
Kappa_minus_max=200;
Kappa_minus_min=50;
Eps_max=1000;
Kappa_g_max=200;
Kappa_g_min=50;
alpha = [0;0;0;0;0;0;525; 609; 645; 688; 701; 700; 677; 585; 320;
    321;245; 0; 0; 0; 0; 0; 0; 0];

T = 24;
intcon = [];
for n = 1: 3*T 
   intcon = [intcon; 6*T + n];
end

Aeq = [];
beq = [];
Aeq_temp = zeros(T, 9*T);
beq_temp = zeros(T, 1);
for t = 1:T
    Aeq_temp(t,t) = 1;
    Aeq_temp(t, T+t) = - Eta_minus;
    Aeq_temp(t, 3*T+t) = 1;
    Aeq_temp(t, 4*T+t) = 1;
    beq_temp(t) = alpha(t);
end

Aeq = [Aeq; Aeq_temp];
beq = [beq; beq_temp];
Aeq_temp = zeros(T, 9*T);
beq_temp = zeros(T, 1);
for t = 1:T
   Aeq_temp(t, 3*T+t) = - Eta_g;
   Aeq_temp(t, 5*T+t) = 1;
end
Aeq = [Aeq; Aeq_temp];
beq = [beq; beq_temp];

Aeq_temp = zeros(T, 9*T);
beq_temp = zeros(T, 1);
for t = 2:T
    Aeq_temp(t, 2*T+t) = 1;
    Aeq_temp(t, 2*T+t-1) = -Eta_epsilon;
    Aeq_temp(t, t) = - Eta_plus;
    Aeq_temp(t, T+t) = 1;
end
for t = 1:T
    Aeq_temp(t, 2*T+1) = 1;
    Aeq_temp(t, 1) = - Eta_plus;
    Aeq_temp(t, T+1) = 1;
end
Aeq = [Aeq; Aeq_temp];
beq = [beq; beq_temp];

A = [];
b = [];
A_temp = zeros(T, 9*T); % kappa_plus constraints
b_temp = zeros(T, 1);
for t = 1:T
    A_temp(t, t) = 1;
    A_temp(t, 6*T + t) = - Kappa_plus_max;
end
A = [A; A_temp];
b = [b; b_temp];

A_temp = zeros(T, 9*T);
b_temp = zeros(T, 1);
for t = 1:T
   A_temp(t, t) = -1;
   A_temp(t, 6*T +t) = Kappa_plus_min;
end
A = [A; A_temp];
b = [b; b_temp];

A_temp = zeros(T, 9*T); %kappa_minus constraints
b_temp = zeros(T, 1);
for t = 1:T
    A_temp(t, T+t) = 1;
    A_temp(t, 7*T + t) = - Kappa_minus_max;
end
A = [A; A_temp];
b = [b; b_temp];

A_temp = zeros(T, 9*T);
b_temp = zeros(T, 1);
for t = 1:T
   A_temp(t, T+t) = -1;
   A_temp(t, 7*T +t) = Kappa_minus_min;
end
A = [A; A_temp];
b = [b; b_temp];

A_temp = zeros(T, 9*T); %kappa_g constraints
b_temp = zeros(T, 1);
for t = 1:T
    A_temp(t, 3*T+t) = 1;
    A_temp(t, 8*T + t) = - Kappa_g_max;
end
A = [A; A_temp];
b = [b; b_temp];

A_temp = zeros(T, 9*T);
b_temp = zeros(T, 1);
for t = 1:T
   A_temp(t, 3*T+t) = -1;
   A_temp(t, 8*T +t) = Kappa_g_min;
end
A = [A; A_temp];
b = [b; b_temp];

A_temp = zeros(T, 9*T);
b_temp = zeros(T, 1);
for t= 1:T
   A_temp(t, 6*T+t) = 1;
   A_temp(t, 7*T+t) = 1;
   b_temp(t) = 1;
end
A = [A; A_temp];
b = [b; b_temp];

ub = [Kappa_plus_max * ones(T, 1);Kappa_minus_max * ones(T, 1);  Eps_max * ones(T, 1); Kappa_g_max * ones(T, 1);
        alpha ; 300*ones(T,1); ones(3*T, 1)];
lb= zeros(9*T, 1);
f = [zeros(5*T, 1); -1*ones(T, 1); zeros(3*T, 1)];
x = intlinprog(f, intcon, A, b, Aeq, beq, lb, ub);
disp(x);


end

