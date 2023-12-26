function [Head,Data]=gWfrXyz2Mat(XYZ,LX,LY)
%Convert XYZ-data to matrix-image and Head-structure. Z values write to matrix, not existing values set to nan. SkewX and skewY must be zero.
%function function [Head,Data]=gWfrXyz2Mat(XYZ,LX,LY), where
%XYZ - rows with X,Y-coordinates and Z-data.
%LX=[lx_x1 lx_y1 lx_x2 lx_y2] is horizontal segment along X axis;
%LY=[ly_x1 ly_y1 ly_x2 ly_y2] is vertical segment along Y axis;
%if grid-web lines parallel to X and Y axis, than can use LX=web-step-along-X, LY=web-step-along-Y.
%Head - header structure, which includes:
%Head.Color=[] - colormap, empty for matrix image;
%Head.Wf - world-file values: [scaleX 0 0 scaleY left_up_angle_X left_up_angle_Y];
%Head.K=[] – multiple (a) and shift (b) for "Data Original Value" calculation from Color; DataOriginalValue=a*Color+b;
%Head.BgVal=nan – the code of “absent” color (it is means – no data for raster’s pixel with BgVal code);
%Data - matrix-image (type double);
%Coordinates Axis (world-file):
%^+Y (N)
%|
%|
%----> +X (E)
%Example: function [Head,Data]=gWfrXyz2Mat(XYZ,[0 5 1 5],[5 0 5 1]);

if ischar(XYZ), XYZ=dlmread(XYZ)';end;
if size(XYZ,1)~=3, error('gWfrXyz2Mat --> XYZ must containe 3 raws');end;
if (numel(LX)==1&&numel(LY)==1)||(((LY(3)-LY(1))==0)&&((LX(4)-LX(2))==0)), % ---- no rotation for X and Y
    if numel(LX)==1&&numel(LY)==1,dx=LX;dy=LY; else dx=LX(3)-LX(1);dy=LY(4)-LY(2);end;
    In2=[round((XYZ(1,:)-min(XYZ(1,:)))./dx)+1;round((max(XYZ(2,:))-(XYZ(2,:)))./dy)+1];
    XYZ(3,XYZ(3,:)==0)=inf; %mark zeros as inf
    Data=full(sparse(In2(2,:)',In2(1,:)',XYZ(3,:)')); %create full matrix
    Data(Data==0)=nan;Data(Data==inf)=0; %change 'zeros' to nan, inf to zeros
    Head.Wf=[dx 0 0 -dy min(XYZ(1,:)) max(XYZ(2,:))]; %[scaleX 0 0 scaleY left_up_angle_X left_up_angle_Y]
    Head.Color=[];Head.K=[];Head.BgVal=nan;
elseif (LY(4)-LY(2))/(LX(3)-LX(1))==(LY(3)-LY(1))/(LX(4)-LX(2)), % ---- rotation presents, but angle between matrix's axis is 90 deg
    error('gWfrXyz2Mat --> sorry, this feature is not ready now');
else % ---- rotation presents, but angle between matrix's axis is not 90 deg
    error('gWfrXyz2Mat --> rotation angles for X and Y axis are not zero and different; world-data file format can not be applied');
end;

%mail@ge0mlib.com 06/07/2018