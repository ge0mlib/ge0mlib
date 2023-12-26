function [a,b,stdxy,mask]=gMapGeomLineDirect2D(X,Y,rk)
%Linear approximation for polyline; robust calculation a,b for y=ax+b. Used for Survey line direction calculation.
%function [a,b,stdxy,mask]=gMapGeomLineDirect2D(X,Y,rk), where
%X - vector x;
%Y - vector y;
%rk - vector std-coefficients for robust procedure, usually [3 2.5];
%a,b - calculated a and b;
%stdxy - standard deviation for Y-ax+b;
%mask - logical mask for elements y and x, which take part in a,b calculation.
%Function Example:
%[a,b,stdxy,mask]=gMapGeomLineDirect2D([1 3 2 5 7 9 3 1],[7 15 90 23 31 39 15 7],[3 2.5 2]);

X=X(:);Y=Y(:);Num=1:size(X,1);mask=false(size(X));rk=rk(:)';
L=isnan(X)|isnan(Y)|isinf(X)|isinf(Y);X(L)=[];Y(L)=[];Num(L)=[];
for nn=rk,
    L=1;
    while ~isempty(L),
        %calculate rms >> X=LSCOV(A,B) --> B=A*X --> y=[x ones(size(x))]*ab --> y=x*ab(1)+ones(size(x))*ab(2) --> y=ax+b
        %ab(1) - angle coeff, â ab(2) - shift
        ab=lscov([X ones(size(X))],Y);
        dN=Y-ab(1).*X+ab(2);
        L=find(abs(dN-mean(dN))>std(dN).*nn);
        X(L)=[];Y(L)=[];Num(L)=[];
    end;
end;
a=ab(1);b=ab(2);stdxy=std(dN);mask(Num)=true;

%mail@ge0mlib.com 02/08/2016