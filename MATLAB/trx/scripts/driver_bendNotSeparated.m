%% This scripts extracts the probability, cumulative probability of actions,
% and transitions between actions
% of all larvae from the trx.mat file, during the different time windows

% Statistical test used for comparing cumulative proba (non corrected) :
% Chi2 test

% CHANGE : adresses, timewindows, couleursconditions, conditionstoplot,
% actionstoplot, couleursactions

adresses={
'/Volumes/TOSHIBA/t2/FCF_attP2-40@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp3/20210412_140055/';
'/Volumes/TOSHIBA/t2/FCF_attP2-40@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp3/20210528_105138/';
'/Volumes/TOSHIBA/t2/FCF_attP2-40@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp3/20210917_101927/';
'/Volumes/TOSHIBA/t2/FCF_attP2-40@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp3/20210920_135644/';
'/Volumes/TOSHIBA/t2/FCF_attP2-40@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp3/20210921_145409/';
'/Volumes/TOSHIBA/t2/GMR_61D08@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20201029_155214/';
'/Volumes/TOSHIBA/t2/GMR_61D08@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20201029_160132/';
'/Volumes/TOSHIBA/t2/GMR_61D08@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20201029_161048/';
'/Volumes/TOSHIBA/t2/GMR_61D08@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20201030_134404/';
'/Volumes/TOSHIBA/t2/GMR_61D08@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20201030_135101/';
'/Volumes/TOSHIBA/t2/GMR_61D08@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20201030_135950/';
'/Volumes/TOSHIBA/t2/GMR_61D08@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20201030_140811/';
'/Volumes/TOSHIBA/t2/GMR_61D08@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20201103_153710/';
'/Volumes/TOSHIBA/t2/GMR_61D08@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20201106_112713/';
'/Volumes/TOSHIBA/t2/GMR_61D08@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20201106_113256/';
'/Volumes/TOSHIBA/t2/GMR_SS00739@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp3/20210412_143101/';
'/Volumes/TOSHIBA/t2/GMR_SS00739@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp3/20210420_134403/';
'/Volumes/TOSHIBA/t2/GMR_SS00739@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp3/20210423_142647/';
'/Volumes/TOSHIBA/t2/GMR_SS00739@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp3/20210917_103841/';
'/Volumes/TOSHIBA/t2/GMR_SS00739@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp3/20210920_145635/';
'/Volumes/TOSHIBA/t2/GMR_SS00739@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp3/20210921_150639/';
'/Volumes/TOSHIBA/t2/GMR_SS00739@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp3/20210413_152434/';
'/Volumes/TOSHIBA/t2/GMR_SS00739@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp3/20210420_132541/';
'/Volumes/TOSHIBA/t2/GMR_SS00739@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp3/20210423_143250/';
'/Volumes/TOSHIBA/t2/GMR_SS00739@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp3/20210917_104816/';
'/Volumes/TOSHIBA/t2/GMR_SS00739@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp3/20210920_150531/';
'/Volumes/TOSHIBA/t2/GMR_SS00739@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp3/20210921_150113/';
'/Volumes/TOSHIBA/t2/GMR_SS00739@w1118/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20210917_103100/';
'/Volumes/TOSHIBA/t2/GMR_SS00739@w1118/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20210920_144947/';
'/Volumes/TOSHIBA/t2/GMR_SS00739@w1118/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20210921_151254/';
'/Volumes/TOSHIBA/t2/GMR_SS00888@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp3/20210412_135205/';
'/Volumes/TOSHIBA/t2/GMR_SS00888@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp3/20210420_135956/';
'/Volumes/TOSHIBA/t2/GMR_SS00888@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp3/20210423_134257/';
'/Volumes/TOSHIBA/t2/GMR_SS00888@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp3/20210917_110518/';
'/Volumes/TOSHIBA/t2/GMR_SS00888@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp3/20210920_143009/';
'/Volumes/TOSHIBA/t2/GMR_SS00888@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp3/20210921_152519/';
'/Volumes/TOSHIBA/t2/GMR_SS00888@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp3/20210412_141841/';
'/Volumes/TOSHIBA/t2/GMR_SS00888@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp3/20210420_140555/';
'/Volumes/TOSHIBA/t2/GMR_SS00888@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp3/20210423_133733/';
'/Volumes/TOSHIBA/t2/GMR_SS00888@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp3/20210917_111547/';
'/Volumes/TOSHIBA/t2/GMR_SS00888@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp3/20210920_142415/';
'/Volumes/TOSHIBA/t2/GMR_SS00888@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp3/20210921_153203/';
'/Volumes/TOSHIBA/t2/GMR_SS00888@w1118/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20210917_105837/';
'/Volumes/TOSHIBA/t2/GMR_SS00888@w1118/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20210920_143942/';
'/Volumes/TOSHIBA/t2/GMR_SS00888@w1118/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20210921_151823/';
'/Volumes/TOSHIBA/t2/GMR_SS00918@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp3/20210412_133348/';
'/Volumes/TOSHIBA/t2/GMR_SS00918@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp3/20210420_135359/';
'/Volumes/TOSHIBA/t2/GMR_SS00918@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp3/20210423_134901/';
'/Volumes/TOSHIBA/t2/GMR_SS00918@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp3/20210917_113003/';
'/Volumes/TOSHIBA/t2/GMR_SS00918@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp3/20210920_140845/';
'/Volumes/TOSHIBA/t2/GMR_SS00918@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp3/20210921_154457/';
'/Volumes/TOSHIBA/t2/GMR_SS00918@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp3/20210412_131541/';
'/Volumes/TOSHIBA/t2/GMR_SS00918@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp3/20210420_133848/';
'/Volumes/TOSHIBA/t2/GMR_SS00918@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp3/20210423_135503/';
'/Volumes/TOSHIBA/t2/GMR_SS00918@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp3/20210917_113610/';
'/Volumes/TOSHIBA/t2/GMR_SS00918@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp3/20210920_141407/';
'/Volumes/TOSHIBA/t2/GMR_SS00918@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp3/20210921_153952/';
'/Volumes/TOSHIBA/t2/GMR_SS00918@w1118/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20210917_112240/';
'/Volumes/TOSHIBA/t2/GMR_SS00918@w1118/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20210920_140209/';
'/Volumes/TOSHIBA/t2/GMR_SS00918@w1118/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20210921_155109/';
'/Volumes/TOSHIBA/t2/FCF_attP2-40@w1118/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20210920_134508/';
'/Volumes/TOSHIBA/t2/FCF_attP2-40@w1118/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20210921_144206/';
'/Volumes/TOSHIBA/t2/FCF_attP2@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20201026_143013/';
'/Volumes/TOSHIBA/t2/FCF_attP2@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20201026_144502/';
'/Volumes/TOSHIBA/t2/FCF_attP2@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20201026_145347/';
'/Volumes/TOSHIBA/t2/FCF_attP2@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20201027_143218/';
'/Volumes/TOSHIBA/t2/FCF_attP2@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20201027_143950/';
'/Volumes/TOSHIBA/t2/FCF_attP2@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20201029_145530/';
'/Volumes/TOSHIBA/t2/FCF_attP2@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20201029_150401/';
'/Volumes/TOSHIBA/t2/FCF_attP2@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20201030_111127/';
'/Volumes/TOSHIBA/t2/FCF_attP2@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20201030_111916/';
'/Volumes/TOSHIBA/t2/FCF_attP2@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20201103_144436/';
'/Volumes/TOSHIBA/t2/FCF_attP2@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20201103_145318/';
'/Volumes/TOSHIBA/t2/FCF_attP2@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20201106_102914/';
'/Volumes/TOSHIBA/t2/FCF_attP2@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20201109_103426/';
'/Volumes/TOSHIBA/t2/FCF_attP2@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20210705_150206/';
'/Volumes/TOSHIBA/t2/FCF_attP2@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20210706_151121/';
'/Volumes/TOSHIBA/t2/FCF_attP2@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20210709_125518/';
'/Volumes/TOSHIBA/t2/FCF_attP2@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20201026_150310/';
'/Volumes/TOSHIBA/t2/FCF_attP2@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20201026_150925/';
'/Volumes/TOSHIBA/t2/FCF_attP2@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20201026_151544/';
'/Volumes/TOSHIBA/t2/FCF_attP2@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20201027_151024/';
'/Volumes/TOSHIBA/t2/FCF_attP2@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20201027_151749/';
'/Volumes/TOSHIBA/t2/FCF_attP2@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20201029_143741/';
'/Volumes/TOSHIBA/t2/FCF_attP2@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20201029_144607/';
'/Volumes/TOSHIBA/t2/FCF_attP2@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20201030_130844/';
'/Volumes/TOSHIBA/t2/FCF_attP2@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20201103_152602/';
'/Volumes/TOSHIBA/t2/FCF_attP2@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20201109_104456/';
'/Volumes/TOSHIBA/t2/FCF_attP2@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20210705_151017/';
'/Volumes/TOSHIBA/t2/FCF_attP2@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20210706_151744/';
'/Volumes/TOSHIBA/t2/FCF_attP2@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20210709_130323/';
'/Volumes/TOSHIBA/t2/GMR_20B01@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20201103_151502/';
'/Volumes/TOSHIBA/t2/GMR_20B01@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20201106_105754/';
'/Volumes/TOSHIBA/t2/GMR_20B01@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20201106_110616/';
'/Volumes/TOSHIBA/t2/GMR_20B01@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20201109_104214/';
'/Volumes/TOSHIBA/t2/GMR_20B01@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20201109_104758/';
'/Volumes/TOSHIBA/t2/GMR_20B01@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20210705_152528/';
'/Volumes/TOSHIBA/t2/GMR_20B01@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20210706_153021/';
'/Volumes/TOSHIBA/t2/GMR_20B01@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20210709_131812/';
'/Volumes/TOSHIBA/t2/GMR_20B01@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20201103_154636/';
'/Volumes/TOSHIBA/t2/GMR_20B01@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20201106_111314/';
'/Volumes/TOSHIBA/t2/GMR_20B01@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20201106_111913/';
'/Volumes/TOSHIBA/t2/GMR_20B01@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20201109_105416/';
'/Volumes/TOSHIBA/t2/GMR_20B01@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20201109_110036/';
'/Volumes/TOSHIBA/t2/GMR_20B01@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20210705_151741/';
'/Volumes/TOSHIBA/t2/GMR_20B01@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20210706_152356/';
'/Volumes/TOSHIBA/t2/GMR_20B01@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20210709_131047/';
'/Volumes/TOSHIBA/t2/GMR_20B01@w1118/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20210705_153053/';
'/Volumes/TOSHIBA/t2/GMR_20B01@w1118/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20210706_153554/';
'/Volumes/TOSHIBA/t2/GMR_20B01@w1118/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20210709_132541/';
'/Volumes/TOSHIBA/t2/GMR_57C10@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20201026_154327/';
'/Volumes/TOSHIBA/t2/GMR_57C10@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20201026_155155/';
'/Volumes/TOSHIBA/t2/GMR_57C10@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20201026_155859/';
'/Volumes/TOSHIBA/t2/GMR_57C10@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20201027_145136/';
'/Volumes/TOSHIBA/t2/GMR_57C10@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20201027_145815/';
'/Volumes/TOSHIBA/t2/GMR_57C10@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20201030_113048/';
'/Volumes/TOSHIBA/t2/GMR_57C10@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20201030_113921/';
'/Volumes/TOSHIBA/t2/GMR_57C10@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20201026_152535/';
'/Volumes/TOSHIBA/t2/GMR_57C10@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20201026_153231/';
'/Volumes/TOSHIBA/t2/GMR_57C10@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20201027_152528/';
'/Volumes/TOSHIBA/t2/GMR_57C10@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20201027_153159/';
'/Volumes/TOSHIBA/t2/GMR_57C10@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20201030_132714/';
'/Volumes/TOSHIBA/t2/GMR_57C10@UAS_Abeta42_117/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20201030_133529/';
'/Volumes/TOSHIBA/t2/GMR_61D08@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20201029_152202/';
'/Volumes/TOSHIBA/t2/GMR_61D08@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20201029_153748/';
'/Volumes/TOSHIBA/t2/GMR_61D08@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20201029_154452/';
'/Volumes/TOSHIBA/t2/GMR_61D08@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20201030_114832/';
'/Volumes/TOSHIBA/t2/GMR_61D08@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20201030_115609/';
'/Volumes/TOSHIBA/t2/GMR_61D08@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20201030_120522/';
'/Volumes/TOSHIBA/t2/GMR_61D08@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20201103_150138/';
'/Volumes/TOSHIBA/t2/GMR_61D08@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20201106_104110/';
'/Volumes/TOSHIBA/t2/GMR_61D08@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/20201106_104913/';
'/Volumes/TOSHIBA/t2/FCF_attP2-40@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp3/20210412_140914/';
'/Volumes/TOSHIBA/t2/FCF_attP2-40@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp3/20210420_133117/';
'/Volumes/TOSHIBA/t2/FCF_attP2-40@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp3/20210528_102708/';
'/Volumes/TOSHIBA/t2/FCF_attP2-40@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp3/20210917_101151/';
'/Volumes/TOSHIBA/t2/FCF_attP2-40@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp3/20210920_135038/';
'/Volumes/TOSHIBA/t2/FCF_attP2-40@UAS_Abeta40_116/p_4_60s1x30s0s#p_4_120s10x2s8s#n#n/exp3/20210921_144806/';

    };

for exp=1:length(adresses)
    
    clearvars -except adresses exp
    % Define the parameters
    
    % !! Important: put all files in a "data" folder (with the "data" name
    % only) contained in the main folder specified by 'adress' below
    adress=char(adresses(exp,:));
    timewindows=[
        15 30
        60 61
        60 62
        60 70 
        60 80
        60 90
        120 220
        ];
    tfin=250; % change if you have a different duration of experiment
    numberofwindows=length(timewindows);
    actionnames=["crawl"
        "head_cast"
        "stop"
        "hunch"
        "back_up"
        "roll"
        "small_actions"
        "backup_sequence"
        "bend"
        ];
    states=["run";"cast";"stop";"hunch";"backup";"roll";"small_actions";
        "backup_sequence";
        "bend_static"
        ];
    
    
    couleursactions=[
        0    0    0 % crawl
        1    0    0 % head cast
        0    1    0 % stop
        0    0    1 % hunch
        0    1    1 % back-up
        1    1    0 % roll
        1    0    1 % small actions
        0    0.4470    0.7410 % backup sequences
        0.8500    0.3250    0.0980 % bend / static bend
        ];
    
    if exp>=1
        couleursconditions=[0.00,0.45,0.74 ... % colors that will be used for each genotype/condition, add some if more genotypes/conditions
        ; 0.85,0.33,0.10 ...
        ; 0.93,0.69,0.13
        ; 0.2 0.5 0.3];
    else
        couleursconditions=[0.00,0.45,0.74 ... % colors that will be used for each genotype/condition, add some if more genotypes/conditions
        ; 0.85,0.33,0.10 ...
        ; 0.93,0.69,0.13
        ; 0.2 0.5 0.3];
    end
    
    
    % Concatenate trx for all experiments in each genotype
    
    TRX =concatenateTrx(adress);
    
    mkdir(adress, 'dataFiles_bendNotSeparated');
    filename=[adress 'dataFiles_bendNotSeparated/trx_concatenated.mat'];
    save(filename, 'TRX'); % save concatenated trx file
 
    % Add new fields with actions over time for each action
    % write 1 if the action is performed, 0 if not 
            for larva=1:length(TRX)
            larvaname=['larva' num2str(larva)];
            for action=1:length(states)
                actionname=states(action);
                indices=find(TRX(larva).global_state_large_state==action);
                numberstoadd=zeros(length(TRX(larva).global_state_large_state),1);
                numberstoadd(indices)=1;
                TRX(larva).(actionname)=numberstoadd;
            end
        end
    
    % Extract the probability of actions over time
    probabilities=struct;
  
        for action=1:length(states) % for each action (or state)
            actionname=states(action);
            probabilities.(actionname)=probabilityOfActionFromTrx(TRX,actionname,[timewindows(1,1) tfin]);
        end
    
    filename=[adress 'dataFiles_bendNotSeparated/probabilitiesovertime.mat'];
    save(filename, 'probabilities'); % save probabilities of action over time
    %%
    
    % Plot the probabilities over time
    
    % create new folder for the figures
    mkdir(adress, 'probabilitiesOverTime_bendNotSeparated');
    
   
        fig=figure;
        hold on
        actionsplotovertime=[1 2 3 4 5 6 9];
        for action=actionsplotovertime % for each action except backup sequence & small actions
            actionname=states(action);
            X=probabilities.(actionname)(:,1);
            Y=probabilities.(actionname)(:,2);
            plot(X,Y,'color',couleursactions(action,:),'linewidth',2);
        end
        yl=ylim;
        le=legend(regexprep(actionnames(actionsplotovertime),'_',''));
        xlabel('Time (s)');
        ylabel('Probability of action');
        set(gca,'box','off')
        
        filename=[adress 'probabilitiesOverTime_bendNotSeparated/00uncorr_probabilitiesovertime.fig'];
        saveas(gcf,filename);
        filename=[adress 'probabilitiesOverTime_bendNotSeparated/00uncorr_probabilitiesovertime'];
        saveas(gcf,filename,'epsc')
        
    % Extract the cumulative probabilities for the different time windows
        
        cumulativeProbabilities=struct;
        for timewindow=1:numberofwindows
            num1=regexprep(num2str(timewindows(timewindow,1)),'\.','p');
            num2=regexprep(num2str(timewindows(timewindow,2)),'\.','p');
            windowname=['window' num1 's_' num2 's'];
            windowtouse=timewindows(timewindow,:);
                for action=1:length(states)
                    actionname=states(action);
                    [cumulativeProbabilities.(windowname).(actionname).proba, cumulativeProbabilities.(windowname).(actionname).probacontrol, cumulativeProbabilities.(windowname).(actionname).numberoflarvae, cumulativeProbabilities.(windowname).(actionname).numberoflarvaecontrol]=cumulativeFromTrx(TRX,windowtouse,action);
                end
        end
        
        filename=[adress 'dataFiles_bendNotSeparated/cumulativeProbabilities.mat'];
        save(filename, 'cumulativeProbabilities');
        
%% Extraction probability of transition from one action to another
    
    allTransitions=struct;
    for timewindow=1:numberofwindows
        timestransitions=timewindows(timewindow,:);
        timestransitions(1,1)=timestransitions(1,1)-0.5; % extend time window in order to include BEFORE air puff
        num1=regexprep(num2str(timestransitions(1,1)),'\.','p');
        num2=regexprep(num2str(timestransitions(1,2)),'\.','p');
        windowname=['window' num1 's_' num2 's'];
            [allTransitions.notNormalized.(windowname), allTransitions.normalized.(windowname), meanNumberofTransitions.(windowname), nb_active.(windowname), nb_larvae_that_transition.(windowname), nb_transition_perlarvae.(windowname), first_transition.(windowname)]=transitionFromTrx(TRX, timestransitions);
    end
        allTransitionsForPlot=allTransitions;
   
    
    for timewindow=1:numberofwindows
        timestransitions=timewindows(timewindow,:);
        timestransitions(1,1)=timestransitions(1,1)-0.5; % extend time window in order to include BEFORE air puff
        num1=regexprep(num2str(timestransitions(1,1)),'\.','p');
        num2=regexprep(num2str(timestransitions(1,2)),'\.','p');
        windowname=['window' num1 's_' num2 's'];
        categories=["notNormalized";"normalized"];
            for i=1:length(categories)
                namecat=categories(i);
                allTransitions.(namecat).(windowname)=array2table(allTransitions.(namecat).(windowname));
                for j=1:length(actionnames)
                    variablename=['Var' num2str(j)];
                    allTransitions.(namecat).(windowname).Properties.VariableNames{variablename} = char(actionnames(j));
                end
            end
    end
    
    filename=[adress 'dataFiles_bendNotSeparated/allTransitions.mat'];
    save(filename, 'allTransitions');
    
    %% Plot transition matrix as heatmap
    
    mkdir(adress, 'transitions_bendNotSeparated');
    
    colormap hot;
    for timewindow=1:numberofwindows
        timestransitions=timewindows(timewindow,:);
        timestransitions(1,1)=timestransitions(1,1)-0.5; % extend time window in order to include BEFORE air puff
        num1=regexprep(num2str(timestransitions(1,1)),'\.','p');
        num2=regexprep(num2str(timestransitions(1,2)),'\.','p');
        windowname=['window' num1 's_' num2 's'];
 
            categories=["notNormalized";"normalized"];
            for i=1:length(categories)
                namecat=categories(i);
                datatoplot=round(allTransitionsForPlot.(namecat).(windowname),2);
                xcat=categorical(actionnames);
                h=figure;
                h=heatmap(xcat,xcat,datatoplot);
                if i==2
                    caxis([0 1]);
                end
                colormap hot;
                title(windowname);
                filename=[adress 'transitions_bendNotSeparated' windowname '_' char(namecat)];
                saveas(gcf,[filename '.fig']);
                saveas(gcf,[filename '.png']);
            end
    end
    close all % close all of the figures for better memory performance
end
    
    
    
    
   