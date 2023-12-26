function Data1=gWfrMatAngles(Head,Data,directCode)
%Calculate dip-angles for matrix-data (topography or bathymetry grid), using a number of methods. Warning! SkewX and skewY are zero (will be changed in future).
%function Data1=gWfrMatAngles(Head,Data), where
%Head - input header structure, which includes:
%Head.Color=[] - colormap for palette image;
%Head.Wf - world-file values: [scaleX skewY skewX scaleY left_up_angle_X left_up_angle_Y];
%Head.K=[] – multiple (a) and shift (b) for "Data Original Value" calculation from Color; DataOriginalValue=a*Color+b;
%Head.BgVal=nan – the code of “absent” color (it is means – no data for raster’s pixel with BgVal code);
%Data - input matrix-image (type double; nan is code of “absent” data);
%directCode - the direction of max-angle estimation: 2- calculate dx and dy; 4- calculate dx,dy,dxy,dyx.
%Data1 - output matrix with "angles" (see manual for calculation method description).
%Example: Data1=gWfrMat2Im(Head,Data);

switch directCode,
    case 2,
        Dat=nan([size(Data) 2]);
        if Head.Wf(2)==0&&Head.Wf(3)==0, % ---- no rotation for X and Y
            tmp=diff(Data,1,1);tmp(:,end)=tmp(:,end-1);Dat(:,:,1)=atan2([tmp;tmp(end,:)],abs(Head.Wf(4))); %diff along Data column
            tmp=diff(Data,1,2);tmp(end,:)=tmp(end-1,:);Dat(:,:,2)=atan2([tmp tmp(:,end)],abs(Head.Wf(1))); %diff along Data row
            Data1=max(abs(Dat),[],3)./pi.*180;
        else % ---- rotation presents
            error('gWfrMatAngles --> rotation angles for X and Y axis are not zero; calculation can not be applied now');
        end;
    case 4,
        Dat=nan([size(Data) 4]);
        if Head.Wf(2)==0&&Head.Wf(3)==0, % ---- no rotation for X and Y
            tmp=diff(Data,1,1);tmp(:,end)=tmp(:,end-1);Dat(:,:,1)=atan2([tmp;tmp(end,:)],abs(Head.Wf(4))); %diff along Data column
            tmp=diff(Data,1,2);tmp(end,:)=tmp(end-1,:);Dat(:,:,2)=atan2([tmp tmp(:,end)],abs(Head.Wf(1))); %diff along Data row
            tmp=reshape(Data(1:end-size(Data,1))-Data([size(Data,1)+2:end end]),size(Data,1),size(Data,2)-1);tmp(end,:)=tmp(end-1,:);Dat(:,:,3)=atan2([tmp tmp(:,end)],sqrt(Head.Wf(1).^2+Head.Wf(4).^2));
            Data=Data';
            tmp=reshape(Data(1:end-size(Data,1))-Data([size(Data,1)+2:end end]),size(Data,1),size(Data,2)-1);tmp(end,:)=tmp(end-1,:);Dat(:,:,4)=atan2([tmp tmp(:,end)]',sqrt(Head.Wf(1).^2+Head.Wf(4).^2));
            Data1=max(abs(Dat),[],3)./pi.*180;
        else % ---- rotation presents
            error('gWfrMatAngles --> rotation angles for X and Y axis are not zero; calculation can not be applied now');
        end;
    otherwise, error('directCode is not correct');
end;

%mail@ge0mlib.com 28/02/2021