function gAcadGeoReffImage(fId,fR)
%Write to AutoCad script file: insert image to XY coordinates using World-file (tfw, jfw and same). Tiff image convert to png format.
%function gAcadGeoReffImage(fId,fR), where
%fId- file identifier;
%fR- path to image file (string), includes image extension.
%Function Example:
%fId=fopen('c:\temp\112.scr','w');gAcadGeoReffImage(fId,'c:\temp\Prod02.tif');fclose(fId);
%fId=fopen('c:\temp\112.scr','w');for n=1:23,gAcadGeoReffImage(fId,['c:\temp\1\' num2str(n,'%02d') '.tif']);end;fclose(fId);
%============= World-file lines ===============
%Line1_A: x-component of the pixel width (x-scale);
%Line2_D: y-component of the pixel width (y-skew);
%Line3_B: x-component of the pixel height (x-skew);
%Line4_E: y-component of the pixel height (y-scale), typically negative.
%Line5_C: x-coordinate of center of upper left pixel;
%Line6_F: y-coordinate of center of upper left pixel.
%==============================================

L=find(fR=='.');[A,cmap]=imread(fR);
if strcmp(fR(L(end)+1:end),'tif')||strcmp(fR(L(end)+1:end),'tiff'),
    if size(A,3)==4,A(:,:,4)=[];end;
    fR1=[fR(1:L(end)) 'png'];if isempty(cmap),imwrite(A,fR1);else imwrite(A,cmap,fR1);end; %read image and write to png
else fR1=fR;
end;
L1=find(fR=='\');gAcadLayerMake(fId,fR(L1(end)+1:L(end)-1)); %make layer with file name
b=imfinfo(fR); %get image size
a=dlmread([fR(1:L(end)+1) 'fw']); %read georeference file
if (a(2)==0)&&(a(3)==0),%if rotation parameters are zero
    if(a(1)~=-a(4)),warning('Pixels sides must be equal!');end;
    m=b.Width.*a(1);x=a(5);y=a(6)+b.Height.*a(4);Ang=0;
elseif (a(1)==-a(4))&&(a(2)==a(3)),%if rotation parameters are not zero, but pixels sides are equal
    c=a(1)+a(2)*1i;Ang=angle(c);%complex along pixels x-axis
    m=b.Width.*abs(c);%length along horizontal images' side
    dxy=-b.Height.*abs(c).*exp(Ang*1i);%complex along vertical images' side from up to down
    x=a(5)+real(dxy);y=a(6)+imag(dxy);%down&left images coner coordinates
else error('Pixels sides must be equal');
end;
fprintf(fId,'-image a %s\r\n%0.15f,%0.15f %0.15f %0.15f\r\n',fR1,[x y],m,Ang);

%mail@ge0mlib.com 02/11/2019