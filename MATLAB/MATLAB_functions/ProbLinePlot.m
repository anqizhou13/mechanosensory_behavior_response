function [] = ProbLinePlot(genotype,window)
figure(1)
plot(genotype(:,1),genotype(:,2),'LineWidth',2)
hold on
plot(genotype(:,1),genotype(:,3),'LineWidth',2)
hold on
plot(genotype(:,1),genotype(:,8),'LineWidth',2)
hold on
plot(genotype(:,1),genotype(:,4),'LineWidth',2)
hold on
plot(genotype(:,1),genotype(:,5),'LineWidth',2)
hold on
plot(genotype(:,1),genotype(:,6),'LineWidth',2)
xlim(window)
title(genotype)
xlabel('Seconds(s)')
ylabel('Behavioral Probability')
legend('crawl','cast','static bend','stop','hunch','backup',...
    'Location','southoutside','Orientation','horizontal')
end
