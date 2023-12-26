function gWfrXyzDraw(XYZ,figNum,key)
%Draw XYZ-points.
%function gWfrXyzDraw(XYZ,figNum,key), where
%XYZ - X,Y,Z-data in 3-rows-vector;
%figNum - figure number;
%key - drawing method: 1) draw plot(X,Y) in the plane like to postmap, axis equal; 2) draw plot3(X,Y,Z) in 3D, axis not equal;
%the "Data cursor" instrument can used to draw X,Y,Z values for point; when drawing, the values X,Y copy to clipboard.
%Example: XYZ=dlmread('e:\example1.pts');gWfrXyzDraw(XYZ',10,1);

if size(XYZ,1)~=3, error('gWfrXyzDraw --> XYZ must containe 3 raws');end;
switch key,
    case 1,
        a=figure(figNum);dcm_obj=datacursormode(a);set(dcm_obj,'UpdateFcn',{@gWfrXyzDrawCallback,XYZ});
        figure(figNum);plot(XYZ(1,:),XYZ(2,:),'.b');axis equal;
    case 2,
        a=figure(figNum);dcm_obj=datacursormode(a);set(dcm_obj,'UpdateFcn',{@gWfrXyzDrawCallback,XYZ});
        figure(figNum);plot3(XYZ(1,:),XYZ(2,:),XYZ(3,:),'.b');
end;

function output_txt=gWfrXyzDrawCallback(~,event_obj,XYZ)
di=get(event_obj,'DataIndex');%pos=get(event_obj,'Position');tr=get(event_obj,'Target');
output_txt={['DI: ',num2str(di,'%d')],['X:',num2str((XYZ(1,di)),'%f')],['Y:',num2str((XYZ(2,di)),'%f')],['Z:',num2str((XYZ(3,di)),'%f')]};
clipboard('copy', [num2str((XYZ(1,di)),'%f') '	' num2str((XYZ(2,di)),'%f')]);

%mail@ge0mlib.com 06/07/2018