function gAcadPline(fId,X,Y,dgt)
%Write to AutoCad script file: draw one poly-line in X(:),Y(:) coordinates.
%function gAcadPline(fId,X,Y,dgt), where
%fId- file identifier;
%X- x-coordinate vector (right/E);
%Y- y-coordinate vector (up/N);
%dgt- printing digits after decimal points for X and Y (if isempty - dgt=[5 5]).
%AutoCad script line example: Pline 1.00000,1.00000 2.00000,1.00000 3.00000,1.00000 4.00000,1.00000 5.00000,1.00000
%Function Example:
%X=[1 2 3 5 6 7 8]';Y=[1 2 4 7 11 16 22]';
%fId=fopen('c:\temp\112.scr','w');gAcadZoom(fId,[0 0 0.0001],4);gAcadColor(fId,[255 0 0]);gAcadPline(fId,X,Y,[2 2]);fclose(fId);

if isempty(dgt),dgt=[5 5];end;formSt=[' %0.' num2str(dgt(1)) 'f,%0.' num2str(dgt(2)) 'f'];
fprintf(fId,'pline');fprintf(fId,formSt,[X(:) Y(:)]');fprintf(fId,'\r\n\r\n');

%mail@ge0mlib.com 02/11/2019