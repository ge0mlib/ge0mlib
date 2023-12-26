function [E,N]=gNavGeog2ProjLambertConicConf(B,L,EllipParam,ProjParam)
%Convert Geographic coordinates to Lambert Conic Conformal projection. EPSG dataset coordinate operation method codes 9801,9802,9826,9803,1051.
%Formulas source: "Geomatics Guidance Note 7, part 2 Coordinate Conversions&Transformations including Formulas", Report 373-7-2, October 2017.
%EPSG 9801; EPSG 9802. EPSG recognises two variants of the Lambert Conic Conformal, the methods called 1SP (EPSG 9810) and 2SP (EPSG 9802).
%EPSG 9826. 1SP West Orientated. In older mapping of Denmark and Greenland the Lambert Conic Conformal (1SP) is used with axes positive north and >>west<<.
%EPSG 9803. 2SP Belgium. In 1972, in order to retain approximately the same grid coordinates after a change of geodetic datum, a modified form of the two standard parallel case was introduced in Belgium. In 2000 this modification was replaced through use of the regular Lambert Conic Conformal (2SP) method with appropriately modified parameter values.
%EPSG 1051. 2SP Michigan. In 1964, the US state of Michigan redefined its State Plane CS27 zones, changing them from being Transverse Mercator zones orientated north-south to being Lambert Conic Conformal zones orientated east-west to better reflect the geography of the state.
%EPSG 9817. Lambert Conic Near-Conformal. The Lambert Conformal Conic with one standard parallel formulas, as published by the Army Map Service, are still in use in several countries. However in some countries the expansion formulas were truncated to the third order and the map projection is not fully conformal.
%function [E,N]=gNavGeog2ProjLambertConicConf(B,L,EllipParam,ProjParam), where
%B,L- rows, Latitude, Longitude in degrees;
%>>> ProjParam- 1SP parameters [Latitude_of_natural_origin(B0) Longitude_of_natural_origin(L0) Scale_factor_at_natural_origin(K0) False_easting(FE) False_northing(FN) 1];
%>>> ProjParam- 2SP parameters [Latitude_of_false_origin(Bf) Longitude_of_false_origin(Lf) Latitude_of_1st_standard_parallel(B1) Latitude_of_2nd_standard_parallel(B2) Easting_at_false_origin(EF) Northing_at_false_origin(NF) 2];
%>>> ProjParam- 1SP West Orientated parameters [Latitude_of_natural_origin(B0) Longitude_of_natural_origin(L0) Scale_factor_at_natural_origin(K0) False_easting(FE) False_northing(FN) 3];
%>>> ProjParam- 2SP Belgium parameters [Latitude_of_false_origin(Bf) Longitude_of_false_origin(Lf) Latitude_of_1st_standard_parallel(B1) Latitude_of_2nd_standard_parallel(B2) Easting_at_false_origin(EF) Northing_at_false_origin(NF) 4];
%>>> ProjParam- 2SP Michigan parameters [Latitude_of_false_origin(Bf) Longitude_of_false_origin(Lf) Latitude_of_1st_standard_parallel(B1) Latitude_of_2nd_standard_parallel(B2) Easting_at_false_origin(EF) Northing_at_false_origin(NF) Ellipsoid_scaling_factor(K) 5];
%EllipParam- ellipsoid parameters [Semi_major_axis_a  Eccentricity_et];
%E,N- rows, Easting, Northing in meters;
%Examples:
%EllipParam=[6378206.400 0.08227185];ProjParam=[18 -77 1 250000 150000 1];[GpsE,GpsN]=gNavGeog2ProjLambertConicConf(17.9321666666667,-76.9436833333333,EllipParam,ProjParam);
%EllipParam=[6378206.400 0.08227185];ProjParam=[27.8333333333333 -99 28.3833333333333 30.2833333333333 2000000*0.304800609601219 0 2];[GpsE,GpsN]=gNavGeog2ProjLambertConicConf(28.5,-96,EllipParam,ProjParam);
%EllipParam=[6378388 0.08199189];ProjParam=[90 4.35693972222222 49.833333333333333 51.166666666666667 150000.01 5400088.44 4];[GpsE,GpsN]=gNavGeog2ProjLambertConicConf(50.6795725,5.80737027777778,EllipParam,ProjParam);
%EllipParam=[6378206.400 0.08227185];ProjParam=[43.3166666666667 -84.3333333333333 44.1833333333333 45.7 2000000*0.304800609601219 0 1.0000382 5];[GpsE,GpsN]=gNavGeog2ProjLambertConicConf(43.75,-83.1666666666667,EllipParam,ProjParam);

Lz=B<0;B(Lz)=360+B(Lz);Lz=L<0;L(Lz)=360+L(Lz);
a=EllipParam(1);et=EllipParam(2);B=B./180.*pi;L=L./180.*pi;
switch ProjParam(end),
    case 1, %EPSG 9801, 1SP
        B0=ProjParam(1)/180*pi;L0=ProjParam(2)/180*pi;K0=ProjParam(3);FE=ProjParam(4);FN=ProjParam(5);
        m0=cos(B0)./sqrt(1-(et.*sin(B0)).^2);
        t0=tan(pi./4-B0./2)./((1-et.*sin(B0))./(1+et.*sin(B0))).^(et./2);
        n=sin(B0);
        F=m0./(n.*t0.^n);
        t=tan(pi./4-B./2)./((1-et.*sin(B))./(1+et.*sin(B))).^(et./2);
        r=a.*F.*K0.*t.^n;r0=a.*F.*K0.*t0.^n;
        tet=n.*(L-L0);
        E=FE+r.*sin(tet);
        N=FN+r0-r.*cos(tet);
    case 2, %EPSG 9802, 2SP
        Bf=ProjParam(1)/180*pi;Lf=ProjParam(2)/180*pi;B1=ProjParam(3)/180*pi;B2=ProjParam(4)/180*pi;EF=ProjParam(5);NF=ProjParam(6);
        m1=cos(B1)./sqrt(1-(et.*sin(B1)).^2);m2=cos(B2)./sqrt(1-(et.*sin(B2)).^2);
        t1=tan(pi./4-B1./2)./((1-et.*sin(B1))./(1+et.*sin(B1))).^(et./2);t2=tan(pi./4-B2./2)./((1-et.*sin(B2))./(1+et.*sin(B2))).^(et./2);
        n=(log(m1)-log(m2))./(log(t1)-log(t2));
        F=m1./(n.*t1.^n);
        t=tan(pi./4-B./2)./((1-et.*sin(B))./(1+et.*sin(B))).^(et./2);tf=tan(pi./4-Bf./2)./((1-et.*sin(Bf))./(1+et.*sin(Bf))).^(et./2);
        r=a.*F.*t.^n;rf=a.*F.*tf.^n;
        tet=n.*(L-Lf);
        E=EF+r.*sin(tet);
        N=NF+rf-r.*cos(tet);
    case 3, %EPSG 9826, 1SP West Orientated
        B0=ProjParam(1)/180*pi;L0=ProjParam(2)/180*pi;K0=ProjParam(3);FE=ProjParam(4);FN=ProjParam(5);
        m0=cos(B0)./sqrt(1-(et.*sin(B0)).^2);
        t0=tan(pi./4-B0./2)./((1-et.*sin(B0))./(1+et.*sin(B0))).^(et./2);
        n=sin(B0);
        F=m0./(n.*t0.^n);
        t=tan(pi./4-B./2)./((1-et.*sin(B))./(1+et.*sin(B))).^(et./2);
        r=a.*F.*K0.*t.^n;r0=a.*F.*K0.*t0.^n;
        tet=n.*(L-L0);
        E=FE-r.*sin(tet);
        N=FN+r0-r.*cos(tet);
    case 4, %EPSG 9803, 2SP Belgium
        Bf=ProjParam(1)/180*pi;Lf=ProjParam(2)/180*pi;B1=ProjParam(3)/180*pi;B2=ProjParam(4)/180*pi;EF=ProjParam(5);NF=ProjParam(6);
        m1=cos(B1)./sqrt(1-(et.*sin(B1)).^2);m2=cos(B2)./sqrt(1-(et.*sin(B2)).^2);
        t1=tan(pi./4-B1./2)./((1-et.*sin(B1))./(1+et.*sin(B1))).^(et./2);t2=tan(pi./4-B2./2)./((1-et.*sin(B2))./(1+et.*sin(B2))).^(et./2);
        n=(log(m1)-log(m2))./(log(t1)-log(t2));
        F=m1./(n.*t1.^n);
        t=tan(pi./4-B./2)./((1-et.*sin(B))./(1+et.*sin(B))).^(et./2);tf=tan(pi./4-Bf./2)./((1-et.*sin(Bf))./(1+et.*sin(Bf))).^(et./2);
        r=a.*F.*t.^n;rf=a.*F.*tf.^n;
        tet=n.*(L-Lf);
        aa=(29.2985./3600)./180.*pi;
        E=EF+r.*sin(tet-aa);
        N=NF+rf-r.*cos(tet-aa);
    case 5, %EPSG 1051, 2SP Michigan
        Bf=ProjParam(1)/180*pi;Lf=ProjParam(2)/180*pi;B1=ProjParam(3)/180*pi;B2=ProjParam(4)/180*pi;EF=ProjParam(5);NF=ProjParam(6);K=ProjParam(7);
        m1=cos(B1)./sqrt(1-(et.*sin(B1)).^2);m2=cos(B2)./sqrt(1-(et.*sin(B2)).^2);
        t1=tan(pi./4-B1./2)./((1-et.*sin(B1))./(1+et.*sin(B1))).^(et./2);t2=tan(pi./4-B2./2)./((1-et.*sin(B2))./(1+et.*sin(B2))).^(et./2);
        n=(log(m1)-log(m2))./(log(t1)-log(t2));
        F=m1./(n.*t1.^n);
        t=tan(pi./4-B./2)./((1-et.*sin(B))./(1+et.*sin(B))).^(et./2);tf=tan(pi./4-Bf./2)./((1-et.*sin(Bf))./(1+et.*sin(Bf))).^(et./2);
        r=a.*K.*F.*t.^n;rf=a.*K.*F.*tf.^n;
        tet=n.*(L-Lf);
        E=EF+r.*sin(tet);
        N=NF+rf-r.*cos(tet);
end;

%mail@ge0mlib.com 18/12/2020