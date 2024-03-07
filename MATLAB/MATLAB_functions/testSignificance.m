function [p] = testSignificance(A,B,probA,probB,n,Nsim)

% This function tests statistical significance between two genotypes for
% behavioural actions by sampling from hypergeometric distribution

% arguments:
% A: a matrix of size genotypes x actions of # larvae AFTER the stimulus
% B: a matrix of size genotypes x actions of # larvae BEFORE the stimulus
% probA: A but probability instead of frequency
% probB: B but probability instead of frequency
% n: a vector stating # of larvae per genotype
% Nsim: number of simulations used

% control genotype is always in the 1st row

[x y] = size(A);
p = zeros(x-1,y);

for i = 2:x % first row is the control
    for j = 1:y
    theta_exp = probA(i,j)-probB(i,j)-(probA(1,j)-probB(1,j));
        for s = 1:Nsim
        Nout = 0;
        n_b_test = hygernd(n(1)+n(i),round(B(1,y))+round(B(i,y)),round(B(i,y)));
        n_b_control = n(1) + n(i) - n_b_test;
        n_a_test = hygernd(n(1)+n(i),round(A(1,y))+round(A(i,y)),round(A(i,y)));
        n_a_control = n(1) + n(i) - n_a_test;
        chi_test = n_a_test/n(i) - n_b_test/n(i);
        chi_control = n_a_control/n(1) - n_b_control/n(1);
        theta = chi_test - chi_control;
  
        if theta >= theta_exp;
            Nout = Nout+1;
        end
        p(i-1,j) = Nout/Nsim;
    end
    end
end