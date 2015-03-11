function [ reference_points,transformed_points] = find_local_regis_points( bw1,bw2,outbw2,R )
%LOCAL_RESGIS Summary of this function goes here
%   Detailed explanation goes here
ptbifu1 = points_init(bw1);
ptbifu2 = points_init(outbw2);
[M, N] = size(bw1);

idy = mod(ptbifu1, M); %找分叉点的行数
if (idy==0) idy=M; end
idx = 1 + (ptbifu1 - idy)/M; %分叉点的列数
num=1;
corresponding_points_num=1;

for i=1:N
    for j=1:M
        num_martrix(j,i) = num;
        num = num+1;
    end
end
bifu_in_bw1=[];
for i = 1: numel(ptbifu1)
    similar_bifu=[];
    bifu_in_area=[];
    count_bifu=1;
    difference=[];
    if ( idy(i)>R ) && ( idx(i)>R ) && ( (idy(i)+R)<=M ) && ( (idx(i)+R)<=N )
        region_num = num_martrix(idy(i)-R:idy(i)+R, idx(i)-R:idx(i)+R);
        region_num = region_num(:);
        bifu_in_area = intersect(region_num,ptbifu2); %找这个区域内的分叉点
    else
        bifu_in_area=[];
    end
    if(isempty(bifu_in_area))
        continue;                    %若为空则跳过
    else
        anglevec1 = point_anglevec(bw1,ptbifu1(i) , 3); %若有分叉点，则计算角度
        angel1=findangle(anglevec1); 
        for j=1:numel(bifu_in_area)
            anglevec = point_anglevec(outbw2,bifu_in_area(j), 3);
            angel=findangle(anglevec);
            if (numel(angel)==numel(angel1)) && ~isempty(angel)           %若与参考图像中的分叉点的角度个数一致，则保存在similar_bifu中备用
                similar_bifu(count_bifu,:) = angel;
                difference(count_bifu) = mean(abs(similar_bifu(count_bifu,:) - angel1));
                bifu_num(count_bifu)=j;
                count_bifu = count_bifu+1;                
            end
        end
        if(~isempty(similar_bifu))
            [min_difference, order]= min(difference);
            if(min_difference>12)
                continue;
            else
                corresponding_points(corresponding_points_num)=bifu_in_area(bifu_num(order));
                bifu_in_bw1(corresponding_points_num)=ptbifu1(i);
                corresponding_points_num=corresponding_points_num+1;
            end
        else
            continue;
        end
        
    end
end
if(isempty(bifu_in_bw1))
   reference_points = [];
   transformed_points = [];
   return;
else
bw1_idy = mod(bifu_in_bw1, M); %找分叉点的行数
if (bw1_idy==0) bw1_idy=M; end
bw1_idx = 1 + (bifu_in_bw1 - bw1_idy)/M; %分叉点的列数


outbw2_idy = mod(corresponding_points, M); %找分叉点的行数
if (outbw2_idy==0) idy=M; end
outbw2_idx = 1 + (corresponding_points - outbw2_idy)/M; %分叉点的列数

dy = bw1_idx - outbw2_idx;
dx = bw1_idy - outbw2_idy;
for i=1:numel(dy)
    distance(i) = sqrt(dy(i)*dy(i)+dx(i)*dx(i));
end
%----------------------------------------------------------------------
%以下部分是分为4个区域，每个区域选择距离最大的作为匹配点
% area_up=min(outbw2_idy);
% area_down=max(outbw2_idy);
% area_left=min(outbw2_idx);
% area_right=max(outbw2_idx);
% 
% vertical = floor((area_down - area_up)/4);
% 
% a=1;b=1;c=1;d=1;
% for i=1:numel(outbw2_idy)
%     if(outbw2_idy(i)>=area_up & outbw2_idy(i)<outbw2_idy+vertical)
%         area1(a)=i;
%         a=a+1;
%     elseif(outbw2_idy(i)>=area_up+vertical & outbw2_idy(i)<outbw2_idy+2*vertical)
%         area2(b)=i;
%         b=b+1;
%     elseif(outbw2_idy(i)>=area_up+2*vertical & outbw2_idy(i)<outbw2_idy+3*vertical)
%         area3(c)=i;
%         c=c+1;
%     else
%         area4(d)=i;
%         d=d+1;
%     end
% end
% 
% area1(2,:)=bifu_in_bw1(area1(1,:));
% area1(3,:)=corresponding_points(area1(1,:));
% area1(4,:)=distance(area1(1,:));
% 
% 
% area2(2,:)=bifu_in_bw1(area2(1,:));
% area2(3,:)=corresponding_points(area2(1,:));
% area2(4,:)=distance(area2(1,:));
% 
% area3(2,:)=bifu_in_bw1(area3(1,:));
% area3(3,:)=corresponding_points(area3(1,:));
% area3(4,:)=distance(area3(1,:));
% 
% 
% area4(2,:)=bifu_in_bw1(area4(1,:));
% area4(3,:)=corresponding_points(area4(1,:));
% area4(4,:)=distance(area4(1,:));
% 
% [area1(4,:) order1]=sort(area1(4,:),'descend');   %每个区域内的对应点按距离从大到小排序，第一行指第几个对应点，第二行指参考图像上的分叉点，三行指变换图像上的对应点，第四行指他们之间的距离
% area1(1:3,:)=area1(1:3,order1);
% 
% 
% [area2(4,:) order2]=sort(area2(4,:),'descend');
% area2(1:3,:)=area2(1:3,order2');
% 
% [area3(4,:) order3]=sort(area3(4,:),'descend');
% area3(1:3,:)=area3(1:3,order3');
% 
% [area4(4,:) order4]=sort(area4(4,:),'descend');
% area4(1:3,:)=area4(1:3,order4');
% 
% matching_points1 = [area1(2,1) area2(2,1) area3(2,1) area4(2,1)];
% matching_points2 = [area1(3,1) area2(3,1) area3(3,1) area4(3,1)];
%——————————————————————————————————————————————————————————————————————————————————————

 [matching_num] = find(distance>3.0);
 matching_points1 = bifu_in_bw1(matching_num);
 matching_points2 = corresponding_points(matching_num);


reference_points = points_transform(matching_points1', [M, N]);
transformed_points = points_transform(matching_points2', [M, N]);
end


