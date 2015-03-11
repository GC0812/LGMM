clear all;
close all;
clc;

%Retinal images' multiscale segmentation and skeleton%

path(path,'./PreProcessing'); %add path

imgDir = './Dataset/Image/';
D=dir(fullfile(imgDir,'*.pgm'));
outDir = './Dataset/Skeleton/'; mkdir(outDir);

maxlevel=0;
flt='cl';
SNR=5;

for count = 1:numel(D)
    lmDir=fullfile(imgDir,D(count).name);
    outFile = fullfile(outDir,[D(count).name(1:end-4) ]);
    mkdir(outFile);
    X=imread(lmDir); 
    
    %%%segmentation    
    IG=X;          
%     X=rgb2gray(X);
    f=double(X);   
    Y=f;
    
    [M,N]=size(Y);
    
    sa = 2.0;
    [M1,N1]=size(Y);
    x1=[-6:6];
    tmp2=exp(-(x1.*x1))/(2*sa*sa); % constcut the filter with casue kernel
    tmp2=max(tmp2)-tmp2;
    ht1=repmat(tmp2,[9 1]);
    sht1=sum(ht1(:));
    mean=sht1/(13*9);
    ht1=ht1-mean;
    ht1=ht1/sht1;
    h{1}=zeros(15,16);
    for i=1:9
        for j=1:13
            h{1}(i+3,j+1)=ht1(i,j); % filter side 9*13
        end
    end
    for k=1:11
        ag=15*k;
        h{k+1}=imrotate(h{1},ag,'bicubic','crop'); % rotate the filter 15*i to detect vessels with different angles
    end
    for k=1:12
        R{k}=conv2( Y,h{k},'same'); % convw image to detect vessels
    end
    rt=zeros(M1,N1);
    for  i=1:M1
        for j=1:N1
            ER= [R{1}(i,j),R{2}(i,j),R{3}(i,j),R{4}(i,j),R{5}(i,j),R{6}(i,j),...
                R{7}(i,j), R{8}(i,j), R{9}(i,j), R{10}(i,j), R{11}(i,j), R{12}(i,j)];
            rt(i,j) = max(ER);
        end
    end
    rmin=abs(min(rt(:)));
    
    for m=1:M1
        for n=1:N1
            rt(m,n)=rt(m,n)+rmin;
        end
    end
    
    Img=rt;
    eps1=0.000001;
    
    [nrow, ncol]=size(Img);
    I_temp=Img;% initial value
    I_temp=I_temp.*0;
    Imgu=Img.*0;
    lamda=0.001;
    timestep=0.01;
    f=Img;
    for n=1:14
        for nnnn=1:1
            Iy_back = I_temp-I_temp(:,[1,1:ncol-1]);% D_y in paper
            Iy_forw = I_temp(:,[2:ncol,ncol])-I_temp;% D+y in paper
            Ix_back = I_temp-I_temp([1,1:nrow-1],:); % D_x in paper
            Ix_forw = I_temp([2:nrow,nrow],:)-I_temp; % D+x in paper
            Iy = 0.5*(I_temp(:,[2:ncol,ncol])-I_temp(:,[1,1:ncol-1])); % D_0y in paper
            Ix = 0.5*(I_temp([2:nrow,nrow],:)-I_temp([1,1:nrow-1],:)); % D_0x in paper
            % computer CE of the paper
            c11=Ix_forw.^2+Iy.^2+eps1;
            c12=c11.^(1/2);
            c1=1./c12;
            % computer CW of the paper
            Iyy=Iy([1,1:nrow-1],:);
            c21=Ix_back.^2+Iyy.^2+eps1;   % origal code is   c21=Ix_back.^2+Iy.^2+eps1;
            c22=c21.^(1/2);
            c2=1./c22;
            % computer CS of the paper
            c31=Iy_forw.^2+Ix.^2+eps1;
            c32=c31.^(1/2);
            c3=1./c32;
            % computer CN of the paper   % orgial code is  c41=Iy_back.^2+Ix.^2+eps1;
            Ixx=Ix(:,[1,1:ncol-1]);
            c41=Iy_back.^2+Ixx.^2+eps1;
            c42=c41.^(1/2);
            c4=1./c42;
            
            % temporary a I
            I_temp=(2*lamda.*f+c1.*I_temp([2:nrow,nrow],:)+c2.*I_temp([1,1:nrow-1],:)+c3.*I_temp(:,[2:ncol,ncol])+c4.*I_temp(:,[1,1:ncol-1]))./(2*lamda+c1+c2+c3+c4);
            
        end
        Imgu=Imgu+I_temp;
        Imguf{n}=I_temp;
        f=f-I_temp;
        lamda=lamda*2;
        
    end
        
    dx=1;
    dy=1;
    
    num=14;
    for  ws=1:num
        
        rmax = max(max(Imguf{ws}));
        for m = 1:M
            for n = 1:N
                Imguf{ws}(m,n) = round(Imguf{ws}(m,n)*255/rmax);  % change to 0-255
                
            end
        end
        
        minImguf=min(min(Imguf{ws}));
        Imguf{ws}=Imguf{ws}-minImguf;
        Imguf{ws}(Imguf{ws}>255)=255;
        
        
        [tt1,e1,cmtx] = myThreshold(Imguf{ws});
        ms = 45;
        mk = msk(Y,ms);
        rt2 = 255*ones(M,N);
        for i=1:M
            for j=1:N
                if  Imguf{ws}(i,j)>=tt1 && mk(i,j)==255
                    rt2(i,j)=0;
                end
            end
        end
                        
        J{ws} = im2bw(rt2);
        J{ws}= ~J{ws};
        [Label,Num] = bwlabel(J{ws});
        Lmtx = zeros(Num+1,1);
        
        for i=1:M
            for j=1:N
                Lmtx(double(Label(i,j))+1) = Lmtx(double(Label(i,j))+1) + 1;
            end
        end
        sLmtx = sort(Lmtx);
        cp = 0;
        for i=1:M
            for j=1:N
                if (Lmtx(double(Label(i,j)+1)) > cp) && (Lmtx(double(Label(i,j)+1)) ~= sLmtx(Num+1,1))
                    J{ws}(i,j) = 0;
                else
                    J{ws}(i,j) = 1;
                end
            end
        end
        
        for i=1:M
            for j=1:N
                if mk(i,j)==0
                    J{ws}(i,j)=1;
                end
            end
        end
        name = {'01';'02';'03';'04';'05';'06';'07';'08';'09';'10';'11';'12';'13';'14'};
        outName=strcat(outFile,'/',name(ws),'.jpg');
        outName=cell2mat(outName);
        imwrite(J{ws},outName,'jpg');
        
        %%%denoise
        J{ws}=~J{ws}; 
        [labelmap, num]=bwlabel(J{ws},8);
        for i=1:num
            if(sum(sum(labelmap==i))<100)
                J{ws}(labelmap==i)=0;
            end
        end
        
        %%%filling
        se=strel('square',3); 
        img=imdilate(J{ws},se);
        img1=imerode(img,se);
        outName1=strcat(outFile,'/',name(ws),'.png');
        outName1=cell2mat(outName1);
        imwrite(img1,outName1,'png');
        
        %%%skeleton
        bw=bwmorph(skeleton(img1)>35,'skel',Inf); 
        outName2=strcat(outFile,'/',name(ws),'.tif');
        outName2=cell2mat(outName2);
        imwrite(bw,outName2,'tif');
    end
end
