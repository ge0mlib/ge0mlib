function gAcadZoom(fId,XYM,dgt)
%Write "zoom" command to AutoCad script file. Warning!!! There is some problem with "zoom" command for AutoCadCivil.
%function gAcadZoom(fId,XYM,dgt), where
%fId- file identifier;
%XYM- [x-coordinate (right/E), y-coordinate (up/N), scale] for zoom;
%dgt- printing digits after decimal points for XYM column (if isempty - dgt=5).
%Function Example: fId=fopen('c:\temp\113.scr','w');gAcadZoom(fId,[0 0 0.0001],4);fclose(fId);

if isempty(dgt),dgt=5;end;fprintf(fId,['zoom c %0.' num2str(dgt(1)) 'f,%0.' num2str(dgt(1)) 'f %0.' num2str(dgt(1)) 'f\r\n'],XYM);

%mail@ge0mlib.com 02/11/2019