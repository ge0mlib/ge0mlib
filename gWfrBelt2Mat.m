function [Head,DataOut]=gWfrBelt2Mat(Data,DataE,DataN,dd)
%Mat-data using Belt-data.

%====Input====
%Data- "reflection points";
%DataE- easting for "reflection points"(m);
%DataN- northing for "reflection points"(m);
%dd- step for Mat (scaleX and scaleY).
%====Output====
%Head - header structure, which includes:
%Head.Color=[] - colormap, empty for matrix image;
%Head.Wf - world-file values: [scaleX 0 0 scaleY left_up_angle_X left_up_angle_Y];
%Head.K=[] – multiple (a) and shift (b) for "Data Original Value" calculation from Color; DataOriginalValue=a*Color+b;
%Head.BgVal=nan – the code of “absent” color (it is means – no data for raster’s pixel with BgVal code);
%DataOut - matrix-image (type double);
%Coordinates Axis (world-file):
%^+Y (N)
%|
%|
%----> +X (E)
%Example: [Head,Data]=gWfrXyz2Mat(XYZ,[0 5 1 5],[5 0 5 1]);

[xq,yq]=ndgrid(min(DataN(:)):dd:max(DataN(:)),min(DataE(:)):dd:max(DataE(:)));
Data([1 end],:)=nan;Data(:,[1 end])=nan;
DataOut=griddata(DataN,DataE,Data,xq,yq,'nearest');DataOut=flipud(DataOut);
Head.Wf=[dd 0 0 -dd min(DataE(:)) max(DataN(:))]; %[scaleX 0 0 scaleY left_up_angle_X left_up_angle_Y]
Head.Color=[];Head.K=[];Head.BgVal=nan;

%mail@ge0mlib.ru 09/02/2022