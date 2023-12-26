function [Head,Data]=gWfrRead(fname)
%Read raster-image file with world-file. Example: *.tif and *.tfw.
%function [Head,Data]=gWfrRead(fname), where
%fname - image’s file name with extension (the world-file extension created as first and last letters of the image's extension and ending with a 'w');
%Head - header structure, which includes:
%Head.Color - colormap for palette image;
%Head.Wf - world-file values: [scaleX skewY skewX scaleY left_up_angle_X left_up_angle_Y];
%Head.K=[a b] - multiple (a) and shift (b) for "Data Original Value" calculation from Color; DataOriginalValue=a*Color+b;
%Head.BgVal - the code of “absent” color (it is means – no data for raster’s pixel with BgVal code);
%Data - raster-image data matrix.
%Coordinates Axis (world-file):
%^+Y
%|
%|
%----> +X
%Example: [Head,Data]=gWfrRead('d:\03_Block-3_SSS_Mosaic\Block-3_2.tif');
%======================
%The world file is an ASCII text file, which contains the following lines:
%Line1_A: pixel size in the x-direction in map units;
%Line2_D: rotation (skew) parameter about y-axis;
%Line3_B: rotation (skew) parameter about x-axis;
%Line4_E: pixel size in the y-direction in map units, almost always NEGATIVE;
%Line5_C: x-coordinate of center of upper left pixel;
%Line6_F: y-coordinate of center of upper left pixel.
%File's example:
%0.10001159
%0
%0
%-0.1
%684083.88367
%5887188.48824 
%Forward conversion: [x';y']=[A B C; D E F]*[x;y;1] or x'=Ax+By+C; y'=Dx+Ey+F.
%Reverse conversion: x=(Ex'-By'+BF-EC)/(AE-DB); y'=(-Dx'+Ay'+DC-AF)/(AE-DB).
%=======================
%The World-file additional lines:
%Line7_key: 9999999999;
%Line8_aS: multiple for raster color;
%Line9_bS: shift for raster color.
%Line10_BgVal: the code of “absent” color (it is means – no data for raster’s pixel with BgVal code).
%File's example:
%0.10001159
%0
%0
%-0.1
%684083.88367
%5887188.48824 
%9999999999
%-0.01
%-38
%255
%=======================

[Data,Head.Color]=imread(fname);L=find(fname=='.');Head.Wf=dlmread([fname(1:L(end)) fname(L(end)+1) fname(end) 'w'])';
if (numel(Head.Wf)==10)&&(Head.Wf(7)==9999999999),
    disp('gWfrImRead --> Head.K=[a b] and Head.BgVal were read from world-file');
    Head.K=Head.Wf(8:9);Head.BgVal=Head.Wf(10);Head.Wf(7:10)=[];
else
    Head.K=[];Head.BgVal=[];
end;

%mail@ge0mlib.com 19/06/2018