function [outputfolder1,imagename1,imagename2]=pathfile(i,C)

foldername1=C{1,1}{i};foldername2=C{1,2}{i};
imagepath1=strcat('./Dataset/Skeleton/',foldername1,'/','*.tif');
imagename1=dir(imagepath1);%第一列图像的图片名称
k1=1;false1=[];
for m=1:numel(imagename1)
    if imagename1(m,1).name(1)=='.'|| imagename1(i,1).isdir==1
        false1(k1)=m;
        k1=k1+1;
    end
end
imagename1(false1)=[];

imagepath2=strcat('./Dataset/Skeleton/',foldername2,'/','*.tif');
imagename2=dir(imagepath2);%与第一列相对应的图像的的名称
k2=1;false2=[];
for j=1:numel(imagename2)
    if imagename2(j,1).name(1)=='.'|| imagename2(i,1).isdir==1
        false2(k2)=j;
        k2=k2+1;
    end
end
imagename2(false2)=[];

outputfolder=strcat('./Results/Skeleton/',foldername1,'-',foldername2);
mkdir(outputfolder);
outputfolder_three=strcat(outputfolder,'/','three');
mkdir(outputfolder_three);
outputfolder_four=strcat(outputfolder,'/','four');
mkdir(outputfolder_four);
outputfolder_five=strcat(outputfolder,'/','five');
mkdir(outputfolder_five);
outputfolder_thrfou=strcat(outputfolder,'/','three_four');
mkdir(outputfolder_thrfou);
outputfolder_thrfiv=strcat(outputfolder,'/','three_five');
mkdir(outputfolder_thrfiv);
outputfolder_foufiv=strcat(outputfolder,'/','four_five');
mkdir(outputfolder_foufiv);
outputfolder_thrfoufiv=strcat(outputfolder,'/','three_four_five');
mkdir(outputfolder_thrfoufiv);
outputfolder_mytform=strcat(outputfolder,'/','mytform');
mkdir(outputfolder_mytform);
    

outputfolder1(1).path=outputfolder_three;
outputfolder1(2).path=outputfolder_four;
outputfolder1(3).path=outputfolder_five;
outputfolder1(4).path=outputfolder_thrfou;
outputfolder1(5).path=outputfolder_thrfiv;
outputfolder1(6).path=outputfolder_foufiv;
outputfolder1(7).path=outputfolder_thrfoufiv;
outputfolder1(8).path=outputfolder_mytform;
end
