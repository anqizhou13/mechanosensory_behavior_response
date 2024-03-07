function p = pvalueFromDataConvergence(n_B, N_B, n_A, N_A,n_B_ref, N_B_ref, n_A_ref, N_A_ref)
% 8 arguments avec uniquement des nombres de larves
% A = after, B = before
% n_ = nombre de larves qui font l'action N_ = nombre de larves totales
% _ref = controle, sans ref = g�notype d'int�r�t

% On calcule ici la fr�quence du comportement
r_B = n_B./N_B;
r_A = n_A./N_A;

r_B_ref = n_B_ref./N_B_ref;
r_A_ref = n_A_ref./N_A_ref;

% Ratio exp�rimental de larves qui font l'action chez le g�notype d'int�r�t
% par rapport au contr�le (en corrigeant les probabilit�s par la baseline)
TH_exp = (r_A_ref - r_B_ref) - (r_A - r_B);

% On r�p�te 50 000 fois la simulation hyperg�om�trique
% N_tot  = 5e5;
N_tot  = 1e4;

% Before stimulus = baseline, on calcule les nombre de larves
N_pop_tot = N_B + N_B_ref; % toute la population suivie pendant la baseline
n_bend_on = n_B + n_B_ref; % toute la population qui fait l'action pendant la baseline; pour le bend, haut, mais environ nul pour le hunch

% uses hypergeometric law to generate random number that represents the
% number of larvae from genotype of interest
x = random('hyge', N_pop_tot, n_bend_on, N_B, N_tot, 1);
% x is a N by 1 table, in which input are N_pop_tot, n_bend_on, n_B
% on g�n�re un nombre x N_tot fois (ici, 500 000) , d�crivant le nombre de larves qui hunch pendant la
% baseline ET appartiennent au g�notype d'int�r�t
% NB. boule gagnante = larve qui hunch
% On tire N_B boules = nombre de larves du g�notype d'int�r�t, et on
% regarde si elles hunch d'apr�s la loi "commune" de proba de bend

% on �value, � partir de la simulation, la part d'action de la baseline qui
% devrait correspondre au contr�le
y = n_bend_on - x;

% figure;histogram(x);hold on; histogram(y)
% et on calcule le ratio de larves d'int�r�t qui font l'action pendant la
% baseline
r_B_gen = x./N_B;
% et le ratio de larves contr�les qui font l'action pendant la baseline
r_B_ref_gen = y./N_B_ref;

% histogram(r_B_gen);hold on;histogram(r_B_ref_gen)

% After : m�me calcul
N_pop_tot = N_A + N_A_ref;
n_bend_on = n_A + n_A_ref;

x = random('hyge', N_pop_tot, n_bend_on, N_A ,  N_tot,1 ) ; 
y = n_bend_on - x;

r_A_gen = x./N_A;
r_A_ref_gen = y./N_A_ref;

% On g�n�re la diff�rence corrig�e de larves qui ont fait l'action en
% calculant la diff�rence entre ce qui est observ� chez le contr�le entre
% la baseline et la stimulation, et ce qui est observ� chez le g�notype
% d'int�r�t. Si chaque �chantillon suit la m�me loi initiale, on devrait
% avoir une diff�rence corrig�e �gale � TH_exp

TH_gen =  (r_A_ref_gen - r_B_ref_gen) - (r_A_gen - r_B_gen);

% TH_diff = TH_gen - TH_exp;

II = TH_gen <= TH_exp;
pII = sum(II)./N_tot;

JJ = TH_gen >= TH_exp;
pJJ = sum(JJ)./N_tot;

p = min(pII, pJJ);
end





