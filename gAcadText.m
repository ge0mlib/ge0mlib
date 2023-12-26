function gAcadText(fId,X,Y,FontSize,TextRotAngle,AText,dgt)
%Write to AutoCad script file: draw texts in X(:),Y(:) coordinates, with size FontSize(:) and angle TextRotAngle(:).
%function gAcadText(fId,X,Y,FontSize,TextRotAngle,AText,dgt), where
%fId- file identifier;
%X- x-coordinate vector (right/E);
%Y- y-coordinate vector (up/N);
%FontSize- text's font size (scalar or vector);
%TextRotAngle- text's rotation angle (scalar or vector);
%AText- writing text: 1)vector with a numbers; 2)cell-vector with a strings; 3)single char string for single point.
%dgt- printing digits number after decimal points for X,Y and AText as a numbers (if isempty - dgt=[5 5 0]).
%AutoCad script line example: Text 1.00000,1.00000 5 0 1
%Function Example:
%X=[1 2 3 5];Y=[4 5 7 10];
%fId=fopen('c:\temp\112.scr','w');gAcadZoom(fId,[0 0 0.0001],4);gAcadColor(fId,[255 0 0]);gAcadCircle(fId,X,Y,1,[2 2 0]);gAcadText(fId,X-0.5,Y-0.5,2,0,X,[2 2 1]);fclose(fId);

if numel(FontSize)==1, FontSize=repmat(FontSize,size(X));end;
if numel(TextRotAngle)==1, TextRotAngle=repmat(TextRotAngle,size(X));end;
if all(isnumeric(AText)),
    if isempty(dgt),dgt=[5 5 0];end;formSt=['text %0.' num2str(dgt(1)) 'f,%0.' num2str(dgt(2)) 'f %g %g %0.' num2str(dgt(3)) 'f\r\n'];
    fprintf(fId,formSt,[X(:),Y(:),(FontSize(:)),(TextRotAngle(:)),AText(:)]');
end;
if all(iscell(AText)),
    if isempty(dgt),dgt=[5 5];end;formSt=['text %0.' num2str(dgt(1)) 'f,%0.' num2str(dgt(2)) 'f %g %g %s\r\n'];
    for n=1:numel(X), fprintf(fId,formSt,X(n),Y(n),(FontSize(n)),(TextRotAngle(n)),AText{n});end;
end;
if all(ischar(AText))&&(numel(X)==1)&&(numel(Y)==1),
    if isempty(dgt),dgt=[5 5];end;formSt=['text %0.' num2str(dgt(1)) 'f,%0.' num2str(dgt(2)) 'f %g %g %s\r\n'];
    fprintf(fId,formSt,X,Y,(FontSize),(TextRotAngle),AText);
end;

%mail@ge0mlib.com 18/04/2021