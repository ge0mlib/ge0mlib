function [E,N]=gNavGeog2ProjMercator(B,L,EllipParam,ProjParam)
%Convert Geographic coordinates to Mercator projection. EPSG dataset coordinate operation method codes 9804,9805,1044,1026.
%Formulas source: "Geomatics Guidance Note 7, part 2 Coordinate Conversions&Transformations including Formulas", Report 373-7-2, October 2017.
%EPSG recognizes three variants of the Mercator projection, the methods called A (1SP; EPSG 9804), B (EPSG 9805), C (2SP; EPSG 1044), Spherical (EPSG 1026) and Pseudo-Mercator (EPSG 1024; "Web Mercator").
%EPSG 9804. The projection is defined with the equator as the single standard parallel, with scale factor on the equator also defined. False grid coordinates are applied at the natural origin of the projection, the intersection of the equator and the longitude of origin.
%EPSG 9805. Defined through the latitude of two parallels equidistant either side of the equator upon which the grid scale is true. False grid coordinates are applied at the natural origin of the projection, the intersection of the equator and the longitude of origin.
%EPSG 1044. Defined through the latitude of two parallels equidistant either side of the equator upon which the grid scale is true, as in variant (B). However in variant C false grid coordinates are applied at a point other than the natural origin of the projection, called the false origin.
%EPSG 1026. Mercator (Spherical). If latitude 90deg, N is infinite. The above formula for N will fail near to the pole, and should not be used poleward of 88deg.
%EPSG 1024. Pseudo-Mercator ("Web Mercator"). This method is utilised by some popular web mapping and visualisation applications. Strictly speaking the inclusion of 'Mercator' in the method name is misleading: it is not a Mercator projection, it is a different map projection and uses its own distinct formula: it is a separate method. Unlike either the spherical or ellipsoidal Mercator projection methods, this method is not conformal: scale factor varies as a function of azimuth, which creates angular distortion. Despite angular distortion there is no convergence in the meridian, so the graticule has a similar appearance to the graticule of a Mercator projection, but the graticules of the two projections do not overlay.
%function [E,N]=gNavGeog2ProjMercator(B,L,EllipParam,ProjParam), where
%B,L- rows, Latitude, Longitude in degrees;
%EllipParam- ellipsoid parameters [Semi_major_axis_a  Eccentricity_et];
%>>> ProjParam- EPSG 9804 parameters [Longitude_of_natural_origin(L0) Scale_at_natural_origin(K0) False_easting(FE) False_northing(FN) 1]; Latitude_of_natural_origin(B0)==0 by default.
%>>> ProjParam- EPSG 9805 parameters [Latitude_of_standard_parallel(B1) Longitude_of_natural_origin(L0) False_easting(FE) False_northing(FN) 2];
%>>> ProjParam- EPSG 1044 parameters [Latitude_of_standard_parallel(B1) Latitude_of_false_origin(Bf) Longitude_of_natural_origin(Lf) Easting_at_false_origin(EF) Northing_at_false_origin(NF) 3];
%>>> ProjParam- EPSG 1026 parameters [Longitude_of_natural_origin(L0) False_easting(FE) False_northing(FN) 4].
%>>> ProjParam- EPSG 1024 not realized.
%E,N- rows, Easting, Northing in meters;
%Examples:
%EllipParam=[6377397.155 0.081696831];ProjParam=[110 0.997 3900000 900000 1];[GpsE,GpsN]=gNavGeog2ProjMercator(-3,120,EllipParam,ProjParam);
%EllipParam=[6378245.0 0.08181333];ProjParam=[42 51 0 0 2];[GpsE,GpsN]=gNavGeog2ProjMercator(53,53,EllipParam,ProjParam);
%EllipParam=[6378245.0 0.08181333];ProjParam=[42 42 51 0 0 3];[GpsE,GpsN]=gNavGeog2ProjMercator(53,53,EllipParam,ProjParam);
%EllipParam=[6371007.0 0];ProjParam=[0 0 0 4];[GpsE,GpsN]=gNavGeog2ProjMercator(24.381786944444446,-100.3333333333333,EllipParam,ProjParam);

a=EllipParam(1);et=EllipParam(2);B=B./180.*pi;L=L./180.*pi;
switch ProjParam(end)
    case 1 %EPSG 9804
        L0=ProjParam(1)/180*pi;K0=ProjParam(2);FE=ProjParam(3);FN=ProjParam(4);
        E=FE+a*K0*(L-L0);
        N=FN+a*K0*log(tan(pi./4+B./2).*((1-et.*sin(B))./(1+et.*sin(B))).^(et./2));
    case 2 %EPSG 9805
        B1=ProjParam(1)/180*pi;L0=ProjParam(2)/180*pi;FE=ProjParam(3);FN=ProjParam(4);
        K0=cos(B1)./sqrt(1-(et.*sin(B1)).^2);
        E=FE+a*K0*(L-L0);
        N=FN+a*K0*log(tan(pi./4+B./2).*((1-et.*sin(B))./(1+et.*sin(B))).^(et./2));
    case 3 %EPSG 1044
        B1=ProjParam(1)/180*pi;Bf=ProjParam(2)/180*pi;Lf=ProjParam(3)/180*pi;EF=ProjParam(4);NF=ProjParam(5);
        K0=cos(B1)./sqrt(1-(et.*sin(B1)).^2);
        M=a.*K0.*log(tan(pi./4+Bf./2).*((1-et.*sin(Bf))./(1+et.*sin(Bf))).^(et./2));
        E=EF+a*K0*(L-Lf);
        N=(NF-M)+a*K0*log(tan(pi./4+B./2).*((1-et.*sin(B))./(1+et.*sin(B))).^(et./2));
    case 4 %EPSG 1026
        L0=ProjParam(1)/180*pi;FE=ProjParam(2);FN=ProjParam(3);
        if any(abs(B))>(88./180*pi),warning('Projection should not be used poleward of 88deg.');end
        E=FE+a.*(L-L0);
        N=FN+a.*log(tan(pi./4+B./2));        
end

%mail@ge0mlib.com 07/08/2021 (MatLab2018)