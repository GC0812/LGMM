function [ loop_points ] = find_position( linktable,row_array )
%FIND_POSITION Summary of this function goes here
%   Detailed explanation goes here

[M,~] = size(linktable);
num=1;pos=zeros(5,5);
for j=1:5 %分别找linktable中每一行中的数的重复次数,每一行形成一个矩阵,记录重复次数
    if(row_array(j)~=0)        
        ringpoints = find(linktable==row_array(j));  
        ringpoints = ringpoints';
        points_num=numel(ringpoints);
                
        for count=1:points_num
            line(count) = mod(ringpoints(count), M); %找分叉点的行数
            if (line(count)==0) line(count)=M; end
            row(count) = 1 + (ringpoints(count) - line(count))/M; %分叉点的列数
        end
        row1=row;
        line=[];
        row=[];
    
        switch numel(row1)
            case 0
                pos(num,:)=zeros(1,5);
            case 1
                pos(num,:)=[row1 0 0 0 0];
            case 2
                pos(num,:)=[row1 0 0 0];
            case 3
                pos(num,:)=[row1 0 0];
            case 4
                pos(num,:)=[row1 0];
            case 5
                pos(num,:)=row1;
            case 6
                pos(num,:)=row1(2:6);
            case 7
                pos(num,:)=row1(2:6);
        end
        num = num+1;
   else
        pos(num,:) = zeros(1,5);
        num = num+1;
    end
end
   

for k=1:25 %分别找pos中的点,若一个点的重复个数小于2,则赋值为0
    if(numel(find(pos==pos(k)))<2)
        pos(k)=0;
    end
end
    loop_points=unique(pos);
    loop_points(1,:)=[]; 



