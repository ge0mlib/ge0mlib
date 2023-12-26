function [B,L]=gNavProjLambertConicConf2Geog(E,N,EllipParam,ProjParam)
%Convert Lambert Conic Conformal projection to Geographic coordinates. EPSG dataset coordinate operation method codes 9801,9802,9826,9803,1051.
%Formulas source: "Geomatics Guidance Note 7, part 2 Coordinate Conversions&Transformations including Formulas", Report 373-7-2, October 2017.
%EPSG 9801; EPSG 9802. EPSG recognises two variants of the Lambert Conic Conformal, the methods called 1SP (EPSG 9810) and 2SP (EPSG 9802).
%EPSG 9826. 1SP West Orientated. In older mapping of Denmark and Greenland the Lambert Conic Conformal (1SP) is used with axes positive north and >>west<<.
%EPSG 9803. 2SP Belgium. In 1972, in order to retain approximately the same grid coordinates after a change of geodetic datum, a modified form of the two standard parallel case was introduced in Belgium. In 2000 this modification was replaced through use of the regular Lambert Conic Conformal (2SP) method with appropriately modified parameter values.
%EPSG 1051. 2SP Michigan. In 1964, the US state of Michigan redefined its State Plane CS27 zones, changing them from being Transverse Mercator zones orientated north-south to being Lambert Conic Conformal zones orientated east-west to better reflect the geography of the state.
%EPSG 9817. Lambert Conic Near-Conformal. The Lambert Conformal Conic with one standard parallel formulas, as published by the Army Map Service, are still in use in several countries. However in some countries the expansion formulas were truncated to the third order and the map projection is not fully conformal.
%function [B,L]=gNavProjLambertConicConf2Geog(E,N,EllipParam,ProjParam), where
%E,N- rows, Easting, Northing in meters;
%>>> ProjParam- 1SP parameters [Latitude_of_natural_origin(B0) Longitude_of_natural_origin(L0) Scale_factor_at_natural_origin(K0) False_easting(FE) False_northing(FN) 1];
%>>> ProjParam- 2SP parameters [Latitude_of_false_origin(Bf) Longitude_of_false_origin(Lf) Latitude_of_1st_standard_parallel(B1) Latitude_of_2nd_standard_parallel(B2) Easting_at_false_origin(EF) Northing_at_false_origin(NF) 2];
%>>> ProjParam- 1SP West Orientated parameters [Latitude_of_natural_origin(B0) Longitude_of_natural_origin(L0) Scale_factor_at_natural_origin(K0) False_easting(FE) False_northing(FN) 3];
%>>> ProjParam- 2SP Belgium parameters [Latitude_of_false_origin(Bf) Longitude_of_false_origin(Lf) Latitude_of_1st_standard_parallel(B1) Latitude_of_2nd_standard_parallel(B2) Easting_at_false_origin(EF) Northing_at_false_origin(NF) 4];
%>>> ProjParam- 2SP Michigan parameters [Latitude_of_false_origin(Bf) Longitude_of_false_origin(Lf) Latitude_of_1st_standard_parallel(B1) Latitude_of_2nd_standard_parallel(B2) Easting_at_false_origin(EF) Northing_at_false_origin(NF) Ellipsoid_scaling_factor(K) 5];
%EllipParam- ellipsoid parameters [Semi_major_axis_a  Eccentricity_et];
%B,L- rows, Latitude, Longitude in degrees;
%Examples:
%EllipParam=[6378206.400 0.08227185];ProjParam=[18 -77 1 250000 150000 1];[GpsE,GpsN]=gNavProjLambertConicConf2Geog(255966.58,142493.51,EllipParam,ProjParam);
%EllipParam=[6378206.400 0.08227185];ProjParam=[27.8333333333333 -99 28.3833333333333 30.2833333333333 2000000*0.304800609601219 0 2];[GpsE,GpsN]=gNavProjLambertConicConf2Geog(903277.79915962,77650.9425731394,EllipParam,ProjParam);
%EllipParam=[6378388 0.08199189];ProjParam=[90 4.35693972222222 49.833333333333333 51.166666666666667 150000.01 5400088.44 4];[GpsE,GpsN]=gNavProjLambertConicConf2Geog(251763.20,153034.13,EllipParam,ProjParam);
%EllipParam=[6378206.400 0.08227185];ProjParam=[43.3166666666667 -84.3333333333333 44.1833333333333 45.7 2000000*0.304800609601219 0 1.0000382 5];[GpsE,GpsN]=gNavProjLambertConicConf2Geog(703582.144930931,48832.2520113746,EllipParam,ProjParam);

a=EllipParam(1);et=EllipParam(2);
switch ProjParam(end),
    case 1, %EPSG 9801, 1SP
        B0=ProjParam(1)/180*pi;L0=ProjParam(2)/180*pi;K0=ProjParam(3);FE=ProjParam(4);FN=ProjParam(5);
        m0=cos(B0)./sqrt(1-(et.*sin(B0)).^2);
        t0=tan(pi./4-B0./2)./((1-et.*sin(B0))./(1+et.*sin(B0))).^(et./2);
        n=sin(B0);
        F=m0./(n.*t0.^n);
        r0=a.*F.*K0.*t0.^n;
        r=sign(n).*sqrt((E-FE).^2+(r0-(N-FN)).^2);
        t=(r./(a.*K0.*F)).^(1/n);
        tet=atan((E-FE)./(r0-(N-FN)));
        Bi=pi./2-2.*atan(t);for nn=1:6;B=pi./2-2.*atan(t.*((1-et.*sin(Bi))./(1+et.*sin(Bi))).^(et./2));Bi=B;end;
        L=tet./n+L0;
    case 2, %EPSG 9802, 2SP
        Bf=ProjParam(1)/180*pi;Lf=ProjParam(2)/180*pi;B1=ProjParam(3)/180*pi;B2=ProjParam(4)/180*pi;EF=ProjParam(5);NF=ProjParam(6);
        m1=cos(B1)./sqrt(1-(et.*sin(B1)).^2);m2=cos(B2)./sqrt(1-(et.*sin(B2)).^2);
        t1=tan(pi./4-B1./2)./((1-et.*sin(B1))./(1+et.*sin(B1))).^(et./2);t2=tan(pi./4-B2./2)./((1-et.*sin(B2))./(1+et.*sin(B2))).^(et./2);
        n=(log(m1)-log(m2))./(log(t1)-log(t2));
        F=m1./(n.*t1.^n);
        tf=tan(pi./4-Bf./2)./((1-et.*sin(Bf))./(1+et.*sin(Bf))).^(et./2);
        rf=a.*F.*tf.^n;
        r=sign(n).*sqrt((E-EF).^2+(rf-(N-NF)).^2);
        t=(r./(a.*F)).^(1./n);
        tet=atan((E-EF)./(rf-(N-NF)));
        Bi=pi./2-2.*atan(t);for nn=1:6;B=pi./2-2.*atan(t.*((1-et.*sin(Bi))./(1+et.*sin(Bi))).^(et./2));Bi=B;end;
        L=tet./n+Lf;
    case 3, %EPSG 9826, 1SP West Orientated
        B0=ProjParam(1)/180*pi;L0=ProjParam(2)/180*pi;K0=ProjParam(3);FE=ProjParam(4);FN=ProjParam(5);
        m0=cos(B0)./sqrt(1-(et.*sin(B0)).^2);
        t0=tan(pi./4-B0./2)./((1-et.*sin(B0))./(1+et.*sin(B0))).^(et./2);
        n=sin(B0);
        F=m0./(n.*t0.^n);
        r0=a.*F.*K0.*t0.^n;
        r=sign(n).*sqrt((FE-E).^2+(r0-(N-FN)).^2);
        t=(r./(a.*K0.*F)).^(1/n);
        tet=atan((FE-E)./(r0-(N-FN)));
        Bi=pi./2-2.*atan(t);for nn=1:6;B=pi./2-2.*atan(t.*((1-et.*sin(Bi))./(1+et.*sin(Bi))).^(et./2));Bi=B;end;
        L=tet./n+L0;
    case 4, %EPSG 9803, 2SP Belgium
        Bf=ProjParam(1)/180*pi;Lf=ProjParam(2)/180*pi;B1=ProjParam(3)/180*pi;B2=ProjParam(4)/180*pi;EF=ProjParam(5);NF=ProjParam(6);
        m1=cos(B1)./sqrt(1-(et.*sin(B1)).^2);m2=cos(B2)./sqrt(1-(et.*sin(B2)).^2);
        t1=tan(pi./4-B1./2)./((1-et.*sin(B1))./(1+et.*sin(B1))).^(et./2);t2=tan(pi./4-B2./2)./((1-et.*sin(B2))./(1+et.*sin(B2))).^(et./2);
        n=(log(m1)-log(m2))./(log(t1)-log(t2));
        F=m1./(n.*t1.^n);
        tf=tan(pi./4-Bf./2)./((1-et.*sin(Bf))./(1+et.*sin(Bf))).^(et./2);
        rf=a.*F.*tf.^n;
        r=sign(n).*sqrt((E-EF).^2+(rf-(N-NF)).^2);
        t=(r./(a.*F)).^(1./n);
        tet=atan((E-EF)./(rf-(N-NF)));
        Bi=pi./2-2.*atan(t);for nn=1:6;B=pi./2-2.*atan(t.*((1-et.*sin(Bi))./(1+et.*sin(Bi))).^(et./2));Bi=B;end;
        aa=(29.2985./3600)./180.*pi;
        L=(tet+aa)./n+Lf;
    case 5, %EPSG 1051, 2SP Michigan
        Bf=ProjParam(1)/180*pi;Lf=ProjParam(2)/180*pi;B1=ProjParam(3)/180*pi;B2=ProjParam(4)/180*pi;EF=ProjParam(5);NF=ProjParam(6);K=ProjParam(7);
        m1=cos(B1)./sqrt(1-(et.*sin(B1)).^2);m2=cos(B2)./sqrt(1-(et.*sin(B2)).^2);
        t1=tan(pi./4-B1./2)./((1-et.*sin(B1))./(1+et.*sin(B1))).^(et./2);t2=tan(pi./4-B2./2)./((1-et.*sin(B2))./(1+et.*sin(B2))).^(et./2);
        n=(log(m1)-log(m2))./(log(t1)-log(t2));
        F=m1./(n.*t1.^n);
        tf=tan(pi./4-Bf./2)./((1-et.*sin(Bf))./(1+et.*sin(Bf))).^(et./2);
        rf=a.*K.*F.*tf.^n;
        r=sign(n).*sqrt((E-EF).^2+(rf-(N-NF)).^2);
        t=(r./(a.*K.*F)).^(1./n);
        tet=atan((E-EF)./(rf-(N-NF)));
        Bi=pi./2-2.*atan(t);for nn=1:6;B=pi./2-2.*atan(t.*((1-et.*sin(Bi))./(1+et.*sin(Bi))).^(et./2));Bi=B;end;
        L=tet./n+Lf;
end;
B=B./pi.*180;L=L./pi.*180;

%mail@ge0mlib.com 18/12/2020