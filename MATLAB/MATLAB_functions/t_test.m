function [p_all] = t_test(data)
 p_all = [];
 for i = 1:length(data)
     [h,p] = ttest2(data{1},data{i});
     p_all(i) = p;
 end
end