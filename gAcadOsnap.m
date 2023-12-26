function gAcadOsnap(fId,key)
%Write "-osnap" command with Key to AutoCad script file. Usually used for swith off snap for true script execution.
%function gAcadOsnap(fId,key), where
%key - key for "-osnap" command: 'off','end', etc.
%Function Example:
%X=[1 2 3 5];Y=[4 5 7 10];fId=fopen('c:\temp\112.scr','w');gAcadOsnap(fId,'off');gAcadColor(fId,[255 0 0]);gAcadCircle(fId,X,Y,1,[2 2 0]);gAcadText(fId,X-0.5,Y-0.5,2,0,X,[2 2 1]);fclose(fId);

fprintf(fId,'-osnap %s\r\n',key);

%mail@ge0mlib.com 02/11/2019