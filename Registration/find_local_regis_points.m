function [ reference_points,transformed_points] = find_local_regis_points( bw1,outbw2,ptbifu1,R )

%寻找outbw2与bw1相对应的未配准的局部分叉点

[M, N] = size(bw1);
ptbifu2=points_init(outbw2);

idy = mod(ptbifu1, M); %找分叉点的列数(M)
if idy==0
    idy=M;
end
idx = 1 + (ptbifu1 - idy)/M; %分叉点的行数(N)

corresponding_points_num=1;
num=1;
num_matrix=zeros(M,N);
for i=1:N
    for j=1:M
        num_matrix(j,i) = num;
        num = num+1;
    end
end
bifu_in_bw1=[];
for i = 1: numel(ptbifu1)
    similar_bifu=[];
    count_bifu=1;
    difference=[];
    if ( idy(i)>R ) && ( idx(i)>R ) && ( (idy(i)+R)<=M ) && ( (idx(i)+R)<=N )
        region_num = num_matrix(idy(i)-R:idy(i)+R, idx(i)-R:idx(i)+R);%生成一个11x11的区域
        region_num = region_num(:);
        bifu_in_area = intersect(region_num,ptbifu2); %找这个区域内的分叉点
    else
        bifu_in_area=[];
    end
    if(isempty(bifu_in_area))
        continue;                    %若为空则跳过
    else
        anglevec1 = point_anglevec(bw1,ptbifu1(i) , 3); %若有分叉点，则计算角度
        angel1=find_angle(anglevec1);
        for j=1:numel(bifu_in_area)
            anglevec = point_anglevec(outbw2,bifu_in_area(j), 3);
            angle=find_angle(anglevec);
            if (numel(angle)==numel(angel1)) && ~isempty(angle)           %若与参考图像中的分叉点的角度个数一致，则保存在similar_bifu中备用
                similar_bifu(count_bifu,:) = angle;
                difference(count_bifu) = mean(abs(similar_bifu(count_bifu,:) - angel1));
                bifu_num(count_bifu)=j;
                count_bifu = count_bifu+1;
            end
        end
        if(~isempty(similar_bifu))
            [min_difference, order]= min(difference);%在候选中找到误差最小的一个
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
    bw1_idy = mod(bifu_in_bw1, M); %找分叉点的列数
    if bw1_idy==0
        bw1_idy=M;
    end
    bw1_idx = 1 + (bifu_in_bw1 - bw1_idy)/M; %分叉点的行数
    
    outbw2_idy = mod(corresponding_points, M); %找分叉点的列数
    outbw2_idx = 1 + (corresponding_points - outbw2_idy)/M; %分叉点的行数
    
    dx = bw1_idx - outbw2_idx;
    dy = bw1_idy - outbw2_idy;
    
    distance=zeros(1,numel(dy));
    for i=1:numel(dy)
        distance(i) = sqrt(dy(i)*dy(i)+dx(i)*dx(i));
    end
    
    [matching_num] = find(distance>3.0);%认为分叉点距离>3像素则两个分叉点未对应需重新配准
    matching_points1 = bifu_in_bw1(matching_num);
    matching_points2 = corresponding_points(matching_num);
    
    reference_points = points_transform(matching_points1', [M, N]);%获得相应的坐标
    transformed_points = points_transform(matching_points2', [M, N]);
end


