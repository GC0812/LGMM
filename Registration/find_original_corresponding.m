function [ new_corresponding_points ] = find_original_corresponding( bw2, outbw2, mytform,transformed_points )
%FIND_ORIGINAL_CORRESPONDING Summary of this function goes here
%   Detailed explanation goes here
[M2, N2] = size(bw2);
ptbifu_in_bw2 = points_init(bw2);
ptbifu_in_outbw2=points_init(outbw2);
coordinates_bw2 = points_transform(ptbifu_in_bw2,[M2 N2]);
coordinates_outbw2 = points_transform(ptbifu_in_outbw2,[M2 N2]);


[transformed_coordinates(:,1), transformed_coordinates(:,2)]  = tformfwd(mytform,coordinates_bw2(:,1),coordinates_bw2(:,2)); %找到bw2中的分叉点变换后的坐标
transformed_coordinates=round(transformed_coordinates); %四舍五入取整，坐标经变换后不是整数，需取整

for i=1:size(transformed_points,1)
    for j=1:size(transformed_coordinates,1)
        temp(j,:)=abs(transformed_coordinates(j,:)-transformed_points(i,:));
    end
        [~, num]=min(temp(:,1)+temp(:,2));
        line(i) = num;
end

for i=1:numel(line)
    new_corresponding_points(i,:)=coordinates_bw2(line(i),:);
end

end

