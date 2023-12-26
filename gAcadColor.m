function gAcadColor(fId,ColorRGB)
%Write "default rgb-color" to AutoCad script file.
%function gAcadColor(fId,ColorRGB), where
%fId- file identifier;
%ColorRGB- [R G B] color vector (0..255) or symbol y,m,c,r,g,b,w,k.
%Function Example:
%X=[1 2 3 5];Y=[4 5 7 10];fId=fopen('c:\temp\112.scr','w');gAcadZoom(fId,[0 0 0.0001],4);gAcadColor(fId,[255 0 0]);gAcadCircle(fId,X,Y,1,[2 2 0]);gAcadText(fId,X-0.5,Y-0.5,2,0,X,[2 2 1]);fclose(fId);

if all(ischar(ColorRGB)),
    switch ColorRGB(1),
        case 'y',ColorRGB=[255 255 0];  %yellow
        case 'm',ColorRGB=[255 0 255];  %magenta
        case 'c',ColorRGB=[0 255 255];  %cyan
        case 'r',ColorRGB=[255 0 0];  %red
        case 'g',ColorRGB=[0 255 0];    %green
        case 'b',ColorRGB=[0 0 255];    %blue
        case 'w',ColorRGB=[255 255 255];%white
        case 'k',ColorRGB=[0 0 0];      %black
        otherwise,ColorRGB=[0 0 255];warning('Incorrect ColorRGB(1) symbol.');
    end;
end;
fprintf(fId,'-color truecolor %d,%d,%d\r\n',ColorRGB(1),ColorRGB(2),ColorRGB(3));

%mail@ge0mlib.com 21/04/2021