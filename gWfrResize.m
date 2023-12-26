function [Head,Data]=gWfrResize(Head,Data,divXY,rFl)
%Resize raster image or matrix with world-data correction.
%function [Head,Data1]=gWfrResize(Head,Data,divXY,rFl), where
%Head - header structure, which includes:
%Head.Color - colormap for palette image;
%Head.Wf - world-file values: [scaleX skewY skewX scaleY left_up_angle_X left_up_angle_Y];
%Head.K=[a b] - multiple (a) and shift (b) for "Data Original Value" calculation from Color; DataOriginalValue=a*Color+b;
%Head.BgVal - the code of “absent” color (it is means – no data for raster’s pixel with BgVal code);
%Data - raster-image or matrix-image data matrix;
%divXY - divider [divX divY] for [scaleX skewY skewX scaleY];
%rFl - resize method name: 1) repeat or delete values - 'Wfr'; 2) use "imresize" function from Image Processing Toolbox with methods 'nearest','bilinear','bicubic','box','triangle','cubic','lanczos2','lanczos3'.
%Example1: [Head1,Data1]=gWfrResize(Head,Data,[2 2],'Wfr');
%Example2: [Head2,Data2]=gWfrResize(Head,Data,Head0.Wf([1 4])./Head.Wf([1 4]),'Wfr');

switch rFl,
    case {'Wfr','wfr'},
        %resize along X
        lx=sqrt(Head.Wf(1).^2+Head.Wf(3).^2);
        no=0:(size(Data,2)-1);to=no.*lx;tn=0:lx*divXY(1):to(end);
        nn=round(interp1(to,no,tn,'linear'))+1;
        Data=Data(:,nn);Head.Wf([1 3])=Head.Wf([1 3]).*divXY(1);
        %resize along Y
        ly=sqrt(Head.Wf(2).^2+Head.Wf(4).^2);
        no=0:(size(Data,1)-1);to=no.*ly;tn=0:ly*divXY(2):to(end);
        nn=round(interp1(to,no,tn,'linear'))+1;
        Data=Data(nn,:);Head.Wf([2 4])=Head.Wf([2 4]).*divXY(2);
    case {'nearest','bilinea','bicubic','box','triangle','cubic','lanczos2','lanczos3'},
        lx=sqrt(Head.Wf(1).^2+Head.Wf(3).^2);
        NumX=round((size(Data,2)-1).*lx./(lx.*divXY(1)))+1; %new NumX
        Head.Wf([1 3])=Head.Wf([1 3]).*divXY(1);
        ly=sqrt(Head.Wf(2).^2+Head.Wf(4).^2);
        NumY=round((size(Data,1)-1).*ly./(ly.*divXY(2)))+1; %new NumY
        Head.Wf([2 4])=Head.Wf([2 4]).*divXY(2);
        %resize along XY
        Data=imresize(Data,Head.Color,[NumY NumX],rFl,'Colormap','original');
    otherwise,
        error('gWfrResize --> rFl is bad, use: 1)''Wfr'' is repeat or delete values or 2)methods for "imresize" function from Image Processing Toolbox');
end;

%mail@ge0mlib.com 19/06/2018