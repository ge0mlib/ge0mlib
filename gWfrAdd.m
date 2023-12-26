function [Head0,Data0]=gWfrAdd(Head,Data,AddLim,BgVal)
%Adds/cut borders for raster-image or matrix-image and correct world-data; borders value set in pixels.
%function [Head,Data]=gTiffCut(Head,Data,LimS), where
%Head – header structure, which includes:
%Head.Color – colormap for palette image;
%Head.Wf – world-file values: [scaleX skewY skewX scaleY left_up_angle_X left_up_angle_Y];
%Head.K=[a b] – multiple (a) and shift (b) for "Data Original Value" calculation from Color; Z=DataOriginalValue=a*Color+b;
%Head.BgVal – the code of “absent” color (it is means – no data for raster’s pixel with BgVal code);
%Data – raster-image or matrix-image data matrix;
%AddLim - adds for image border in pixels [addX_left addX_right addY_up addY_down] in pixels; positive values are added, negative - are cut;
%BgVal - forced code of “absent” color; if BgVal==[], then used Head.BgVal; it can set to NaN (for matrix-image with type double);
%^+Y
%|
%|
%----> +X
%Example: [Head,Data]=gWfrCut(Head,Data,[100 900 300 800],255);
%========================
%Line1_A: pixel size in the x-direction in map units;
%Line2_D: rotation (skew) parameter about y-axis;
%Line3_B: rotation (skew) parameter about x-axis;
%Line4_E: pixel size in the y-direction in map units, almost always NEGATIVE;
%Line5_C: x-coordinate of center of upper left pixel;
%Line6_F: y-coordinate of center of upper left pixel.
%x'=Ax+By+C; y'=Dx+Ey+F.
%=========================

if isempty(BgVal)&&isempty(Head.BgVal),error('gWfrAdd --> BgVal and Head.BgVal are empty');end;
if ~isempty(BgVal),Head.BgVal=BgVal;end;

if ~isnan(Head.BgVal), Data0=repmat(feval(class(Data),Head.BgVal),size(Data,1)+AddLim(3)+AddLim(4),size(Data,2)+AddLim(1)+AddLim(2),size(Data,3));
else Data0=nan(size(Data,1)+AddLim(3)+AddLim(4),size(Data,2)+AddLim(1)+AddLim(2),size(Data,3));
end;
if AddLim(1)>=0, B1=AddLim(1);C1=0; else B1=0;C1=-AddLim(1);end;
if AddLim(2)>=0, B2=B1+size(Data,2)-C1;C2=size(Data,2); else B2=B1+size(Data,2)-C1+AddLim(2);C2=size(Data,2)+AddLim(2);end;
if AddLim(3)>=0, B3=AddLim(3);C3=0; else B3=0;C3=-AddLim(3);end;
if AddLim(4)>=0, B4=B3+size(Data,1)-C3;C4=size(Data,1); else B4=B3+size(Data,1)-C3+AddLim(4);C4=size(Data,1)+AddLim(4);end;
Data0((B3+1):B4,(B1+1):B2,:)=Data((C3+1):C4,(C1+1):C2,:);

Head0=Head;
Head0.Wf(5)=-AddLim(1).*Head.Wf(1)-AddLim(3).*Head.Wf(3)+Head.Wf(5);
Head0.Wf(6)=-AddLim(1).*Head.Wf(2)-AddLim(3).*Head.Wf(4)+Head.Wf(6);

%mail@ge0mlib.com 19/06/2018