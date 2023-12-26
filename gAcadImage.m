function gAcadImage(fId,fR,XY,m,Ang)
%Write to AutoCad script file: insert image in XY coordinates with scale m (mean that horizontal images' length is 1). Tiff-image convert to png format.
%function gAcadImage(fId,fReff,XY,LPD,Ang), where
%fId- file identifier;
%fR- path to image file (string);
%XY- left down images’ corner coordinates [x-coordinate(right/E) y-coordinate(up/N)];
%m- scale (mean that horizontal images' length is 1);
%Ang- rotation angle (around XY, left rotation in degree).
%Function Example:
%fId=fopen('c:\temp\112.scr','w');gAcadImage(fId,'c:\temp\2017_12_04_doc20171206203403_004.jpg',[10 10],1,0);fclose(fId);

L=find(fR=='.');[A,cmap]=imread(fR);
if strcmp(fR(L(end)+1:end),'tif')||strcmp(fR(L(end)+1:end),'tiff'),
    fR1=[fR(1:L(end)) 'png'];if isempty(cmap),imwrite(A,fR1);else imwrite(A,cmap,fR1);end; %read image and write to png
else fR1=fR;
end;
fprintf(fId,'-image a %s\r\n%0.15f,%0.15f %0.15f %0.15f\r\n',fR1,XY(1:2),m,Ang);

%mail@ge0mlib.com 02/11/2019