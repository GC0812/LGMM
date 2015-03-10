clear all;
close all;
clc;

fid=fopen('./Dataset/index.txt','r');%%读取index文档中的图像配对情况
C=textscan(fid,'%s%s');%%按列读取配对文档中的视网膜图像的配对情况

type(1).no='three';type(2).no='four';type(3).no='five';type(4).no='three_four';
type(5).no='three_five';type(6).no='four_five';type(7).no='three_four_five';%%%7种环结构类型
b=1;
for i=1:numel(C{1,1})
    [outputfolder,imagename1,imagename2]=pathfile(i,C);
    foldername1=C{1,1}{i};foldername2=C{1,2}{i};
    error=11*ones(14,14,7);
    for j=1:numel(imagename1)
        lmDir1=fullfile('./Dataset/skeleton/',foldername1,'/',imagename1(j).name);
        bw1=imread(lmDir1);
        bw1_num=numel(find(bw1==1));
        if bw1_num<2550  %%去除像素数小于阈值的尺度
            continue;
        end
        for k=1:numel(imagename2)
            lmDir2=fullfile('./Dataset/skeleton/',foldername2,'/',imagename2(k).name);
            bw2=imread(lmDir2);
            bw2_num=numel(find(bw2==1));
            if bw2_num<2550
                continue;
            end
            [outmosaicbw,sae,mytform,flag]=cycle_registration(bw1,bw2);%运行配准程序，输出配准结果，分别为3、4、5、34、35、45、345点环的输出结果
            file_tform=['mytform','-',num2str(j),'-',num2str(k)];
            save([outputfolder(8).path,'/',file_tform],'mytform');
            error(j,k,1:7)=sae;
            for m=1:7
                if ~isempty(outmosaicbw(1,m).data)
                    if flag(m)==0
                        outputpath=strcat(outputfolder(m).path,'/',num2str(j),'-',num2str(k),'-','twice','-',type(m).no,'-',num2str(sae(1,m)),'.png');
                        imwrite(outmosaicbw(1,m).data,outputpath);
                    elseif flag(m)==4
                        outputpath=strcat(outputfolder(m).path,'/',num2str(j),'-',num2str(k),'-','cycle','-',type(m).no,'-',num2str(sae(1,m)),'.png');
                        imwrite(outmosaicbw(1,m).data,outputpath);
                    end
                end
            end
        end
    end
    %%%计算3个最小误差，得到最优配准结果对应尺度及误差，并写入minerror.txt
    minerror_all=sort(error(:));
    minerror_three=minerror_all(1:3); %计算3个最小误差
    
    for n=1:3
        [scale_no1,scale_no2,cycle_type_no]=ind2sub(size(error),find(error==minerror_three(n)));
        scale_bw1(n)=scale_no1(1);scale_bw2(n)=scale_no2(1);
        cycle_type(n)=cycle_type_no(1);
    end
    outputfolder=strcat('./Results/skeleton/');
    fid=fopen([outputfolder,'minerror.txt'],'a+');
    fprintf(fid,'%s%s%s %.5f %d%s%d %s\t%.5f %d%s%d %s\t%.5f %d%s%d %s\n',...
    foldername1,'-',foldername2,minerror_three(1),scale_bw1(1),'-',scale_bw2(1),...
    type(cycle_type(1)).no,minerror_three(2),scale_bw1(2),'-',scale_bw2(2),type(cycle_type(2)).no,...
    minerror_three(3),scale_bw1(3),'-',scale_bw2(3),type(cycle_type(3)).no);
    fclose(fid);
    
    %%求得最优骨架化图像配准结果对应的原始图像配准结果
    readfile1=imread(['./Dataset/Image/',foldername1,'.pgm']);
    readfile2=imread(['./Dataset/Image/',foldername2,'.pgm']);
    readfile1=im2double(readfile1);
    readfile2=im2double(readfile2);
    outim1=readfile1;
    
    load([outputfolder(8).path,'/','mytform-',num2str(scale_bw1(1)),'-',num2str(scale_bw2(1)),'.mat']);
    mytform_optimal=mytform(1,cycle_type(1)).data;
    outim2=imtransform(readfile2, mytform_optimal, 'XData', [1 size(outim1,2)], 'YData', [1 size(outim1,1)]);
    outmosaic_image=(outim1+outim2); 
    imwrite(mat2gray(outmosaic_image),'./Results/optimal_result.tif','Resolution',300);
    
    if numel(scale_bw1(1))==1
    bw1_optimal=imread(['./Dataset/Skeleton/',foldername1,'/','0',num2str(scale_bw1(1)),'.tif']);
    else bw1_optimal=imread(['./Dataset/Skeleton/',foldername1,'/',num2str(scale_bw1(1)),'.tif']);
    end
    if numel(scale_bw2(1))==1
    bw2_optimal=imread(['./Dataset/Skeleton/',foldername2,'/','0',num2str(scale_bw2(1)),'.tif']);
    else bw2_optimal=imread(['./Dataset/Skeleton/',foldername2,'/',num2str(scale_bw2(1)),'.tif']);
    end
    outbw2=imtransform(bw2_optimal, mytform_optimal, 'XData', [1 size(bw1,2)], 'YData', [1 size(bw1,1)]);
    outmosaic_ske=1-cat(3,bw1_optimal,outbw2,outbw2);
    imwrite(outmosaic_ske,'./Results/optimal_result_ske.tif','Resolution',300);
end
