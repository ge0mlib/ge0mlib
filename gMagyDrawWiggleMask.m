function gMagyDrawWiggleMask(figN,X,Y,T,mask,AText,ang)
%Draw wiggle with holes for Mask-values. Magnetic colors: blue is minus, red is plus.
%function gMagyDrawWiggleMask(figN,X,Y,T,mask,AText,ang), where
%figN- figure number;
%X- wiggle track x-coordinates;
%Y- wiggle track y-coordinates;
%T- wiggle amplitudes;
%mask- holes mask;
%AText- writing text with a fist wiggle point;
%ang- amplitudes rotation angle; if zero, then T along y-axis; plus is counterclockwise rotation.
%Example: gMagyDrawWiggleMask(1,[1 2 3 4 5 6 7 8 9],[5 5 5 5 5 5 5 5 5],[1 1 2 2 3 2 2 1 1],true(1,9),'E95',-45);

if any(isnan(X))||any(isnan(Y)), error('X or Y includes NaN value');end;
if all(mask),
    LL=isnan(T)|isinf(T);X(LL)=[];Y(LL)=[];T(LL)=[];
    gMagyDrawWiggle(figN,X,Y,T,ang);
    if ~isempty(AText), text(X(1),Y(1),AText,'FontSize',7,'Color',[0 0 0],'Interpreter','none','VerticalAlignment','baseline');end;
else
    L=find([1;~mask(:);1]);dL=diff(L);ddL=find(dL>1);
    for n=ddL',
        x=X(L(n):L(n)+dL(n)-2);y=Y(L(n):L(n)+dL(n)-2);t=T(L(n):L(n)+dL(n)-2);
        LL=isnan(t)|isinf(t);x(LL)=[];y(LL)=[];t(LL)=[];
        gMagyDrawWiggle(figN,x,y,t,ang);
        if ~isempty(AText), text(x(1),y(1),AText,'FontSize',7,'Color',[0 0 0],'Interpreter','none','VerticalAlignment','baseline');end;
    end;
end;

%mail@ge0mlib.com 05/05/17