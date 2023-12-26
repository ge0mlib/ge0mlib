function [B,L,H]=gNavGeoc2Geog(X,Y,Z,EllipParam)
%Convert geocentric coordinates to geographic coordinates.
%function [B,L,H]=gNavGeoc2Geog(XYZ,EllipParam), where
%B,L,H - rows, geographic Latitude, Longitude (degrees) and Height of geoid above ellipsoid (meters);
%X,Y,Z - rows, geocentric coordinates (meters);
%EllipParam - ellipsoid parameters [Semi major axis_a  Eccentricity_et];
%Transformation based on the √Œ—“ P 51794-2001
%Example: GpsEllipParam=[6378137 0.081819190842];[X,Y,Z]=gNavGeog2Geoc(51:.1:52,142:.1:143,100,GpsEllipParam);[B,L,H]=gNavGeoc2Geog(X,Y,Z,GpsEllipParam);
%=======================
%a- major ellipsoid axis; b- minor ellipsoid axis; A- polar flattening; et- first eccentricity of ellipsoid; et2- second eccentricity of ellipsoid;
%A=(a-b)./a; et=sqrt(a.^2-b.^2)./a; et=sqrt(2.*A-A.^2); et2=sqrt(a.^2-b.^2)./b; n=(a-b)/(a+b); m=(a.^2-b.^2)/(a.^2+b.^2); c=a.^2/b;
%b/a=1-A=sqrt(1-et.^2)=1/sqrt(1+et2.^2)=(1-n)/(1+n)=a/c=et/et2;

a=EllipParam(1);et=EllipParam(2);
B=zeros(1,length(X));L=zeros(1,length(X));H=zeros(1,length(X));num=1:length(X);
%=============
D=sqrt(X.^2+Y.^2);LL=(D==0);
if any(LL),
    B(LL)=(et.^2.*a)./2./sqrt(X(LL).^2+Y(LL).^2+Z(LL).^2).*sign(Z(LL))./2;
    L(LL)=0;
    H(LL)=Z(LL).*sin(B(LL))-a.*sqrt(1-et.^2);
    X(LL)=[];Y(LL)=[];Z(LL)=[];D(LL)=[];num(LL)=[];
end;
%=============
L(num)=asin(abs(Y)./D);
LL=(Y<0)&(X>0);if any(LL),L(num(LL))=2.*pi-L(num(LL));end;
LL=(Y<0)&(X<0);if any(LL),L(num(LL))=pi+L(num(LL));end;
LL=(Y>0)&(X<0);if any(LL),L(num(LL))=pi-L(num(LL));end;
%=============
LL=(Z==0);
if any(LL),
    B(num(LL))=0;
    H(num(LL))=D(num(LL))-a;
    X(LL)=[];Y(LL)=[];Z(LL)=[];D(LL)=[];num(LL)=[];
end;
%============
s2=zeros(size(num));nnn=0;sgm=0.00001./3600./180.*pi; %0.00001"
while ~isempty(num),
    s1=s2;nnn=nnn+1;
    r=sqrt(X.^2+Y.^2+Z.^2);c=asin(Z./r);p=(et.^2.*a)./2./r;
    b=c+s1;
    s2=asin(p.*sin(2.*b)./sqrt(1-(et.*sin(b)).^2));
    LL=(abs(s2-s1)<sgm);
    if any(LL)&&(nnn>10),
        B(num(LL))=b(LL);
        H(num(LL))=D(LL).*cos(b(LL))+Z(LL).*sin(b(LL))-a.*sqrt(1-(et.*sin(b(LL))).^2);
        X(LL)=[];Y(LL)=[];Z(LL)=[];D(LL)=[];num(LL)=[];s2(LL)=[];
    end;
end;
B=B./pi.*180;L=L./pi.*180;

%mail@ge0mlib.com 15/09/2017