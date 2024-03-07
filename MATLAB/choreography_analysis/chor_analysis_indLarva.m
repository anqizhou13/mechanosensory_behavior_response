%% USING CHOREOGRAPH DATA TO VISUALIZE QUALITIES OF INDIVIDUAL LARVA
% DESCRIPTIVE TEXT

directory = '/Volumes/TOSHIBA/t2/TH-gal4@CS';
%directory = '/Volumes/TOSHIBA/t2/TH-gal4@TH-RNAi';
%directory = '/Volumes/TOSHIBA/t2/TH-gal4@UAS_TNT_2_0003';


% list all files for the genotype
filelist = dir(fullfile(directory, '**/*.dat')); 

for f = 1:length(filelist)
% load the raw trx file
filepath = strcat(filelist(f).folder,'/',filelist(f).name);
larvaID = extractBetween(filelist(f).name,"@20.",".dat");
L = load(filepath);
L = L(:,[1 3]); % (2 = velocity, 3 = length, 4 = dS)
L = L(L(:,1)>10 & L(:,1)<50,:);

meanL = mean(L(:,2));
len_TH_CS(f) = meanL;
%len_TH_TNT(f) = meanL;
%len_TH_RNAi(f) = meanL;

clear L

%figure('visible','off')
%plot(L(:,1),L(:,2));
%xlabel('Second(s)')
%ylabel('Speed')
%xlim([10 50])
%saveas(gcf,char(larvaID),'epsc')
end

%%
figure()
hold on
histogram(len_TH_CS,50,'FaceAlpha',0.7)
hold on
histogram(len_TH_TNT,50,'FaceAlpha',0.7)
hold on
histogram(len_TH_RNAi,50,'FaceAlpha',0.7)
legend('THxCS','TH>TNT','TH>TH-RNAi')
xlabel('Length(mm)')
ylabel('Frequency')


