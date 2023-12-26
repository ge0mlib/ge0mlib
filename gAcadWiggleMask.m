function gAcadWiggleMask(fId,X,Y,T,mask,Ang,ColorLine,ColorHatch1,ColorHatch2,TransparencyHatch,FontSize,TextRotAngle,AText,dgt)
%Write to AutoCad script file: draw one WiggleToMap in X(:),Y(:) coordinates with out-of-data by mask.
%function gAcadWiggleMask(fId,X,Y,T,mask,Ang,ColorLine,ColorHatch1,ColorHatch2,TransparencyHatch,FontSize,TextRotAngle,AText,dgt), where
%fId- file identifier;
%X- x-coordinate vector (right/E);
%Y- y-coordinate vector (up/N);
%T- wiggle-line value vector;
%mask- mask for each point; 0/false is not drawing point; the Wiggle will cut for a number of segments;
%Ang- wiggle-line rotation angle (scalar; 0- up/N, right/clockwise rotation sign is +);
%ColorLine- wiggle-line color (scalar); if isempty, than not changed;
%ColorHatch1- wiggle-hatch1 (up zero) [R G B] color; if isempty, than not changed;
%ColorHatch2- wiggle-hatch2 (down zero) [R G B] color; if isempty, than not changed;
%TransparencyHatch- hatch transparency in percent from 0 to 100 (if isempty, than not set);
%FontSize- text's font size (scalar or vector);
%TextRotAngle- text's rotation angle (scalar or vector);
%AText- writing text string “in start point” for each segment;
%dgt- printing digits number after detimal points for X,Y and AText (if isempty - dgt=[5 5 0]).
%Using functions: gAcadWiggle
%Function Example:
%X=[1 2 3 4 5 6 7 8];Y=[1 2 4 7 11 16 22 30];T=[0 1 5 1 nan nan -4 -2];mask=logical([1 1 1 1 0 0 1 1]);
%fId=fopen('c:\temp\112.scr','w');gAcadZoom(fId,[0 0 0.0001],4);gAcadWiggleMask(fId,X,Y,T,mask,90,[0 0 255],[255 0 0],[0 255 0],50,1,90,'E95',[2 2 1]);fclose(fId);

if any(isnan(X))||any(isnan(Y)), error('Error gAcadWiggleToMapMask: X or Y includes NaN value');end;
if isempty(dgt),dgt=[5 5 0];end;
if all(mask),
    LL=isnan(T)|isinf(T);X(LL)=[];Y(LL)=[];T(LL)=[];gAcadWiggle(fId,X,Y,T,Ang,ColorLine,ColorHatch1,ColorHatch2,TransparencyHatch,FontSize,TextRotAngle,AText,dgt);
else
    L=find([1;~mask(:);1]);dL=diff(L);ddL=find(dL>1);
    for n=ddL',
        x=X(L(n):L(n)+dL(n)-2);y=Y(L(n):L(n)+dL(n)-2);t=T(L(n):L(n)+dL(n)-2);
        LL=isnan(t)|isinf(t);x(LL)=[];y(LL)=[];t(LL)=[];gAcadWiggle(fId,x,y,t,Ang,ColorLine,ColorHatch1,ColorHatch2,TransparencyHatch,FontSize,TextRotAngle,AText,dgt);
    end;
end;

%mail@ge0mlib.com 02/11/2019