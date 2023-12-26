function [m,ang]=gNavReducingHeading(B,L,EllipParam,ProjForvFunc,ProjParam)
%Calculate scale and angles for Geographic-to-Rectangular coordinates transformation.
%function [m,ang]=gNavReducingHeading(B,L,EllipParam,ProjForvFunc,ProjParam), where
%B - Latitude, 4 values in degrees;
%L - Longitude, 4 values in degrees;
%There are four points:
%   |4 (along Longitude)
%   |
%1------2 (along Latitude)
%   |
%   |3
%EllipParam - ellipsoid parameters [Semi major axis_a  Eccentricity_et];
%ProjForvFunc - function name for Geographic-to-Rectangular coordinates transformation; 'gNGeog2Utm' -- for UTM.
%ProjParam - coordinates transformation's function; UTM parameters [Latitude_of_natural_origin(B0) Longitude_of_natural_origin(L0) Scale_factor_at_natural_origin False_easting False_northing];
%m - scale [mX;mY] >> LX(proj)=LX(geographic_arc)*mX;
%ang - angles [angX;angY] >> HeadingX(proj)=HeadingX(geographic_arc)+angX, the clockwise rotation is +
%Simple calculation for UTM: ang~=(L(orig)-L).*sin(B).
%Example:
%[ang,m]=gNavReducingHeading([60 60 59.99 60.01],[141.99 142.01 142 142],[6378137 0.081819190842],'gNavGeog2Utm',[0 138 0.9996 500000 0]);

[E,N]=feval(ProjForvFunc,B,L,EllipParam,ProjParam);
dXY=gNavArc2Len(B(3:4),L(1:2),EllipParam);
m=[sqrt((E(2)-E(1)).^2+(N(2)-N(1)).^2)./dXY(1);sqrt((E(4)-E(3)).^2+(N(4)-N(3)).^2)./dXY(2)];
ang=[atan((N(2)-N(1))./(E(2)-E(1)));atan(-(E(4)-E(3))./(N(4)-N(3)))]./pi.*180;

%mail@ge0mlib.com 15/09/2017