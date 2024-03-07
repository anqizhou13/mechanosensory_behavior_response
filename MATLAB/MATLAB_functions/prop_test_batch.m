function [p_batch] = prop_test_batch(B,A,n)
% input taken: 
% B = cumulative frequency matrix of dimension genotypes x action before stimulus
% A = cumulative frequency matrix of dimension genotypes x action after stimulus
% n = vector of 1 x genotypes denoting the number of larvae involved
data = round(A-B);
data(:,4) = round(A(:,4)); % hunch is only the after stimulus

[x y] = size(data);
p_batch = zeros(x,y);

for i = 1:x
    N = [n(1) n(i)];
    for j = 1:y
        X = [data(1,j) data(i,j)];
        [h,p, chi2stat,df] = prop_test(X,N,false);
        p_batch(i,j) = p;
    end
end
end