function [B,L]=gNavProjLambAz2Geog(E,N,EllipParam,ProjParam)
%Convert Lambert Azimuthal Equal Area projection coordinates to Geographic. EPSG dataset coordinate operation method code 9820.
%function [B,L]=gNavProjLambAz2Geog(E,N,EllipParam,ProjParam), where
%E,N- rows, Easting, Northing in meters;
%ProjParam- Lambert Azimuthal Equal Area parameters [Latitude_of_natural_origin(B0) Longitude_of_natural_origin(L0) False_easting False_northing];
%EllipParam- ellipsoid parameters [Semi major axis_a  Eccentricity_et];
%B,L- rows, Latitude, Longitude in degrees;
%[E N][B L_west][B0 L0_west FE FN] >> [-E N][B -L_east][B0 -L0_east -FE FN]
%Example:
%EllipParam=[6378137 0.081819190842];ProjParam=[52 10 4321000 3210000];[GpsE,GpsN]=gNavGeog2ProjLambAz(49:.1:51,4:.1:6,EllipParam,ProjParam);
%[GpsLat,GpsLon]=gNavProjLambAz2Geog(GpsE,GpsN,EllipParam,ProjParam);

a=EllipParam(1);et=EllipParam(2);
B0=ProjParam(1)/180*pi;L0=ProjParam(2)/180*pi;FE=ProjParam(3);FN=ProjParam(4);
switch ProjParam(1),
    case 90,
        L=L0+atan((E-FE)./-(N-FN));
        p=sqrt((E-FE).^2+(N-FN).^2);
        bt1=sign(B0).*asin(1-p.^2./(a.^2.*(1-(1-et.^2)./2./et.*log((1-et)./(1+et)))));
        B=bt1+(et.^2./3+31.*et.^4./180+517.*et.^6./5040).*sin(2.*bt1)+(23.*et.^4/360+251.*et.^6./3780).*sin(4.*bt1)+761.*et.^6./45360.*sin(6.*bt1);
    case -90,
        L=L0+atan((E-FE)./(N-FN));
        p=sqrt((E-FE).^2+(N-FN).^2);
        bt1=sign(B0).*asin(1-p.^2./(a.^2.*(1-(1-et.^2)./2./et.*log((1-et)./(1+et)))));
        B=bt1+(et.^2./3+31.*et.^4./180+517.*et.^6./5040).*sin(2.*bt1)+(23.*et.^4/360+251.*et.^6./3780).*sin(4.*bt1)+761.*et.^6./45360.*sin(6.*bt1);
    otherwise
        qp=(1-et.^2).*(1./(1-et.^2)-(1./2./et.*log((1-et)./(1+et))));
        bt0=asin((1-et.^2).*((sin(B0)./(1-(et.*sin(B0)).^2))-(1./2./et.*log((1-et.*sin(B0))./(1+et.*sin(B0)))))./qp);
        Rq=a.*sqrt(qp./2);
        DD=a.*(cos(B0)./sqrt(1-(et.*sin(B0)).^2))./(Rq.*cos(bt0));
        p=sqrt(((E-FE)./DD).^2+((N-FN).*DD).^2);
        CC=2.*asin(p./2./Rq);
        L=L0+atan((E-FE).*sin(CC)./(DD.*p.*cos(bt0).*cos(CC)-DD.^2.*(N-FN).*sin(bt0).*sin(CC)));
        bt1=asin(cos(CC).*sin(bt0)+DD.*(N-FN).*sin(CC).*cos(bt0)./p);
        B=bt1+(et.^2./3+31.*et.^4./180+517.*et.^6./5040).*sin(2.*bt1)+(23.*et.^4/360+251.*et.^6./3780).*sin(4.*bt1)+761.*et.^6./45360.*sin(6.*bt1);
end;
B=B./pi.*180;L=L./pi.*180;

%mail@ge0mlib.com 10/10/2017