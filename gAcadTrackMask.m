function gAcadTrackMask(fId,X,Y,mask,FontSize,TextRotAngle,AText,dgt)
%Write to AutoCad script file: draw one TrackPlot in X(:),Y(:) coordinates with out-of-data by mask.
%function gAcadTrackMask(fId,X,Y,mask,FontSize,TextRotAngle,AText,dgt), where
%fId- file identifier;
%X- x-coordinate vector (right/E);
%Y- y-coordinate vector (up/N);
%mask- mask for each point; 0/false is not drawing point; the poly-line will cut for a number of segments;
%FontSize- text's font size (scalar or vector);
%TextRotAngle- text's rotation angle (scalar or vector);
%AText- writing text string "in start point" for each segment;
%dgt- printing digits number after detimal points for X,Y and AText (if isempty - dgt=[5 5 0]).
%Used functions: gAcadPline,gAcadText.
%Function Example:
%x=[1 2 3 4 5 6 7 8 9 10];y=[1 3 4 1 5 6 1 1 2 3];m=[1 1 1 1 0 0 1 1 1 1];
%fId=fopen('c:\temp\112.scr','w');gAcadZoom(fId,[0 0 0.0001],4);gAcadColor(fId,[255 0 0]);gAcadTrackMask(fId1,x,y,m,1,90,'E95',[2 2 1]);fclose(fId);
%AutoCad script line example:
%============================
%zoom c 0.0000,0.0000 0.0001
%-layer m "Track_GpsRaw"
%
%pline 1.00,1.00 2.00,3.00 3.00,4.00 4.00,1.00
%
%text 1.00,1.00 1 90 E95
%pline 7.00,1.00 8.00,1.00 9.00,2.00 10.00,3.00
%
%text 7.00,1.00 1 90 E95
%==============================

if isempty(dgt),dgt=[5 5 0];end;
if all(mask),
    LL=isnan(X)|isnan(Y)|isinf(X)|isinf(Y);X(LL)=[];Y(LL)=[];gAcadPline(fId,X,Y,dgt(1:2));if ~isempty(AText),gAcadText(fId,X(1),Y(1),FontSize,TextRotAngle,AText,dgt);end;
else
    L=find([1;~mask(:);1]);dL=diff(L);ddL=find(dL>1);
    for n=ddL',
        x=X(L(n):L(n)+dL(n)-2);y=Y(L(n):L(n)+dL(n)-2);
        LL=isnan(x)|isnan(y)|isinf(x)|isinf(y);x(LL)=[];y(LL)=[];gAcadPline(fId,x,y,dgt(1:2));if ~isempty(AText), gAcadText(fId,x(1),y(1),FontSize,TextRotAngle,AText,dgt);end;
    end;
end;

%mail@ge0mlib.com 02/11/2019