function [outlinktable, outfeaturemat, bw] = points_feature(bw, radius)

% This function call subfunctions to generate the feature data

se = strel('square', 5); %创建5*5的正方形
bw = bwmorph(imdilate(bw, se), 'thin', Inf); %使用5*5的方阵进行膨胀，然后进行细化（骨架化）

[ptbifu, ptroot] = points_init(bw);
ptbifubest = points_select(bw, ptbifu, radius, 3);

pt1 = points_select(bw, ptroot, radius, 1);
pt2 = points_select(bw, ptbifu, radius, 4);
ptmargbest = []; %disable the terminal point 

[linktable, featuremat] = points_link(bw, ptbifubest, ptmargbest, radius);

% Only slect those with 3 branches
outlinktable = [];
outfeaturemat = [];
for k = 1:size(linktable, 1)
    if (linktable(k,2) == 3)
        outlinktable  = [outlinktable; linktable(k,:)];
        outfeaturemat = [outfeaturemat; featuremat(k,:)];
    end
end