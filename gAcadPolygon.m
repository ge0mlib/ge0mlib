function gAcadPolygon(fId,X,Y,ColorLine,ColorHatch,TransparencyHatch,dgt)
%Write to AutoCad script file: draw one poly-line with Hatch in X(:),Y(:) coordinates. The poly-line is auto closed (first point will be added to end).
%function gAcadPolygon(fId,X,Y,ColorLine,ColorHatch,dgt), where
%fId- file identifier;
%X- x-coordinate vector (right/E);
%Y- y-coordinate vector (up/N);
%ColorLine- line [R G B] color vector; if isempty, than not changed;
%ColorHatch- hatch [R G B] color vector; if isempty, than not changed;
%TransparencyHatch - hatch transparency in persent from 0 to 100 (if isempty, than not set);
%dgt - printing digits after detimal points for X and Y (if isempty - dgt=[5 5]).
%Using functions: gAcadColor.
%Function Example:
%X=[1 2 3 5 6 7 8];Y=[1 2 4 7 11 16 22];
%fId=fopen('c:\temp\112.scr','w');gAcadZoom(fId,[0 0 0.0001],4);gAcadPolygon(fId,X,Y,[255 0 0],[0 255 0],50,[2 2]);fclose(fId);

if isempty(dgt),dgt=[5 5];end;formSt=[' %0.' num2str(dgt(1)) 'f,%0.' num2str(dgt(2)) 'f'];
if ~isempty(ColorLine), gAcadColor(fId,ColorLine);end;
fprintf(fId,'pline');fprintf(fId,formSt,[X(:) Y(:)]');fprintf(fId,formSt,X(1),Y(1));fprintf(fId,'\r\n\r\n');
if ~isempty(ColorHatch), gAcadColor(fId,ColorHatch);end;
if ~isempty(TransparencyHatch), fprintf(fId,'-hatch properties solid transparency %d select last\r\n\r\n\r\n',round(TransparencyHatch));else fprintf(fId,'-hatch properties solid select last\r\n\r\n\r\n');end;

%mail@ge0mlib.com 02/11/2019