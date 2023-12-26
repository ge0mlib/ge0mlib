function [Head,Data]=gWfrCut(Head,Data,LimS)
%Cut rectangle from raster-image or matrix-image and correct world-data; cutting zone input in pixels.
%function [Head,Data]=gWfrCut(Head,Data,LimS), where
%Head – header structure, which includes:
%Head.Color – colormap for palette image;
%Head.Wf – world-file values: [scaleX skewY skewX scaleY left_up_angle_X left_up_angle_Y];
%Head.K=[a b] – multiple (a) and shift (b) for "Data Original Value" calculation from Color; Z=DataOriginalValue=a*Color+b;
%Head.BgVal – the code of “absent” color (it is means – no data for raster’s pixel with BgVal code);
%Data – raster-image or matrix-image data matrix;
%LimS – limits for cut zone [minX maxX minY maxY] in pixels.
%^+Y
%|
%|
%----> +X
%Example: [Head,Data]=gWfrCut(Head,Data,[100 900 300 800);
%========================
%Line1_A: pixel size in the x-direction in map units;
%Line2_D: rotation (skew) parameter about y-axis;
%Line3_B: rotation (skew) parameter about x-axis;
%Line4_E: pixel size in the y-direction in map units, almost always NEGATIVE;
%Line5_C: x-coordinate of center of upper left pixel;
%Line6_F: y-coordinate of center of upper left pixel.
%x'=Ax+By+C; y'=Dx+Ey+F.
%=========================

Data=Data(LimS(3):LimS(4),LimS(1):LimS(2),:);
Z=Head.Wf;
Head.Wf(5)=Z(1).*(LimS(1)-1)+Z(3).*(LimS(3)-1)+Z(5);
Head.Wf(6)=Z(2).*(LimS(1)-1)+Z(4).*(LimS(3)-1)+Z(6);

%mail@ge0mlib.com 19/06/2018