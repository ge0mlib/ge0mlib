function [Head,Data]=gWfrIm2Mat(Head,Data,BgVal,K)
%Convert raster-image (palette or grayscale) to matrix-image (type double).
%function [Head,Data]=gWfrIm2Mat(Head,Data,BgVal,K), where
%Head - input header structure, which includes:
%Head.Color - palette for palette-image or empty for grayscale-image;
%Head.Wf - world-file values: [scaleX skewY skewX scaleY left_up_angle_X left_up_angle_Y];
%Head.K=[a b] - multiple (a) and shift (b) for "Data Original Value"; DataOriginalValue=a*Color+b;
%Data - input raster-image data matrix.
%K - forced multiple (a) and shift (b) for "Data Original Value" calculation from Color; if K==[], then used Head.K;
%BgVal - forced code of “absent” color; if BgVal==[], then used Head.BgVal;
%Head - output header structure, which includes:
%Head.Color=[] - colormap, empty for matrix image;
%Head.Wf - world-file values: [scaleX skewY skewX scaleY left_up_angle_X left_up_angle_Y];
%Head.K=[] – multiple (a) and shift (b) for "Data Original Value" calculation from Color; DataOriginalValue=a*Color+b;
%Head.BgVal=nan – the code of “absent” color (it is means – no data for raster’s pixel with BgVal code);
%Data - output matrix-image (type double);
%Example: [Head1,Data1]=gWfrIm2Mat(Head,Data,[],[]);

if isempty(K)&&isempty(Head.K)&&~isa(Data1,'double'),error('gWfrIm2Mat --> K and Head.K are empty');end;
if ~isempty(K),Head.K=K;end;
if isempty(BgVal)&&isempty(Head.BgVal),error('gWfrIm2Mat --> BgVal and Head.BgVal are empty');end;
if ~isempty(BgVal),Head.BgVal=BgVal;end;

Data=double(Data);
if isnan(Head.BgVal), L=isnan(Data); else L=Data==Head.BgVal;end;
if isempty(Head.Color),
    %mean the Data is grayscale-image
    Data=Data.*Head.K(1)+Head.K(2);
    Data(L)=nan;Head.Color=[];Head.K=[];Head.BgVal=nan;
else
    %mean the Data is palette-image
    Data(~L)=Head.Color(Data(~L)+1,1).*Head.K(1)+Head.K(2);
    Data(L)=nan;Head.Color=[];Head.K=[];Head.BgVal=nan;
end;

%mail@ge0mlib.com 04/05/2018