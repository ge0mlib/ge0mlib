function [E,N]=gNavGeog2ProjLambAz(B,L,EllipParam,ProjParam)
%Convert Geographic coordinates to Lambert Azimuthal Equal Area projection. EPSG dataset coordinate operation method code 9820.
%function [E,N]=gNavGeog2ProjLambAz(B,L,EllipParam,ProjParam), where
%B,L- rows, Latitude, Longitude in degrees;
%ProjParam- Lambert Azimuthal Equal Area parameters [Latitude_of_natural_origin(B0) Longitude_of_natural_origin(L0) False_easting False_northing];
%EllipParam- ellipsoid parameters [Semi major axis_a  Eccentricity_et];
%E,N- rows, Easting, Northing in meters;
%[E N][B L_west][B0 L0_west FE FN] >> [-E N][B -L_east][B0 -L0_east -FE FN]
%Example:
%EllipParam=[6378137 0.081819190842];ProjParam=[52 10 4321000 3210000];[GpsE,GpsN]=gNavGeog2ProjLambAz(49:.1:51,4:.1:6,EllipParam,ProjParam);
%[GpsLat,GpsLon]=gNavProjLambAz2Geog(GpsE,GpsN,EllipParam,ProjParam);

a=EllipParam(1);et=EllipParam(2);
B0=ProjParam(1)/180*pi;L0=ProjParam(2)/180*pi;FE=ProjParam(3);FN=ProjParam(4);
B=B/180*pi;L=L/180*pi;
switch ProjParam(1),
    case 90,
        qp=(1-et.^2).*(1./(1-et.^2)-(1./2./et.*log((1-et)./(1+et))));
        p=a.*sqrt(qp-(1-et.^2).*((sin(B)./(1-et.^2.*sin(B)))-(1./2./et.*log((1-et.*sin(B))./(1+et.*sin(B))))));
        E=FE+p.*sin(L-L0);
        N=FN-p.*cos(L-L0);
    case -90,
        qp=(1-et.^2).*(1./(1-et.^2)-(1./2./et.*log((1-et)./(1+et))));
        p=a.*sqrt(qp+(1-et.^2).*((sin(B)./(1-et.^2.*sin(B)))-(1./2./et.*log((1-et.*sin(B))./(1+et.*sin(B))))));
        E=FE+p.*sin(L-L0);
        N=FN+p.*cos(L-L0);
    otherwise
        qp=(1-et.^2).*(1./(1-et.^2)-(1./2./et.*log((1-et)./(1+et))));
        bt=asin((1-et.^2).*((sin(B)./(1-(et.*sin(B)).^2))-(1./2./et.*log((1-et.*sin(B))./(1+et.*sin(B)))))./qp);
        bt0=asin((1-et.^2).*((sin(B0)./(1-(et.*sin(B0)).^2))-(1./2./et.*log((1-et.*sin(B0))./(1+et.*sin(B0)))))./qp);
        Rq=a.*sqrt(qp./2);
        BB=Rq.*sqrt(2./(1+sin(bt0).*sin(bt)+(cos(bt0).*cos(bt).*cos(L-L0))));
        DD=a.*(cos(B0)./sqrt(1-(et.*sin(B0)).^2))./(Rq.*cos(bt0));
        E=FE+(BB.*DD.*cos(bt).*sin(L-L0));
        N=FN+(BB./DD.*(cos(bt0).*sin(bt)-sin(bt0).*cos(bt).*cos(L-L0)));
end;

%mail@ge0mlib.com 10/10/2017