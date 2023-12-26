function [X,Y,Z]=gNavGeog2Geoc(B,L,H,EllipParam)
%Convert geographic coordinates to geocentric coordinates.
%function XYZ=gNavGeog2Geoc(B,L,H,EllipParam), where
%B,L,H - rows, geographic Latitude, Longitude (degrees) and Height of geoid (mean sea level) above ellipsoid (meters);
%X,Y,Z - rows, geocentric coordinates (meters);
%EllipParam - ellipsoid parameters [Semi major axis_a  Eccentricity_et];
%Transformation based on the √Œ—“ P 51794-2001
%Example: GpsEllipParam=[6378137 0.081819190842];[X,Y,Z]=gNavGeog2Geoc(51:.1:52,142:.1:143,100,GpsEllipParam);[B,L,H]=gNavGeoc2Geog(X,Y,Z,GpsEllipParam);
%=======================
%a- major ellipsoid axis; b- minor ellipsoid axis; A- polar flattening; et- first eccentricity of ellipsoid; et2- second eccentricity of ellipsoid;
%A=(a-b)./a; et=sqrt(a.^2-b.^2)./a; et=sqrt(2.*A-A.^2); et2=sqrt(a.^2-b.^2)./b; n=(a-b)/(a+b); m=(a.^2-b.^2)/(a.^2+b.^2); c=a.^2/b;
%b/a=1-A=sqrt(1-et.^2)=1/sqrt(1+et2.^2)=(1-n)/(1+n)=a/c=et/et2;

a=EllipParam(1);et=EllipParam(2);
B=B/180*pi;L=L/180*pi;
NH=a./sqrt(1-(et.*sin(B)).^2)+H;
X=(NH).*cos(B).*cos(L);
Y=(NH).*cos(B).*sin(L);
Z=((1-et.^2).*NH).*sin(B);

%mail@ge0mlib.com 15/09/2017