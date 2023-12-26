function gAcadCircle(fId,X,Y,R,dgt)
%Write to AutoCad script file: draw circles in X(:),Y(:) coordinates, with radius R(:).
%function gAcadCircle(fId,X,Y,R,dgt), where
%fId- file identifier;
%X- x-coordinate vector (right/E);
%Y- y-coordinate vector (up/N);
%R- radius (scalar or vector);
%dgt - printing digits after detimal points for X, Y and R columns (if isempty - dgt=[5 5 2]).
%AutoCad script line example: Circle 582160.91000,5306794.61000 1
%Function Example:
%X=[1 2 3 5];Y=[4 5 7 10];fId=fopen('c:\temp\112.scr','w');gAcadZoom(fId,[0 0 0.0001],4);gAcadColor(fId,[255 0 0]);gAcadCircle(fId,X,Y,1,[2 2 0]);gAcadText(fId,X-0.5,Y-0.5,2,0,X,[2 2 1]);fclose(fId);

if isempty(dgt),dgt=[5 5 2];end;formSt=['circle %0.' num2str(dgt(1)) 'f,%0.' num2str(dgt(2)) 'f %0.' num2str(dgt(3)) 'f\r\n'];
if all(size(R)==[1 1]), R=repmat(R,size(X));end;
fprintf(fId,formSt,[X(:) Y(:) R(:)]');

%mail@ge0mlib.com 02/11/2019