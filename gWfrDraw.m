function gWfrDraw(Head,Data,figNum,key)
%Draw raster-image or matrix-image in world-data axis.
%function gWfrDraw(Head,Data,figNum,key), where
%Head - header structure, which includes:
%Head.Color - colormap for palette image;
%Head.Wf - world-file values: [scaleX skewY skewX scaleY left_up_angle_X left_up_angle_Y];
%Head.K=[a b] – multiple (a) and shift (b) for "Data Original Value" calculation from Color; DataOriginalValue=a*Color+b;
%Head.BgVal – the code of “absent” color (it is means – no data for raster’s pixel with BgVal code);
%Data - raster-image or matrix-image data matrix;
%figNum - figure number;
%key - drawing method: 1) is image with pixels numbers in axis; 2) is image with axis constructed from Head.Wf (angles must be zero); 3) plot3 with axis constructed from Head.Wf; 4) is surf with axis constructed from Head.Wf.
%Example: gWfrDraw(Head,Data,100,1);

%if length(size(Data))~=2, error('gWfrDraw --> Data dimensions must be 2 (2D-matrix)');end;
if size(Data,3)==4, Data(:,:,4)=[];end;
switch key,
    case 1,
        figure(figNum);
        if numel(size(Data))==2,imagesc(Data);if ~isempty(Head.Color),colormap(gca,Head.Color);end;
        elseif size(Data,3)==3,image(Data);
        elseif size(Data,3)==4,image(Data(:,:,1:3),'AlphaData',Data(:,:,4),'AlphaDataMapping','direct');
        end;
        axis xy equal;set(gca,'color','none');
    case 2,
        if (Head.Wf(2)~=0)||(Head.Wf(3)~=0), warning('gWfrDraw --> Rotation angles is not 0! Drawn axis are not correct!');end;
        aX=(0:(size(Data,2))-1).*Head.Wf(1)+Head.Wf(5);%- vector for coordinates along X-axis;
        aY=(0:(size(Data,1))-1).*Head.Wf(4)+Head.Wf(6);%- vector for coordinates along Y-axis.
        figure(figNum);
        if numel(size(Data))==2,imagesc(aX,aY,Data);if ~isempty(Head.Color),colormap(gca,Head.Color);end;
        elseif size(Data,3)==3,image(aX,aY,Data);
        elseif size(Data,3)==4,image(aX,aY,Data(:,:,1:3),'AlphaData',Data(:,:,4),'AlphaDataMapping','direct');
        end;
        axis xy equal;set(gca,'color','none');
    case 3,
        [Y,X]=ndgrid(1:size(Data,1),1:size(Data,2));
        XY=[Head.Wf(1) Head.Wf(3) Head.Wf(5);Head.Wf(2) Head.Wf(4) Head.Wf(6)]*[X(:)';Y(:)';ones(1,numel(X))];
        if isempty(Head.BgVal),
            figure(figNum);plot3(XY(1,:),XY(2,:),Data(:)','.');axis xy;
        else
            if isnan(Head.BgVal), L=~isnan(Data(:)); else L=Data(:)~=Head.BgVal;end;
            figure(figNum);plot3(XY(1,L),XY(2,L),Data(L)','.');axis xy;
        end;
    case 4,
        [Y,X]=ndgrid(1:size(Data,1),1:size(Data,2));
        XY=[Head.Wf(1) Head.Wf(3) Head.Wf(5);Head.Wf(2) Head.Wf(4) Head.Wf(6)]*[X(:)';Y(:)';ones(1,numel(X))];
        figure(figNum);surf(reshape(XY(1,:),size(X)),reshape(XY(2,:),size(X)),Data);axis xy;shading interp;
        if ~isempty(Head.Color),colormap(gca,Head.Color);end;
end;

%mail@ge0mlib.com 11/02/2022