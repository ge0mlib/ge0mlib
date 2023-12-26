function [dm,dAng]=gNavReducingHeadingToProjUtm(B,L,EllipParam,ProjParam,key) %et,L0,Sc
%Calculate Scale and Angle between Geographic Line and Transverse Mercator projection Line (EPSG 9807 Projection)
%function [m,dAng]=gNavReducingHeadingToProjUtm(B,L,et,L0,key), where
%B - Latitude;
%L - Longitude;
%ProjParam- TM parameters [not_used Longitude_of_natural_origin(L0) Scale_factor_at_natural_origin not_used not_used];
%EllipParam- ellipsoid parameters [not_used  Eccentricity_et];
%key - dAng calculation method number (1, 2 or 3);
%dm - Gauss Scale; L(proj)=L(geographic_arc)*m;
%dAng - Gauss Angle; Heading(UTM/TM)=Heading(geographic_arc)-dAng, the clockwise rotation is +
%Example: [m,dAng]=gNavReducingHeadingToProjUtm([60 61],[142 143],EllipParam,ProjParam,2);

et=EllipParam(2);L0=ProjParam(2);k0=ProjParam(3);
B=B./180.*pi;dL=(L-L0)./180.*pi;
switch key,
    case 1,
        dm=(1+(1-(et.*sin(B)).^2)./(1-et.^2).*(cos(B).*dL).^2./2).*k0;
        dAng=dL.*sin(B)./pi.*180;
    case 2,%Boyko2003
        dm=sqrt(1+(1-(et.*sin(B)).^2)./(1-et.^2).*(cos(B).*dL).^2).*k0;
        nu=sqrt((1-(et*sin(B)).^2)/(1-et.^2)-1);
        dAng=(sin(B).*dL+sin(B).*(cos(B)).^2.*(1+3.*nu.^2).*(dL.^3)/3+sin(B).*(cos(B)).^4.*(2-(tan(B)).^2).*(dL.^5)/15)./pi.*180;
    case 3,%Morozov1979
        nu=sqrt((1-(et*sin(B)).^2)/(1-et.^2)-1);
        dm=sqrt(1+(cos(B).*dL).^2.*(1+nu.^2)+(cos(B).*dL).^4/12.*(8-4.*(tan(B)).^2)).*k0;
        dAng=atan(sin(B).*tan(dL)+nu.^2.*sin(B).*(cos(B)).^2.*dL.^3.*(1+2/3.*nu.^2+(cos(B).*dL).^2))./pi.*180;
end;

%mail@ge0mlib.com 15/09/2017