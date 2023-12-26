function [p1,p2]=gMagyDrawWiggle(figN,X,Y,T,ang)
%Draw wiggle. Magnetic colors: blue is minus, red is plus.
%function [p1,p2]=gMagyDrawWiggle(figN,X,Y,T,ang), where
%figN- figure number;
%X- wiggle track x-coordinates;
%Y- wiggle track y-coordinates;
%T- wiggle amplitudes;
%ang- amplitudes rotation angle; if zero, then T along y-axis; plus is counterclockwise rotation;
%[p1,p2]- pointers to red patch and blue patch.
%The coordinate system:
%^ x(forward/roll)
%|
%o---> y(right/pitch)
%Example: gMagyDrawWiggle(1,[1 2 3 4 5 6 7 8 9],[5 5 5 5 5 5 5 5 5],[1 1 2 2 3 2 2 1 1],-45);

p1=[];p2=[];
ang=ang./180.*pi;
if any(isnan(X))||any(isnan(Y)), error('X or Y includes NaN value');end;
X=X(:);Y=Y(:);T=T(:);
L=isnan(T);T(L)=0;
T0a=T;L=T<0;T0a(L)=0;
T0b=T;L=T>0;T0b(L)=0;

Zm=[cos(ang) -sin(ang); sin(ang) cos(ang)];
XYa=(Zm*[zeros(size(T0a)) T0a]')';XYb=(Zm*[zeros(size(T0b)) T0b]')';

z=0;
figure(figN);hold on;
if ~(all(XYa(:,1)==0)&&all(XYa(:,2)==0)), p1=patch([X+XYa(:,1);flipud(X)]',[Y+XYa(:,2);flipud(Y)]','r');z=z+1;end;
if ~(all(XYb(:,1)==0)&&all(XYb(:,2)==0)), p2=patch([X+XYb(:,1);flipud(X)]',[Y+XYb(:,2);flipud(Y)]','b');z=z+1;end;
if ~z, plot(X,Y,'-k');end;
hold off;

%mail@ge0mlib.com 22/11/2018