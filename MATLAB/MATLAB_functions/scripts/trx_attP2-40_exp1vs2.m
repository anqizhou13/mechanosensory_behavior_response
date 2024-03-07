%%
%%%%%%%%%%%%%%%%%%%%%%%
%%%%    Analysis raw from trx files
%%%% analyze difference within repetition of the experiments

% order of columns for action
% 1 = t
% 2 = run/crawl
% 3 = cast/bend
% 4 = stop
% 5 = hunch
% 6 = backup
% 7 = roll
%%%%%%%%%%%%%%%%%%%%%%%


% load data from the first group of experiments

% control split gal-4 attP2-40
dir_attP2_40_Ab40_exp1 = '/Volumes/TOSHIBA/t2/FCF_attP2-40@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp1';
[attP2_40_Ab40_exp1_freq, attP2_40_Ab40_exp1_prob, n_attP2_40_Ab40_exp1] = autotrx(dir_attP2_40_Ab40_exp1);

dir_attP2_40_Ab42_exp1 = '/Volumes/TOSHIBA/t2/FCF_attP2-40@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp1';
[attP2_40_Ab42_exp1_freq, attP2_40_Ab42_exp1_prob, n_attP2_40_Ab42_exp1] = autotrx(dir_attP2_40_Ab42_exp1);

% basin-2
dir_SS00739_Ab40_exp1 = '/Volumes/TOSHIBA/t2/GMR_SS00739@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp1';
[SS00739_Ab40_exp1_freq, SS00739_Ab40_exp1_prob, n_SS00739_40_Ab40_exp1] = autotrx(dir_SS00739_Ab40_exp1);

dir_SS00739_Ab42_exp1 = '/Volumes/TOSHIBA/t2/GMR_SS00739@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp1';
[SS00739_Ab42_exp1_freq, SS00739_Ab42_exp1_prob, n_SS00739_42_Ab40_exp1] = autotrx(dir_SS00739_Ab42_exp1);

% handle-b (Hb, LNb)
dir_SS00888_Ab40_exp1 = '/Volumes/TOSHIBA/t2/GMR_SS00888@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp1';
[SS00888_Ab40_exp1_freq, SS00888_Ab40_exp1_prob, n_SS00888_40_Ab40_exp1] = autotrx(dir_SS00888_Ab40_exp1);

dir_SS00888_Ab42_exp1 = '/Volumes/TOSHIBA/t2/GMR_SS00888@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp1';
[SS00888_Ab42_exp1_freq, SS00888_Ab42_exp1_prob, n_SS00888_42_Ab40_exp1] = autotrx(dir_SS00888_Ab42_exp1);

% griddle-2 (G2, LNa)
dir_SS00918_Ab40_exp1 = '/Volumes/TOSHIBA/t2/GMR_SS00918@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp1';
[SS00918_Ab40_exp1_freq, SS00918_Ab40_exp1_prob, n_SS00918_40_Ab40_exp1] = autotrx(dir_SS00918_Ab40_exp1);

dir_SS00918_Ab42_exp1 = '/Volumes/TOSHIBA/t2/GMR_SS00918@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp1';
[SS00918_Ab42_exp1_freq, SS00918_Ab42_exp1_prob, n_SS00918_42_Ab40_exp1] = autotrx(dir_SS00918_Ab42_exp1);

% Load second group of repeated experiments

% control split gal-4 attP2-40
dir_attP2_40_Ab40_exp2 = '/Volumes/TOSHIBA/t2/FCF_attP2-40@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp2';
[attP2_40_Ab40_exp2_freq, attP2_40_Ab40_exp2_prob, n_attP2_40_Ab40_exp2] = autotrx(dir_attP2_40_Ab40_exp2);

dir_attP2_40_Ab42_exp2 = '/Volumes/TOSHIBA/t2/FCF_attP2-40@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp2';
[attP2_40_Ab42_exp2_freq, attP2_40_Ab42_exp2_prob, n_attP2_40_Ab42_exp2] = autotrx(dir_attP2_40_Ab42_exp2);

% basin-2
dir_SS00739_Ab40_exp2 = '/Volumes/TOSHIBA/t2/GMR_SS00739@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp2';
[SS00739_Ab40_exp2_freq, SS00739_Ab40_exp2_prob, n_SS00739_40_Ab40_exp2] = autotrx(dir_SS00739_Ab40_exp2);

dir_SS00739_Ab42_exp2 = '/Volumes/TOSHIBA/t2/GMR_SS00739@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp2';
[SS00739_Ab42_exp2_freq, SS00739_Ab42_exp2_prob, n_SS00739_42_Ab40_exp2] = autotrx(dir_SS00739_Ab42_exp2);

% handle-b (Hb, LNb)
dir_SS00888_Ab40_exp2 = '/Volumes/TOSHIBA/t2/GMR_SS00888@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp2';
[SS00888_Ab40_exp2_freq, SS00888_Ab40_exp2_prob, n_SS00888_40_Ab40_exp2] = autotrx(dir_SS00888_Ab40_exp2);

dir_SS00888_Ab42_exp2 = '/Volumes/TOSHIBA/t2/GMR_SS00888@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp2';
[SS00888_Ab42_exp2_freq, SS00888_Ab42_exp2_prob, n_SS00888_42_Ab40_exp2] = autotrx(dir_SS00888_Ab42_exp2);

% griddle-2 (G2, LNa)
dir_SS00918_Ab40_exp2 = '/Volumes/TOSHIBA/t2/GMR_SS00918@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp2';
[SS00918_Ab40_exp2_freq, SS00918_Ab40_exp2_prob, n_SS00918_40_Ab40_exp2] = autotrx(dir_SS00918_Ab40_exp2);

dir_SS00918_Ab42_exp2 = '/Volumes/TOSHIBA/t2/GMR_SS00918@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp2';
[SS00918_Ab42_exp2_freq, SS00918_Ab42_exp2_prob, n_SS00918_42_Ab40_exp2] = autotrx(dir_SS00918_Ab42_exp2);

% total
% control split gal-4 attP2-40
dir_attP2_40_Ab40 = '/Volumes/TOSHIBA/t2/FCF_attP2-40@UAS_Abeta40_116';
[attP2_40_Ab40_freq, attP2_40_Ab40_prob, n_attP2_40_Ab40] = autotrx(dir_attP2_40_Ab40);

dir_attP2_40_Ab42 = '/Volumes/TOSHIBA/t2/FCF_attP2-40@UAS_Abeta42_117';
[attP2_40_Ab42_freq, attP2_40_Ab42_prob, n_attP2_40_Ab42] = autotrx(dir_attP2_40_Ab42);

% basin-2
dir_SS00739_Ab40 = '/Volumes/TOSHIBA/t2/GMR_SS00739@UAS_Abeta40_116';
[SS00739_Ab40_freq, SS00739_Ab40_prob, n_SS00739_40_Ab40] = autotrx(dir_SS00739_Ab40);

dir_SS00739_Ab42 = '/Volumes/TOSHIBA/t2/GMR_SS00739@UAS_Abeta42_117';
[SS00739_Ab42_freq, SS00739_Ab42_prob, n_SS00739_42_Ab40] = autotrx(dir_SS00739_Ab42);

% handle-b (Hb, LNb)
dir_SS00888_Ab40 = '/Volumes/TOSHIBA/t2/GMR_SS00888@UAS_Abeta40_116';
[SS00888_Ab40_freq, SS00888_Ab40_prob, n_SS00888_40_Ab40] = autotrx(dir_SS00888_Ab40);

dir_SS00888_Ab42 = '/Volumes/TOSHIBA/t2/GMR_SS00888@UAS_Abeta42_117';
[SS00888_Ab42_freq, SS00888_Ab42_prob, n_SS00888_42_Ab40] = autotrx(dir_SS00888_Ab42);

% griddle-2 (G2, LNa)
dir_SS00918_Ab40 = '/Volumes/TOSHIBA/t2/GMR_SS00918@UAS_Abeta40_116';
[SS00918_Ab40_freq, SS00918_Ab40_prob, n_SS00918_40_Ab40] = autotrx(dir_SS00918_Ab40);

dir_SS00918_Ab42 = '/Volumes/TOSHIBA/t2/GMR_SS00918@UAS_Abeta42_117';
[SS00918_Ab42_freq, SS00918_Ab42_prob, n_SS00918_42_Ab40] = autotrx(dir_SS00918_Ab42);
% clean up workspace and remove directory links
clear dir*

%% Visualize behavioral probability for time course all controls
% output line plots as results
% bending probability within control genotypes

plot(attP2_40_Ab40_exp2_prob(:,1),attP2_40_Ab40_exp2_prob(:,2))
hold on
plot(attP2_40_Ab42_exp2_prob(:,1),attP2_40_Ab42_exp2_prob(:,2))
hold on
plot(SS00918_Ab40_exp2_prob(:,1),SS00918_Ab40_exp2_prob(:,2))
hold on
plot(SS00918_Ab42_exp2_prob(:,1),SS00918_Ab42_exp2_prob(:,2))
title('Crawl')
xlabel('Seconds (s)')
%xlim([59 62])
ylabel('Behavioral Probability')
legend('attP2-40>Ab40_exp2','attP2-40>Ab42_exp2','SS00918>Ab40_exp2','SS00918>Ab42_exp2')

%% Compile data across time window for bar plot visualizations
%
%
[attP240_Ab40_freq_2s_a, attP240_Ab40_normprob_2s_a] = compileTime(...
    4,attP2_40_Ab40_freq,SS00739_Ab40_freq,SS00888_Ab40_freq,SS00918_Ab40_freq,n_Ab40,2,0)

[attP240_Ab42_freq_2s_a, attP240_Ab42_normprob_2s_a] = compileTime(...
    4,attP2_40_Ab42_freq,SS00739_Ab42_freq,SS00888_Ab42_freq,SS00918_Ab42_freq,n_Ab42,2,0)

[attP240_Ab40_freq_20s_a, attP240_Ab40_normprob_20s_a] = compileTime(...
    4,attP2_40_Ab40_freq,SS00739_Ab40_freq,SS00888_Ab40_freq,SS00918_Ab40_freq,n_Ab40,20,0)

[attP240_Ab42_freq_20s_a, attP240_Ab42_normprob_20s_a] = compileTime(...
    4,attP2_40_Ab42_freq,SS00739_Ab42_freq,SS00888_Ab42_freq,SS00918_Ab42_freq,n_Ab42,20,0)

[attP240_Ab40_exp1_freq_2s_a, attP240_Ab40_exp1_normprob_2s_a] = compileTime(...
    4,attP2_40_Ab40_exp1_freq,SS00739_Ab40_exp1_freq,SS00888_Ab40_exp1_freq,SS00918_Ab40_exp1_freq,n_Ab40_exp1,2,0)

[attP240_Ab42_exp1_freq_2s_a, attP240_Ab42_exp1_normprob_2s_a] = compileTime(...
    4,attP2_40_Ab42_exp1_freq,SS00739_Ab42_exp1_freq,SS00888_Ab42_exp1_freq,SS00918_Ab42_exp1_freq,n_Ab42_exp1,2,0)

[attP240_Ab40_exp1_freq_20s_a, attP240_Ab40_exp1_normprob_20s_a] = compileTime(...
    4,attP2_40_Ab40_exp1_freq,SS00739_Ab40_exp1_freq,SS00888_Ab40_exp1_freq,SS00918_Ab40_exp1_freq,n_Ab40_exp1,20,0)

[attP240_Ab42_exp1_freq_20s_a, attP240_Ab42_exp1_normprob_20s_a] = compileTime(...
    4,attP2_40_Ab42_exp1_freq,SS00739_Ab42_exp1_freq,SS00888_Ab42_exp1_freq,SS00918_Ab42_exp1_freq,n_Ab42_exp1,20,0)

[attP240_Ab40_exp2_freq_2s_a, attP240_Ab40_exp2_normprob_2s_a] = compileTime(...
    4,attP2_40_Ab40_exp2_freq,SS00739_Ab40_exp2_freq,SS00888_Ab40_exp2_freq,SS00918_Ab40_exp2_freq,n_Ab40_exp2,2,0)

[attP240_Ab42_exp2_freq_2s_a, attP240_Ab42_exp2_normprob_2s_a] = compileTime(...
    4,attP2_40_Ab42_exp2_freq,SS00739_Ab42_exp2_freq,SS00888_Ab42_exp2_freq,SS00918_Ab42_exp2_freq,n_Ab42_exp2,2,0)

[attP240_Ab40_exp2_freq_20s_a, attP240_Ab40_exp2_normprob_20s_a] = compileTime(...
    4,attP2_40_Ab40_exp2_freq,SS00739_Ab40_exp2_freq,SS00888_Ab40_exp2_freq,SS00918_Ab40_exp2_freq,n_Ab40_exp2,20,0)

[attP240_Ab42_exp2_freq_20s_a, attP240_Ab42_exp2_normprob_20s_a] = compileTime(...
    4,attP2_40_Ab42_exp2_freq,SS00739_Ab42_exp2_freq,SS00888_Ab42_exp2_freq,SS00918_Ab42_exp2_freq,n_Ab42_exp2,20,0)

%% Visualize behavioral probability for bar plot
% the two main matrixes are 4 x 6 for experiments with each
% Ab transgenes lines
% each column corresponds to one action: 
% run/crawl, cast/bend, stop, Bend, backup, roll
% each row corresponds to one gal-4:

% colors: B2, G-2, and Hb
color = [[0,0,0];[0,0.4,1];[0.9,0.2,0.5];[0.9,0.5,0]];
figure(1),hold on
subplot(3,2,1),hold on
m = length(color);
title('Bend (2s post-stimulus, normalized, all)');
for k = 1:m
    h = bar(k,attP240_Ab40_normprob_2s_a(k,5));
    set(h,'FaceColor',color(k,:));
end
newXticklabel = {'attP2-40>Ab1-40','SS00739>Ab1-40','SS00888>Ab1-40','SS00918>Ab1-40'};
set(gca,'XtickLabel',newXticklabel);
xlim([0.5 4.5]);
%ylim([0 0.2]);
xtickangle(45);
xlabel('Genotype');
ylabel('Cumulative Probability');

subplot(3,2,2), hold on
title('Bend (2s post-stimulus, normalized, all)');
for k = 1:m
    h = bar(k,attP240_Ab42_normprob_2s_a(k,5));
    set(h,'FaceColor',color(k,:));
end
newXticklabel = {'attP2-40>Ab1-42','SS00739>Ab1-42','SS00888>Ab1-42','SS00918>Ab1-42'};
set(gca,'XtickLabel',newXticklabel);
xlim([0.5 4.5]);
%ylim([0 0.2]);
xtickangle(45);
xlabel('Genotype');
ylabel('Cumulative Probability');

subplot(3,2,3), hold on
title('Bend (2s post-stimulus, normalized, exp1)');
for k = 1:m
    h = bar(k,attP240_Ab40_exp1_normprob_2s_a(k,5));
    set(h,'FaceColor',color(k,:));
end
newXticklabel = {'attP2-40>Ab1-40','SS00739>Ab1-40','SS00888>Ab1-40','SS00918>Ab1-40'};
set(gca,'XtickLabel',newXticklabel);
xlim([0.5 4.5]);
%ylim([0 0.2]);
xtickangle(45);
xlabel('Genotype');
ylabel('Cumulative Probability');

subplot(3,2,4), hold on
title('Bend (2s post-stimulus, normalized, exp1)');
for k = 1:m
    h = bar(k,attP240_Ab42_exp1_normprob_2s_a(k,5));
    set(h,'FaceColor',color(k,:));
end
newXticklabel = {'attP2-40>Ab1-42','SS00739>Ab1-42','SS00888>Ab1-42','SS00918>Ab1-42'};
set(gca,'XtickLabel',newXticklabel);
xlim([0.5 4.5]);
%ylim([0 1.2]);
xtickangle(45);
xlabel('Genotype');
ylabel('Cumulative Probability');

subplot(3,2,5), hold on
title('Bend (2s post-stimulus, normalized, exp2)');
for k = 1:m
    h = bar(k,attP240_Ab40_exp2_normprob_2s_a(k,5));
    set(h,'FaceColor',color(k,:));
end
newXticklabel = {'attP2-40>Ab1-40','SS00739>Ab1-40','SS00888>Ab1-40','SS00918>Ab1-40'};
set(gca,'XtickLabel',newXticklabel);
xlim([0.5 4.5]);
%ylim([0 0.2]);
xtickangle(45);
xlabel('Genotype');
ylabel('Cumulative Probability');

subplot(3,2,6), hold on
title('Bend (2s post-stimulus, normalized, exp2)');
for k = 1:m
    h = bar(k,attP240_Ab42_exp2_normprob_2s_a(k,5));
    set(h,'FaceColor',color(k,:));
end
newXticklabel = {'attP2-40>Ab1-42','SS00739>Ab1-42','SS00888>Ab1-42','SS00918>Ab1-42'};
set(gca,'XtickLabel',newXticklabel);
xlim([0.5 4.5]);
%ylim([0 1.2]);
xtickangle(45);
xlabel('Genotype');
ylabel('Cumulative Probability');