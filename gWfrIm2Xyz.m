function XYZ=gWfrIm2Xyz(Head,Data,BgVal,K,SortKey)
%Convert raster-image or matrix-image and Head-structure to XYZ-data. The value of color (first palette’s column for palette image) is used for Z creation.
%function XYZ=gWfrIm2Xyz(Head,Data,BgVal,K,SortKey), where
%Head - header structure, which includes:
%Head.Color - colormap for palette image;
%Head.Wf - world-file values: [scaleX skewY skewX scaleY left_up_angle_X left_up_angle_Y];
%Head.K=[a b] – multiple (a) and shift (b) for "Data Original Value" calculation from Color; Z=DataOriginalValue=a*Color+b;
%Head.BgVal – the code of “absent” color (it is means – no data for raster’s pixel with BgVal code);
%Data - raster-image or matrix-image data matrix;
%K - forced multiple (a) and shift (b) for "Data Original Value" calculation from Color; if K==[], then used Head.K;
%BgVal - forced code of “absent” color; if BgVal==[], then used Head.BgVal; it can set to NaN (for matrix with type double); excepted in XYZ;
%SortKey - if 1 than sort along Y (values along X change quick), else sort along X (values along Y change quick);
%XYZ - rows (type double) with X,Y-coordinates and Z-data without BgVal value; if Head.K is not empty, then Z=a.*Head.Color+b.
%Example: XYZ=gWfrIm2Xyz(Head,Data,0,[],1);

if isempty(K)&&isempty(Head.K),error('gWfrIm2Xyz --> K and Head.K are empty');end;
if ~isempty(K),Head.K=K;end;
if isempty(BgVal)&&isempty(Head.BgVal),error('gWfrIm2Xyz --> BgVal and Head.BgVal are empty');end;
if ~isempty(BgVal),Head.BgVal=BgVal;end;

[Y,X]=ndgrid(0:size(Data,1)-1,0:size(Data,2)-1);
if SortKey, X=fliplr(X');Y=fliplr(Y');Data=fliplr(Data');end; %sort along Y
XY=[Head.Wf(1) Head.Wf(3) Head.Wf(5);Head.Wf(2) Head.Wf(4) Head.Wf(6)]*[X(:)';Y(:)';ones(1,numel(X))];
if isempty(Head.Color),
    if isnan(Head.BgVal), L=~isnan(Data); else L=Data~=Head.BgVal;end;
    Z=Data(L);if ~isempty(Head.K),Z=double(Z).*Head.K(1)+Head.K(2);end;
else
    if ~all(all(Head.Color(:,2:3)==[Head.Color(:,1) Head.Color(:,1)])), warning('gWfrIm2Xyz --> Color1 palleter must be gray');end;
    if isnan(Head.BgVal), L=~isnan(Data); else L=Data~=Head.BgVal;end;
    Z=Head.Color(Data(L)+1,1);if ~isempty(Head.K),Z=double(Z).*Head.K(1)+Head.K(2);end;
end;
XYZ=[XY(:,L);Z(:)'];

%mail@ge0mlib.com 04/11/2019