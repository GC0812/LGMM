function [P1, P2,error_mat] = featurematchs(featuremat1, featuremat2, NumMin,NeighborNum)

% This function matches the best point in the feature matrix

% if (nargin == 3)
%    NeighborNum = 3; 
% end

M1 = size(featuremat1, 1);
M2 = size(featuremat2, 1);
 
errmat = zeros(M1, M2);
idxmat = zeros(M1, M2);
for i=1:M1
    vec1 = featuremat1(i,:); %取featuremat1的某一行
    for j=1:M2
        vec2 = featuremat2(j,:); %取featuremat2的某一行
        for k=1:NeighborNum
            vec2 = circshift(vec2, [0, (k-1)*(NeighborNum+2)]); %vec2中的元素循环移位，右移5位，十位
            tmperr(k)= mean(abs(vec2-vec1)); %求两个特征相减的均值
            %tmperr(k)=sqrt(sum((vec2-vec1).^2));
        end
        [errmat(i,j), idxmat(i,j)]= min(tmperr); %返回均值的最小值及行号
    end
end

% errmat(i,j) (M1 X M2) <==>(j-1)*M1 + i

[errmat, idx]= sort(errmat(:)); %把errmat元素从小到大排列，返回数值和位置
error_mat=errmat(1);
%seeds = idx(1:NumMin); %取前20个位置
seeds=idx;
P1 = mod(seeds, M1); %这20个数的行数
P1(P1==0)= M1; 
P2 = 1+(seeds-P1)/M1; %这20个数的列数
% idxmat = idxmat(:);
% P2idx = idxmat(idx(1:numel(seeds))); %这20个数的行号(2代表右移5位)

