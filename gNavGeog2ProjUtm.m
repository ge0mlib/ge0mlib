function [E,N]=gNavGeog2ProjUtm(B,L,EllipParam,ProjParam)
%Convert Geographic coordinates to Transverse Mercator. EPSG dataset coordinate operation method code 9807: formulas are based on those of Kruger and published in Finland as Recommendations for Public Administration (JHS) 154 (referred as ‘JHS formulas’)
%function [E,N]=gNavGeog2ProjUtm(B,L,EllipParam,ProjParam), where
%B,L- rows, Latitude, Longitude in degrees;
%E,N- rows, Easting, Northing in meters;
%ProjParam- TM parameters [Latitude_of_natural_origin(B0) Longitude_of_natural_origin(L0) Scale_factor_at_natural_origin False_easting False_northing];
%EllipParam- ellipsoid parameters [Semi major axis_a  Eccentricity_et];
%Example:
%GpsEllipParam=[6378137 0.081819190842];GpsProjParam=[0 142 0.9996 500000 0];[GpsE,GpsN]=gNavGeog2ProjUtm(51:.1:52,142:.1:143,GpsEllipParam,GpsProjParam);
%[GpsLat,GpsLon]=gNavGeog2ProjUtm(GpsE,GpsN,GpsEllipParam,GpsProjParam);
%=======================
%a- major ellipsoid axis; b- minor ellipsoid axis; A- polar flattening; et- first eccentricity of ellipsoid; et2- second eccentricity of ellipsoid;
%A=(a-b)./a; et=sqrt(a.^2-b.^2)./a; et=sqrt(2.*A-A.^2); et2=sqrt(a.^2-b.^2)./b; n=(a-b)/(a+b); m=(a.^2-b.^2)/(a.^2+b.^2); c=a.^2/b;
%b/a=1-A=sqrt(1-et.^2)=1/sqrt(1+et2.^2)=(1-n)/(1+n)=a/c=et/et2;

a=EllipParam(1);et=EllipParam(2);
B0=ProjParam(1)/180*pi;L0=ProjParam(2)/180*pi;k0=ProjParam(3);FE=ProjParam(4);FN=ProjParam(5);
B=B/180*pi;L=L/180*pi;
f=1-sqrt(1-et^2);n=f/(2-f);
Bz=a/(1+n)*(1+n^2/4+n^4/64);
h1=n/2-2/3*n^2+5/16*n^3+41/180*n^4; h2=13/48*n^2-3/5*n^3+557/1440*n^4; h3=61/240*n^3-103/140*n^4; h4=49561/161280*n^4;
if B0==0, M0=0;
elseif B0==pi/2, M0=Bz.*pi/2;
elseif B0==-pi/2, M0=-Bz.*pi/2;
else
    s0=atan(sinh(asinh(tan(B0))-et*atanh(et*sin(B0))));
    M0=Bz*(s0+h1*sin(2*s0)+h2*sin(4*s0)+h3*sin(6*s0)+h4*sin(8*s0));
end;
bt=atan(sinh(asinh(tan(B))-(et*atanh(et*sin(B)))));
nu0=atanh(cos(bt).*sin(L-L0));
ep0=asin(sin(bt).*cosh(nu0));
nu=nu0+h1*cos(2*ep0).*sinh(2*nu0)+h2*cos(4*ep0).*sinh(4*nu0)+h3*cos(6*ep0).*sinh(6*nu0)+h4*cos(8*ep0).*sinh(8*nu0);
ep=ep0+h1*sin(2*ep0).*cosh(2*nu0)+h2*sin(4*ep0).*cosh(4*nu0)+h3*sin(6*ep0).*cosh(6*nu0)+h4*sin(8*ep0).*cosh(8*nu0);
E=FE+k0*Bz*nu;
N=FN+k0*(Bz*ep-M0);

%mail@ge0mlib.com 15/09/2017