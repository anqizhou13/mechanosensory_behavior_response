function [TH_exp,TH_gen, p] = pvalue_convergence_hunch(n_B, N_B, n_A, N_A,n_B_ref, N_B_ref, n_A_ref, N_A_ref)
fprintf('lets make easier assumptions \n');

r_B = n_B./N_B;
r_A = n_A./N_A;

r_B_ref = n_B_ref./N_B_ref;
r_A_ref = n_A_ref./N_A_ref;

TH_exp = (r_A_ref - r_B_ref) - (r_A- r_B);
% fprintf()

N_tot  = 5e5;
% TH_gen = zeros(N_tot, 1);


%before
N_pop_tot = N_B + N_B_ref;
n_bend_on = n_B + n_B_ref;
%x = hypernd(N_pop_tot,n_bend_on, n_B ) ; 
% x = random('hyge', N_pop_tot,0, n_B, N_tot,1 ) ; 
% y = n_bend_on - x;

x =zeros(N_tot, 1);
y =zeros(N_tot, 1);

r_B_gen = x./N_B;
r_B_ref_gen = y./N_B_ref;

%after
N_pop_tot = N_A + N_A_ref;
n_bend_on = n_A + n_A_ref;
%x = hypernd(N_pop_tot,n_bend_on, n_A ) ; 
x = random('hyge', N_pop_tot,n_bend_on, n_A ,  N_tot,1 ) ; 
y = n_bend_on - x;

r_A_gen = x./N_A;
r_A_ref_gen = y./N_A_ref;

TH_gen =  (r_A_ref_gen - r_B_ref_gen) - (r_A_gen- r_B_gen);


II= TH_gen <= TH_exp;
pII = sum(II)./N_tot;

JJ =  TH_gen >= TH_exp;
pJJ = sum(JJ)./N_tot;

p = min(pII, pJJ);
if p<0.001
   fprintf('p-value = %f\n',p);
   fprintf('super small p-value to be written as p<0.001 \n');
   
else
    fprintf('p-value = %f\n', p);
end

