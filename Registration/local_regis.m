function [ outmosaicbw_local_regis,averagerror_local_regis ] = local_regis( bw1,bw2, mytform,points_in_bw1,points_in_bw2)
%LOCAL_REGIS Summary of this function goes here
%   Detailed explanation goes hereoutbw1 = bw1;
try
for i=1:7
    if isempty(mytform(i).parameter)
        outmosaicbw_local_regis(i).local=[];
        averagerror_local_regis(i)=10;
    else
        outbw2 = imtransform(bw2, mytform(i).parameter, 'XData', [1 size(bw1,2)], 'YData', [1 size(bw1,1)]);
        outmosaicbw(i).local = 1-cat(3, bw1, outbw2,outbw2);

        R=5;
        [reference_points,transformed_points] = find_local_regis_points( bw1,bw2,outbw2,R );
        if(isempty(transformed_points))
                averagerror_local_regis(i)=10;
                outmosaicbw_local_regis(i).local=[];
                continue;
        else
        [new_corresponding_points] = find_original_corresponding(bw2,outbw2,mytform(i).parameter,transformed_points);

        reference = [reference_points;points_in_bw1(i).points]; %与初始特征点集集合在一起
        transform = [new_corresponding_points;points_in_bw2(i).points];
        mytform_local_regis(i).parameter = cp2tform(transform,reference,'similarity');

        outbw1 = bw1;
        outbw2 = imtransform(bw2, mytform_local_regis(i).parameter, 'XData', [1 size(bw1,2)], 'YData', [1 size(bw1,1)]);
        outmosaicbw_local_regis(i).local = 1-cat(3,bw1,outbw2,outbw2); 
        averagerror_local_regis(i)=ddistance(bw1,outbw2);
        end
    end   
end

if numel(outmosaicbw_local_regis)<7
    outmosaicbw_local_regis(7).local=[];
end
catch
    outmosaicbw_local_regis(7).local=[];
    averagerror_local_regis=10:1:16;
end
% outmosaicbw_length=numel(outmosaicbw_local_regis);%outmosaic没有值的，为[]
% if outmosaicbw_length<7
%     for k=outmosaicbw_length+1:7;
%     outmosaicbw_local_regis(k).local=[];
%     end
% end
    
    
    
    
    
    
