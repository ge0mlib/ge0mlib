function [Head1n,Data1n,Head2n,Data2n]=gWfrCombineColors(Head1,Data1,Head2,Data2,MinMax,imType)
%Combine colors/palettes for raster-image1 and raster-image2 using Head.K field (renew colors/raletter are linear).
%function [Head1n,Data1n,Head2n,Data2n]=gWfrMergeColor2(Head1,Data1,Head2,Data2), where
%Head - header structure, which includes:
%Head.Color - colormap for palette image;
%Head.Wf - world-file values: [scaleX skewY skewX scaleY left_up_angle_X left_up_angle_Y];
%Head.K=[a b] – multiple (a) and shift (b) for "Data Original Value" calculation from Color; Z=DataOriginalValue=a*Color+b;
%Head.BgVal – the code of “absent” color (it is means – no data for raster’s pixel with BgVal code);
%Data - raster-image or matrix-image data matrix;
%Head1,Data1,Head2,Data2 - input Data and Header; 
%Head1n,Data1n,Head2n,Data2n - output Data and Header; Head1n.K==Head2n.K; the Head.BgVal will be set 255 for palette-image and 65535 for grayscale-image; BgVal value for palette is [0 0 0];
%imType - forsed output raster-image type: 'uint8' or 'palette'- palette, 'uint16' or 'grayscale' - grayscale without pallete;
%MinMax - minimal and maximal values link to level-0 and level-254/65534; if empty, than min and max will calculate from Data.
%Algorithm: 1) convert raster-image to matrix-image; 2) find [min max] for matrix-images; 3) convert matrix-image to raster-image.
%Example: [Head1n,Data1n,Head2n,Data2n]=gWfrCombineColors(Head1,Data1,Head2,Data2,[],[]);

if isempty(Head1.K)&&~isa(Data1,'double'), error('gWfrCombineColors --> Need Head1.K values for raster-image1');end; %check than image without Head.K is matrix-image
if isempty(Head2.K)&&~isa(Data2,'double'), error('gWfrCombineColors --> Need Head2.K values for raster-image2');end; %check than image without Head.K is matrix-image
if isempty(imType),
    if isempty(Head1.Color)||isempty(Head2.Color), imType='uint16'; else imType='uint8';end; %find output raster-images type
end;
[Head1z,Data1z]=gWfrIm2Mat(Head1,Data1,[],[]);[Head2z,Data2z]=gWfrIm2Mat(Head2,Data2,[],[]); %convert raster-images to matrix-images
if isempty(MinMax), MinMax=[min([min(Data1z(:)) min(Data2z(:))]) max([max(Data1z(:)) max(Data2z(:))])];end; %calculate MinMax values
[Head1n,Data1n]=gWfrMat2Im(Head1z,Data1z,MinMax,1,imType); %convert matrix-images to raster-images; BgVal value for palette is [1 1 1]
[Head2n,Data2n]=gWfrMat2Im(Head2z,Data2z,MinMax,1,imType); %convert matrix-images to raster-images; BgVal value for palette is [1 1 1]

%mail@ge0mlib.com 19/06/2018