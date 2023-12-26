function gAcadWiggle(fId,X,Y,T,Ang,ColorLine,ColorHatch1,ColorHatch2,TransparencyHatch,FontSize,TextRotAngle,AText,dgt)
%Write to AutoCad script file: draw Wiggle in X(:),Y(:) coordinates.
%function gAcadWiggle(fId,X,Y,T,Ang,ColorLine,ColorHatch1,ColorHatch2,TransparencyHatch,FontSize,TextRotAngle,AText,dgt), where
%fId- file identifier;
%X- x-coordinate vector (right/E);
%Y- y-coordinate vector (up/N);
%T- wiggle-line value vector;
%Ang- wiggle-line rotation angle (scalar; 0- up/N, right/clockwise rotation sign is +);
%ColorLine- wiggle-line color (scalar); if isempty, than not changed;
%ColorHatch1- wiggle-hatch1 (up zero) [R G B] color; if isempty, than not changed;
%ColorHatch2- wiggle-hatch2 (down zero) [R G B] color; if isempty, than not changed;
%TransparencyHatch- hatch transparency in percent from 0 to 100 (if isempty, than not set);
%FontSize- text's font size (scalar or vector);
%TextRotAngle- text's rotation angle (scalar or vector);
%AText- writing text string “in start point” for each segment;
%dgt- printing digits number after detimal points for X,Y and AText (if isempty - dgt=[5 5 0]).
%Using functions: gAcadColor,gAcadWiggleToMap,gAcadText
%Function Example:
%X=[1 2 3 4 5 6 7 8];Y=[1 2 4 7 11 16 22 30];T=[0 1 5 1 -2 -4 -4 -2];
%fId=fopen('c:\temp\112.scr','w');gAcadZoom(fId,[0 0 0.0001],4);gAcadWiggle(fId,X,Y,T,90,[0 0 255],[255 0 0],[0 255 0],50,1,90,'E95',[2 2 1]);fclose(fId);

if any(isnan(X))||any(isnan(Y)), error('Error gAcadWiggle: X or Y includes NaN value');end;
L=isnan(T);T(L)=0;
T0a=T(:);L=T<0;T0a(L)=0;
T0b=T(:);L=T>0;T0b(L)=0;

Head=Ang./180.*pi;HeadM=[cos(Head) -sin(Head); sin(Head) cos(Head)];
XYa=(HeadM*[zeros(size(T0a)) T0a]')';x1=[X(:);flipud(X(:)+XYa(:,1))];y1=[Y(:);flipud(Y(:)+XYa(:,2))];
XYb=(HeadM*[zeros(size(T0b)) T0b]')';x2=[X(:);flipud(X(:)+XYb(:,1))];y2=[Y(:);flipud(Y(:)+XYb(:,2))];

if isempty(dgt),dgt=[5 5];end;formSt=[' %0.' num2str(dgt(1)) 'f,%0.' num2str(dgt(2)) 'f'];

if ~isempty(ColorLine), gAcadColor(fId,ColorLine);end;
fprintf(fId,'pline');fprintf(fId,formSt,[x1,y1]');fprintf(fId,formSt,x1(1),y1(1));fprintf(fId,'\r\n\r\n');
if ~isempty(ColorHatch1), gAcadColor(fId,ColorHatch1);end;
if ~isempty(TransparencyHatch), fprintf(fId,'-hatch properties solid transparency %g select last\r\n\r\n\r\n',(TransparencyHatch)); else fprintf(fId,'-hatch properties solid select last\r\n\r\n\r\n'); end;

if ~isempty(ColorLine), gAcadColor(fId,ColorLine);end;
fprintf(fId,'pline');fprintf(fId,formSt,[x2,y2]');fprintf(fId,formSt,x2(1),y2(1));fprintf(fId,'\r\n\r\n');
if ~isempty(ColorHatch2), gAcadColor(fId,ColorHatch2);end;
if ~isempty(TransparencyHatch), fprintf(fId,'-hatch properties solid transparency %g select last\r\n\r\n\r\n',(TransparencyHatch)); else fprintf(fId,'-hatch properties solid select last\r\n\r\n\r\n'); end;

if ~isempty(AText), gAcadText(fId,X(1),Y(1),FontSize,TextRotAngle,AText,dgt);end;

%mail@ge0mlib.com 18/04/2021