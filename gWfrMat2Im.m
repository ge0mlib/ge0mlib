function [Head,Data]=gWfrMat2Im(Head,Data,MinMax,BgVal,imType)
%Convert matrix-image to raster-image: palette (254 levels + “absent” color=255, grey paletter) or grayscale (65534 levels + “absent” color=65535).
%function [Head,Data]=gWfrMat2Im(Head,Data,MinMax,BgVal,imType), where
%Head - input header structure, which includes:
%Head.Color=[] - colormap for palette image;
%Head.Wf - world-file values: [scaleX skewY skewX scaleY left_up_angle_X left_up_angle_Y];
%Head.K=[] – multiple (a) and shift (b) for "Data Original Value" calculation from Color; DataOriginalValue=a*Color+b;
%Head.BgVal=nan – the code of “absent” color (it is means – no data for raster’s pixel with BgVal code);
%Data - input matrix-image (type double);
%MinMax - minimal and maximal values link to level-0 and level-254/65534; if empty, than min and max will calculate from Data;
%BgVal - code of “absent” color for palette (palette image only);
%imType - raster-image type: 'uint8' or 'palette'- palette, 'uint16' or 'grayscale' - grayscale without pallete;
%Head - output header structure, which includes:
%Head.Color - linear palette for palette-image or empty for grayscale-image;
%Head.Wf - world-file values: [scaleX skewY skewX scaleY left_up_angle_X left_up_angle_Y];
%Head.K=[a b] - multiple (a) and shift (b) for "Data Original Value"; DataOriginalValue=a*Color+b;
%Head.BgVal– the code of “absent” color, will be set 255 for palette-image and 65535 for grayscale-image;
%Data - output raster-image data matrix.
%Example: [Head1,Data1]=gWfrMat2Im(Head,Data,[],1,'palette');

Lz=isnan(Data);
if isempty(MinMax), L=~(isnan(Data)|isinf(Data)|Lz);MinMax=[min(Data(L)) max(Data(L))];end;
switch imType,
    case {'uint8','palette'},
        stp=(MinMax(2)-MinMax(1))./abs(MinMax(2)-MinMax(1))./254;Data=round((Data-MinMax(1))./abs(MinMax(2)-MinMax(1))./stp);
        Data(Data>254)=254;Data(Data<0)=0;Data(Lz)=256;Data=uint8(Data);
        colr=[0:stp(1):1 BgVal]';Head.Color=[colr colr colr];
        Head.K=[(MinMax(2)-MinMax(1)) MinMax(1)];Head.BgVal=255;
    case {'uint16','grayscale'},
        stp=(MinMax(2)-MinMax(1))./abs(MinMax(2)-MinMax(1))./65534;Data=round((Data-MinMax(1))./abs(MinMax(2)-MinMax(1))./stp);
        Data(Data>65534)=65534;Data(Data<0)=0;Data(Lz)=65535;Data=uint16(Data);
        Head.Color=[];
        Head.K=[(MinMax(2)-MinMax(1))./65534 MinMax(1)];Head.BgVal=65535;
    otherwise
        error('gWfrMat2Im --> un-known raster-image format');
end;

%mail@ge0mlib.com 04/05/2018