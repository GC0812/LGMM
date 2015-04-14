function [ featuremat3,featuremat4,featuremat5,loop3,loop4,loop5,linktableoriginal,bw,ptbifu] = export_featuremat( bw )

%求得图像的分叉点，连接关系，构造3种环结构并输出特征向量

featuremat3=[];featuremat4=[];featuremat5=[];loop3=[];loop4=[];loop5=[];

[ptbifu] = points_init(bw); %找分叉点
bw(ptbifu)=1;
radius=3;
% 
% label = points_show(bw,ptbifu,3);  %标记分叉点
% label_bifu = 1-cat(3, bw, bw+label , bw);
% figure,imshow(label_bifu)

[linktableoriginal] = points_link(bw, ptbifu); %找到每个分叉点的相邻分叉点构成连接关系

[linktable] = select_linktable(linktableoriginal);%挑选得到能构成环的连接关系

if isempty(linktable)
    return
end

% pt=unique(linktable(1,:),'legacy');
% label = points_show(bw,pt,3);  %标记分叉点
% label_bifu = 1-cat(3, bw, bw+label , bw);
% figure,imshow(label_bifu)   

[~,N] = size(linktable);

linktable1=linktable;

loop4_num=1;
loop3_num=1;
loop5_num=1;
loop3=[];
loop4=[];
loop5=[];
num_end_points=1;
end_points=[];
continue_num=1;


linktable2=linktable1;
for i=1:N %从linktable第一列开始一直到最后一列
    empty=1;
    if(linktable(1,i)~=0)
        net_num=1;
        column_array = linktable(:,i); %先研究第一列的行数矩阵pos
        loop_points = find_position(linktable,column_array);
        if(numel(loop_points)<3) %如果重复次数的个数小于3的话，则不能组成环
            linktable2(:,i)=0;
            linktable=linktable2;
            net=[];
            continue_points=[];
            continue_num=1;
            num_end_points=1;
            end_points=[];
            continue;
        else %把一二层写到net中
            path=find_path(linktable,loop_points);
            if(numel(path)<2)
                linktable2(:,i)=0;
                linktable=linktable2;
                net=[];
                continue_points=[];
                continue_num=1;
                num_end_points=1;
                end_points=[];
                continue;
            end
            net(net_num).edge=path(1);
            net_num=net_num+1;
            net(net_num).edge=path(2:numel(path));
            net_num=net_num+1;
            linktable(:,i)=0;
            
            for j=1:numel(net(2).edge) %由第二层找到第三层
                %------------------------------------------
                %
                row_array = linktable(:,linktable(1,:)==net(2).edge(j)); %把path中的元素作为研究对象开始寻找与其连接的元素
                [net_points ] = find_net( linktable,linktable1,row_array );
                if(j==1)
                    net(net_num).edge=net_points;
                else
                    net(net_num).edge=[net(net_num).edge net_points];
                end
            end
            if(isempty(net(3).edge))
                linktable2(:,i)=0;
                linktable=linktable2;
                net=[];
                continue_points=[];
                continue_num=1;
                num_end_points=1;
                end_points=[];
                continue
            end
            for k=1:numel(net(3).edge) %找结束点
                if(numel(find([net.edge]==net(3).edge(k)))>1)
                    end_points(num_end_points) = net(3).edge(k);
                    num_end_points=num_end_points+1;
                end
            end
            
            if(~isempty(end_points)) %如果有结束点，说明前三层中有环，找到环并输出
                for a=1:num_end_points-1
                    loop_points  = export_loop(linktable1,end_points(a),net,net_num); %如果找到结束点，则说明前几层有环，找到环，并输出
                    switch numel(loop_points)
                        case 3
                            loop3(loop3_num,:)=loop_points;
                            loop3_num=loop3_num+1;
                        case 4
                            loop4(loop4_num,:)=loop_points;
                            loop4_num=loop4_num+1;
                        case 5
                            loop5(loop5_num,:)=loop_points;
                            loop5_num=loop5_num+1;                            
                    end
                end
            end
            continue_points(continue_num).path=setdiff(net(3).edge,end_points);  %判断是不是仍有除了结束点之外的其他点出现
            
            if(isempty(continue_points(continue_num).path)) %若是没有其他点，则应结束本次循环
                linktable2(:,i)=0;
                linktable=linktable2;
                net=[];
                continue_points=[];
                continue_num=1;
                num_end_points=1;
                end_points=[];
                continue
            end
            
            
            end_points=[];
            num_end_points=1;
            net_num=net_num+1;
            
            linktable_temp=linktable;
            %------------------------------------------------------------------------------------------
            for j=1:numel(continue_points(continue_num).path) %不是结束点的接着往下找（到第四层了）
                
                row_array=linktable(:,linktable(1,:)==continue_points(continue_num).path(j));
                loop_points=intersect(row_array,net(2).edge,'legacy');
                if(isempty(loop_points))
                    empty=empty+1;
                    continue
                end
                if(numel(loop_points)~=1)
                    loop_points=loop_points(1);
                end
                linktable_temp(:,linktable_temp(1,:)==loop_points)=0;
                [net_points]= find_net(linktable_temp,linktable1,row_array);
                
                if(j==1)
                    net(net_num).edge=net_points;
                elseif(j==2)
                    net(net_num).edge=[net(net_num).edge net_points];
                end
                linktable_temp=linktable;
            end
            
            continue_num=continue_num+1;
            if((empty-1)==numel(continue_points(continue_num-1))) %如果找不到第四层，则结束本次循环
                linktable2(:,i)=0;
                linktable=linktable2;
                net=[];
                continue_points=[];
                continue_num=1;
                num_end_points=1;
                end_points=[];
                continue
            end
            for k=1:numel(net(4).edge) %找结束点，如果有，则说明有环产生
                if(numel(find([net.edge]==net(4).edge(k)))>1)
                    end_points(num_end_points) = net(4).edge(k);
                    num_end_points=num_end_points+1;
                end
            end
            
            if(~isempty(end_points))
                for a=1:num_end_points-1
                    loop_points  = export_loop(linktable1,end_points(a),net,net_num);
                    switch numel(loop_points)
                        case 3
                            loop3(loop3_num,:)=loop_points;
                            loop3_num=loop3_num+1;
                        case 4
                            loop4(loop4_num,:)=loop_points;
                            loop4_num=loop4_num+1;
                        case 5
                            loop5(loop5_num,:)=loop_points;
                            loop5_num=loop5_num+1;
                    end
                end
            end
            
            continue_points(continue_num).path=setdiff(net(4).edge,end_points);
            
            if(isempty(continue_points(continue_num).path))
                linktable2(:,i)=0;
                linktable=linktable2;
                net=[];
                continue_points=[];
                continue_num=1;
                num_end_points=1;
                end_points=[];
                continue
            end
            end_points=[];
            num_end_points=1;
            
            net_num=net_num+1;
            %------------------------------------------------------------------------
            for j=1:numel(continue_points(continue_num).path) %不是结束点的接着往下找(第五层)
                row_array=linktable(:,linktable(1,:)==continue_points(continue_num).path(j));
                loop_points=intersect(row_array,net(3).edge,'legacy');
                if(isempty(loop_points))
                    empty=empty+1;
                    continue
                end
                if(numel(loop_points)~=1)
                    loop_points=loop_points(1);
                end
                linktable_temp(:,linktable_temp(1,:)==loop_points)=0;
                [net_points]= find_net(linktable_temp,linktable1,row_array);
                if(j==1)
                    net(net_num).edge=net_points;
                else
                    net(net_num).edge=[net(net_num).edge net_points];
                end
            end
            
            continue_num=continue_num+1;
            
            
            for k=1:numel(net(5).edge) %找结束点，如果有，则说明有环产生
                if(numel(find([net.edge]==net(5).edge(k)))>1)
                    end_points(num_end_points) = net(5).edge(k);
                    num_end_points=num_end_points+1;
                end
            end
            
            if(~isempty(end_points))
                for a=1:num_end_points-1
                    loop_points  = export_loop(linktable1,end_points(a),net,net_num);
                    switch numel(loop_points)
                        case 3
                            loop3(loop3_num,:)=loop_points;
                            loop3_num=loop3_num+1;
                        case 4
                            loop4(loop4_num,:)=loop_points;
                            loop4_num=loop4_num+1;
                        case 5
                            loop5(loop5_num,:)=loop_points;
                            loop5_num=loop5_num+1;
                    end
                end
            end
            continue_points(continue_num).path=setdiff(net(5).edge,end_points);
            
            
            if(isempty(continue_points(continue_num).path))
                
                linktable2(:,i)=0;
                linktable=linktable2;
                net=[];
                continue_points=[];
                continue_num=1;
                num_end_points=1;
                end_points=[];
                continue
            end
            end_points=[];
            
            
            linktable2(:,i)=0;
            linktable=linktable2;
            net=[];
            continue_points=[];
            continue_num=1;
            net_num=net_num+1;
            num_end_points=1;
            end_points=[];
        end
    end
end

loopa=unique(loop3,'rows');
loopb=unique(loop4,'rows');
loopc=unique(loop5,'rows');
j=1;

loop3=[];
loop4=[];loop5=[];
loop3_num=1;
loop4_num=1;
loop5_num=1;

path_points=[];
for i=1:size(loopa,1)
    temp = verifystructure( linktable1,loopa(i,:),path_points );
    if(~isempty(temp))
        loop3(loop3_num,:)=temp;
        loop3_num=loop3_num+1;
    end
end
for i=1:size(loopb,1)
    temp = verifystructure( linktable1,loopb(i,:),path_points );
    if(~isempty(temp))
        loop4(loop4_num,:)=temp;
        loop4_num=loop4_num+1;
    end
end
for i=1:size(loopc,1)
    temp = verifystructure( linktable1,loopc(i,:),path_points );
    if(~isempty(temp))
        loop5(loop5_num,:)=temp;
        loop5_num=loop5_num+1;
    end
end


Len = size(loop3,1);
num_featuremat3=1;
for count=1:Len
    bifu_loop = loop3(count,:);
    featuremat3(num_featuremat3,:)= points_featuremat(bw, bifu_loop, radius);
    num_featuremat3=num_featuremat3+1;
end
Len = size(loop4,1);
num_featuremat4=1;
for count=1:Len
    bifu_loop = loop4(count,:);
    featuremat4(num_featuremat4,:)= points_featuremat(bw, bifu_loop, radius);
    num_featuremat4=num_featuremat4+1;
end
Len = size(loop5,1);
num_featuremat5=1;
for count=1:Len
    bifu_loop = loop5(count,:);
    featuremat5(num_featuremat5,:)= points_featuremat(bw, bifu_loop, radius);
    num_featuremat5=num_featuremat5+1;
end

end

