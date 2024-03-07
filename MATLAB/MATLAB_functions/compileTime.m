function [b_freq, b_prob, a_freq, a_prob] = compileTime(s,C,G1,G2,G3,n,t,norm)
% input taken:
% s: number of genotypes being compiled
% C: datatable of control
% G1 - G3: datatables of comparison
% n: vector denoting number of larvae per genotype
% t: length of time window desired, varies between action

    [m,l] = size(C);
    b_freq = zeros(s,l-1);
    b_prob = zeros(s,l-1);
    a_freq = zeros(s,l-1);
    a_prob = zeros(s,l-1);
    
    range = find(C(:,1)>59-t & C(:,1)<59);
    b_freq(1,:) = sum(C(range(1):range(end),2:end),1)+C(range(1),2:end);
    range = find(G1(:,1)>59-t & G2(:,1)<59);
    b_freq(2,:) = sum(G1(range(1):range(end),2:end),1)+G1(range(1),2:end);
    range = find(G2(:,1)>59-t & G2(:,1)<59);
    b_freq(3,:) = sum(G2(range(1):range(end),2:end),1)+G2(range(1),2:end);
    range = find(G3(:,1)>59-t & G3(:,1)<59);
    b_freq(4,:) = sum(G3(range(1):range(end),2:end),1)+G3(range(1),2:end);
   
    if norm == 1
   range = find(C(:,1)>60 & C(:,1)<60+t);
   a_freq(1,:) = sum(C(range(1):range(end),2:end),1)-b_freq(1,:);
   range = find(G1(:,1)>60 & G1(:,1)<60+t);
   a_freq(2,:) = sum(G1(range(1):range(end),2:end),1)-b_freq(2,:);
   range = find(G2(:,1)>60 & G2(:,1)<60+t);
   a_freq(3,:) = sum(G2(range(1):range(end),2:end),1)-b_freq(3,:);
   range = find(G3(:,1)>60 & G3(:,1)<60+t);
   a_freq(4,:) = sum(G3(range(1):range(end),2:end),1)-b_freq(4,:);
    else
        range = find(C(:,1)>60 & C(:,1)<60+t);
   a_freq(1,:) = sum(C(range(1):range(end),2:end),1);
   range = find(G1(:,1)>60 & G1(:,1)<60+t);
   a_freq(2,:) = sum(G1(range(1):range(end),2:end),1);
   range = find(G2(:,1)>60 & G2(:,1)<60+t);
   a_freq(3,:) = sum(G2(range(1):range(end),2:end),1);
   range = find(G3(:,1)>60 & G3(:,1)<60+t);
   a_freq(4,:) = sum(G3(range(1):range(end),2:end),1);
    end
    for i = 1:s
        for j = 1:l-1
            if j == 4 % the action of hunch
                % never normalize hunching behavior by the time
                a_prob(i,j) = a_freq(i,j)/n(i);
                b_prob(i,j) = b_freq(i,j)/n(i);
            else
            a_prob(i,j) = a_freq(i,j)/n(i)/t;
            b_prob(i,j) = b_freq(i,j)/n(i)/t;
            end
        end
    end
end
