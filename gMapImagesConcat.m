function gMapImagesConcat(dName,nIm,szIm,cRule,finSize)
%Concatenate a jpg-images from defined folders to new images (grouped), using defined sizes and rules.
%function gMapImagesConcat(dName,nIm,szIm,cRule), where
%dName - folder's name with images preliminary sorted by alphabet;
%nIm - number images for single concatenation;
%szIm - "size" of Images and image-border in some units; there are a number of cells from first image to last with format:
%   [vert_size_or_nan, horizontal_size_or_nan, border_thickness]; if we use nan, than image resize proportionally.
%cRule - concatenate sequence for images; each two concatenated images create one "new" image (additional number which can be used for follow concatenations);
%   there are a number of cells for each concatenation with format:
%   [image1_num,concat_side(0-right,1-down),concat_point for both images(1-up/left,2-middle,3-down/right),image2_num_will_concatenated_to_1]
%finSize - "imresize" function parameter from Image Toolbox, there are
%   [numrows numcols] - returns image B that has the number of rows and columns specified by the two-element vector [numrows numcols];
%   scale - returns image B that is scale times the size of A.
%The concatenated images saved at dName\Concat folder.
%Example:
%parameters and operations step by step:
%3 - number of images in group;
%[8,nan,0.1] - image-1, vertical size 8, horizontal size is proportional, border thickness is 0.1;
%[8,nan,0.1] - image-2, vertical size 8, horizontal size is proportional, border thickness is 0.1;
%[7,nan,0.1] - image-3, vertical size 7, horizontal size is proportional, border thickness is 0.1;
%[1,0,2,2] - first concatenation: to image-1, right side, middle of right-side, concatenate with image-2 middle of left-side); the image-4 is created;
%[4,1,1,3] - second concatenation: to image-4, down side, left of down-side, concatenate with image-3 left point of up-side); the image-5 is created and saved to dName\Concat folder.
%Function's call:
%gMapImagesConcat('e:\018\proc1\',3,{[8,nan,0.02],[8,nan,0.02],[7,nan,0.02]},{[1,0,2,2],[4,1,2,3]},[]);

dz=dir(dName);dz([dz(:).isdir])=[];fName=char(dz(:).name);fName=sortrows(fName);
[~,w]=dos(['dir ',dName,'/b']);
if ~contains(w,['Concat',char(10)]),dos(['mkdir ',dName,'\Concat']);end
for n=1:nIm:size(fName,1)
    c=cell(nIm,1);
    for nn=1:nIm,fNameN=deblank(fName(n+nn-1,:));c{nn}=imread([dName,'\',fNameN]);disp(fNameN);end %read nIm files
    sc=zeros(nIm*2,1);for nn=1:nIm,sc(nn*2-1:nn*2)=[size(c{nn},1) size(c{nn},2)]./(szIm{nn}(1:2)-szIm{nn}(3));end;scl=max(sc(~isnan(sc))); %find max points-per-unit
    for nn=1:nIm %resize images to "max points-per-unit"
        if isnan(szIm{nn}(1)),c{nn}=imresize(c{nn},[round(size(c{nn},1)./size(c{nn},2).*(szIm{nn}(2)-szIm{nn}(3))*scl) round((szIm{nn}(2)-szIm{nn}(3))*scl)]);
        elseif isnan(szIm{nn}(2)),c{nn}=imresize(c{nn},[round((szIm{nn}(1)-szIm{nn}(3))*scl) round(size(c{nn},2)./size(c{nn},1).*(szIm{nn}(1)-szIm{nn}(3))*scl)]);
        else,c{nn}=resize(c{nn},[round((szIm{nn}(1)-szIm{nn}(3))*scl) round((szIm{nn}(2)-szIm{nn}(3))*scl)]);
        end
    end
    for nn=1:nIm %add borders to images, usig "max points-per-unit"
        brd=round(szIm{nn}(3).*scl);
        tmp=uint8(zeros([size(c{nn},1)+2.*brd size(c{nn},2)+2.*brd size(c{nn},3)]));
        tmp(brd+1:end-brd,brd+1:end-brd,:)=c{nn};
        c{nn}=tmp;
    end
    for nn=1:numel(cRule) %concatenate images
        if cRule{nn}(2)==0 %to right side
            c{nIm+nn}=uint8(zeros(max([size(c{cRule{nn}(1)},1) size(c{cRule{nn}(4)},1)]),size(c{cRule{nn}(1)},2)+size(c{cRule{nn}(4)},2),3)+255);
            if cRule{nn}(3)==1 %up
                c{nIm+nn}(1:size(c{cRule{nn}(1)},1),1:size(c{cRule{nn}(1)},2),:)=c{cRule{nn}(1)};
                c{nIm+nn}(1:size(c{cRule{nn}(4)},1),size(c{cRule{nn}(1)},2)+1:end,:)=c{cRule{nn}(4)};
            elseif cRule{nn}(3)==2 %middle
                tmp=fix((size(c{nIm+nn},1)-size(c{cRule{nn}(1)},1))./2);c{nIm+nn}(tmp+1:tmp+size(c{cRule{nn}(1)},1),1:size(c{cRule{nn}(1)},2),:)=c{cRule{nn}(1)};
                tmp=fix((size(c{nIm+nn},1)-size(c{cRule{nn}(4)},1))./2);c{nIm+nn}(tmp+1:tmp+size(c{cRule{nn}(4)},1),size(c{cRule{nn}(1)},2)+1:end,:)=c{cRule{nn}(4)};
            elseif cRule{nn}(3)==3 %down
                c{nIm+nn}(end-size(c{cRule{nn}(1)},1)+1:end,1:size(c{cRule{nn}(1)},2),:)=c{cRule{nn}(1)};
                c{nIm+nn}(end-size(c{cRule{nn}(4)},1)+1:end,size(c{cRule{nn}(1)},2)+1:end,:)=c{cRule{nn}(4)};
            end
        elseif cRule{nn}(2)==1 %to bottom side
            c{nIm+nn}=uint8(zeros(size(c{cRule{nn}(1)},1)+size(c{cRule{nn}(4)},1),max([size(c{cRule{nn}(1)},2) size(c{cRule{nn}(4)},2)]),3)+255);
            if cRule{nn}(3)==1 %left
                c{nIm+nn}(1:size(c{cRule{nn}(1)},1),1:size(c{cRule{nn}(1)},2),:)=c{cRule{nn}(1)};
                c{nIm+nn}(size(c{cRule{nn}(1)},1)+1:end,1:size(c{cRule{nn}(4)},2),:)=c{cRule{nn}(4)};
            elseif cRule{nn}(3)==2 %middle
                tmp=fix((size(c{nIm+nn},2)-size(c{cRule{nn}(1)},2))./2);c{nIm+nn}(1:size(c{cRule{nn}(1)},1),tmp+1:tmp+size(c{cRule{nn}(1)},2),:)=c{cRule{nn}(1)};
                tmp=fix((size(c{nIm+nn},2)-size(c{cRule{nn}(4)},2))./2);c{nIm+nn}(size(c{cRule{nn}(1)},1)+1:end,tmp+1:tmp+size(c{cRule{nn}(4)},2),:)=c{cRule{nn}(4)};
            elseif cRule{nn}(3)==3 %right
                c{nIm+nn}(1:size(c{cRule{nn}(1)},1),end-size(c{cRule{nn}(1)},2)+1:end,:)=c{cRule{nn}(1)};
                c{nIm+nn}(size(c{cRule{nn}(1)},1)+1:end,end-size(c{cRule{nn}(4)},2)+1:end,:)=c{cRule{nn}(4)};
            end
        end
    end
    nn=nIm+numel(cRule);if ~isempty(finSize),c{nn}=imresize(c{nn},finSize);end
    imwrite(c{nn},[dName,'\Concat\',deblank(fName(n,:))]);   
end

%mail@ge0mlib.com 07/09/2021