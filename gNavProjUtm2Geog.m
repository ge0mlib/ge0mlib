function [B,L]=gNavProjUtm2Geog(E,N,EllipParam,ProjParam)
%Convert Transverse Mercator to Geographic coordinates. EPSG dataset coordinate operation method code 9807: formulas are based on those of Kruger and published in Finland as Recommendations for Public Administration (JHS) 154 (referred as ‘JHS formulas’).
%function [B,L]=gNavProjUtm2Geog(E,N,EllipParam,ProjParam), where
%E,N- rows, Easting, Northing in meters;
%B,L- rows, Latitude, Longitude in degrees;
%ProjParam- TM parameters [Latitude_of_natural_origin(B0) Longitude_of_natural_origin(L0) Scale_factor_at_natural_origin False_easting False_northing];
%EllipParam- ellipsoid parameters [Semi major axis_a  Eccentricity_et];
%Example:
%GpsEllipParam=[6378137 0.081819190842];GpsProjParam=[0 142 0.9996 500000 0];[GpsE,GpsN]=gNavGeog2ProjUtm(51:.1:52,142:.1:143,GpsEllipParam,GpsProjParam);
%[GpsLat,GpsLon]=gNavProjUtm2Geog(GpsE,GpsN,GpsEllipParam,GpsProjParam);
%=======================
%a- major ellipsoid axis; b- minor ellipsoid axis; A- polar flattening; et- first eccentricity of ellipsoid; et2- second eccentricity of ellipsoid;
%A=(a-b)./a; et=sqrt(a.^2-b.^2)./a; et=sqrt(2.*A-A.^2); et2=sqrt(a.^2-b.^2)./b; n=(a-b)/(a+b); m=(a.^2-b.^2)/(a.^2+b.^2); c=a.^2/b;
%b/a=1-A=sqrt(1-et.^2)=1/sqrt(1+et2.^2)=(1-n)/(1+n)=a/c=et/et2;

a=EllipParam(1);et=EllipParam(2);
B0=ProjParam(1)/180*pi;L0=ProjParam(2)/180*pi;k0=ProjParam(3);FE=ProjParam(4);FN=ProjParam(5);
f=1-sqrt(1-et^2);n=f/(2-f);
Bz=a/(1+n)*(1+n^2/4+n^4/64);
h1=n/2-2/3*n^2+37/96*n^3+1/360*n^4; h2=1/48*n^2-1/15*n^3+437/1440*n^4; h3=17/480*n^3-37/840*n^4; h4=4397/161280*n^4;
if ~B0(1), M0=0;
elseif B0(1)==pi/2, M0=Bz.*pi/2;
elseif B0(1)==-pi/2, M0=-Bz.*pi/2;
else
    s0=atan(sinh(asinh(tan(B0))-et*atanh(et*sin(B0))));
    M0=Bz*(s0+h1*sin(2*s0)+h2*sin(4*s0)+h3*sin(6*s0)+h4*sin(8*s0));
end;
nu=(E-FE)/(Bz*k0);
ep=((N-FN)+k0*M0)/(Bz*k0);
nu0=nu-(h1*cos(2*ep).*sinh(2*nu)+h2*cos(4*ep).*sinh(4*nu)+h3*cos(6*ep).*sinh(6*nu)+h4*cos(8*ep).*sinh(8*nu));
ep0=ep-(h1*sin(2*ep).*cosh(2*nu)+h2*sin(4*ep).*cosh(4*nu)+h3*sin(6*ep).*cosh(6*nu)+h4*sin(8*ep).*cosh(8*nu));
bt=asin(sin(ep0)./cosh(nu0));
Q1=asinh(tan(bt));Q2=Q1;
num=(1:size(Q1,2));Qout=zeros(size(Q1));nnn=0;sgm=0.000001./3600./180.*pi; %0.000001"
while ~isempty(num),
    Q3=Q2;
    Q2=Q1+et*atanh(et*tanh(Q2));nnn=nnn+1;
    L=(abs(Q2-Q3)<sgm);
    if any(L)&&(nnn>10), Qout(num(L))=Q2(L);Q1(L)=[];Q2(L)=[];num(L)=[];end;
end;
B=atan(sinh(Qout))*180/pi;
L=(L0+asin(tanh(nu0)./cos(bt)))*180/pi;

%mail@ge0mlib.com 15/09/2017