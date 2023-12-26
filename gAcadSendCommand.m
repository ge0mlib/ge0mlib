function gAcadSendCommand(fId,keyZ)
%Write defined command+CR+LF to AutoCad script file.
%function gAcadSendCommand(fId,keyZ), where
%keyZ - command send to AutoCad.
%Function Example:
%fId=fopen('c:\temp\112.scr','w');gAcadSendCommand(fId,'-osnap off');gAcadSendCommand(fId,'-color truecolor 10,10,0');fclose(fId);

fprintf(fId,'%s\r\n',keyZ);

%mail@ge0mlib.com 02/11/2019