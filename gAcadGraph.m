function gAcadGraph(fId,X,Y,T,Ang,ColorGraph,ColorTrack,dgt)
%Write to AutoCad script file: draw plot T relativeiy to trackplot in X,Y coordinates.
%function gAcadGraph(fId,X,Y,T,Ang,ColorGraph,ColorTrack,dgt), where
%fId- file identifier;
%X- x-coordinate vector (right/E);
%Y- y-coordinate vector (up/N);
%T- graph-line value vector;
%Ang- plot-line rotation angle (one number; 0- up/N, right/clockwise rotation sign is +);
%ColorGraph- graph [R G B] color vector; if isempty, than not changed;
%ColorTrack- track-line [R G B] color vector; if isempty, than not changed;
%dgt- printing digits after decimal points for X and Y (if isempty - dgt=[5 5]).
%Using functions: gAcadColor.
%Function Example:
%X=[1 2 3 4 5 6 7 8];Y=[1 2 4 7 11 16 22 30];T=[0 1 5 1 -2 -4 -4 -2];
%fId=fopen('c:\temp\112.scr','w');gAcadZoom(fId,[0 0 0.0001],4);gAcadGraph(fId,X,Y,T,90,[255 0 0],[0 255 0],[2 2]);fclose(fId);

Head=Ang./180.*pi;HeadM=[cos(Head) sin(Head); -sin(Head) cos(Head)];
XY=(HeadM*[zeros(size(T(:))) T(:)]')';x1=X(:)+XY(:,1);y1=Y(:)+XY(:,2);
if isempty(dgt),dgt=[5 5];end;formSt=[' %0.' num2str(dgt(1)) 'f,%0.' num2str(dgt(2)) 'f'];
if ~isempty(ColorGraph), gAcadColor(fId,ColorGraph);end;fprintf(fId,'pline');fprintf(fId,formSt,[x1(:),y1(:)]');fprintf(fId,'\r\n\r\n');
if ~isempty(ColorTrack), gAcadColor(fId,ColorTrack);end;fprintf(fId,'pline');fprintf(fId,formSt,[X(:),Y(:)]');fprintf(fId,'\r\n\r\n');

%mail@ge0mlib.com 02/11/2019