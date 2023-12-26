function [B,L]=gNavProjPolarStereo2Geog(E,N,EllipParam,ProjParam)
%Convert Polar Stereographic projection to Geographic coordinates. EPSG dataset coordinate operation methods codes 9810,9829,9830.
%Formulas source: "Geomatics Guidance Note 7, part 2 Coordinate Conversions&Transformations including Formulas", Report 373-7-2, October 2017.
%For the polar sterographic projection, three variants are recognised, differentiated by their defining parameters. In the basic variant (variant A) the latitude of origin is either the north or the south pole, at which is defined a scale factor at the natural origin, the meridian along which the northing axis increments and along which intersecting parallels increment towards the north pole (the longitude of origin), and false grid coordinates. In variant B instead of the scale factor at the pole being defined, the (non-polar) latitude at which the scale is unity – the standard parallel – is defined. In variant C the latitude of a standard parallel along which the scale is unity is defined; the intersection of this parallel with the longitude of origin is the false origin, at which grid coordinate values are defined.
%EPSG 9810. In the basic variant 'A' the latitude of origin is either the north or the south pole.
%EPSG 9829. In variant 'B' instead of the scale factor at the pole being defined, the (non-polar) latitude at which the scale is unity – the standard parallel – is defined.
%EPSG 9830. In variant 'C' the latitude of a standard parallel along which the scale is unity is defined; the intersection of this parallel with the longitude of origin is the false origin, at which grid coordinate values are defined.
%function [B,L]=gNavProjPolarStereo2Geog(E,N,EllipParam,ProjParam), where
%E,N- rows, Easting, Northing in meters;
%>>> ProjParam- 'A' parameters [Longitude_of_natural_origin(L0) Scale_at_natural_origin(K0) False_easting(FE) False_northing(FN) key]; key set to 10 for south pole and 11 for north pole;
%>>> ProjParam- 'B' parameters [Latitude_of_standard_parallel(Bf) Longitude_of_natural_origin(L0) False_easting(FE) False_northing(FN) 2];
%>>> ProjParam- 'C' parameters [Latitude_of_standard_parallel(Bf) Longitude_of_natural_origin(L0) Easting_at_false_origin(EF) Northing_at_false_origin(NF) 3];
%EllipParam- ellipsoid parameters [Semi_major_axis_a  Eccentricity_et];
%B,L- rows, Latitude, Longitude in degrees;
%For the south pole case, latitude B is negative; longitude L measured clockwise in the projection plane. For the north pole case, longitude L measured anticlockwise in the projection plane.
%Examples:
%EllipParam=[6378137 0.081819190842];ProjParam=[0 0.994 2000000 2000000 11];[B,L]=gNavProjPolarStereo2Geog(3320416.75,632668.43,EllipParam,ProjParam);
%EllipParam=[6378137 0.081819191];ProjParam=[-71 70 6000000 6000000 2];[B,L]=gNavProjPolarStereo2Geog(7255380.79,7053389.56,EllipParam,ProjParam);
%EllipParam=[6378388 0.081991890];ProjParam=[-67 140 300000 200000 3];[B,L]=gNavProjPolarStereo2Geog(303169.52,244055.72,EllipParam,ProjParam);

a=EllipParam(1);et=EllipParam(2);
if (ProjParam(5)==10)||(ProjParam(5)==11),key=ProjParam(5);else key=ProjParam(5).*10+(ProjParam(1)>0);end;
switch key,
    case 10, %Type 'A', south pole case
        L0=ProjParam(1)/180*pi;K0=ProjParam(2);FE=ProjParam(3);FN=ProjParam(4);
        ro=sqrt((E-FE).^2+(N-FN).^2);
        t=ro.*sqrt((1+et).^(1+et).*(1-et).^(1-et))./(2.*a.*K0);
        ksi=2.*atan(t)-pi./2;
        B=ksi+(et.^2./2+5.*et.^4./24+et.^6./12+13.*et.^8./360).*sin(2.*ksi)+(7.*et.^4./48+29.*et.^6./240+811.*et.^8./115200).*sin(4.*ksi)+(7.*et.^6./120+81.*et.^8./1120).*sin(6.*ksi)+(4279.*et.^8./161280).*sin(8.*ksi);
        LL=E==FE;L=zeros(size(B));
        L(LL)=L0;L(~LL)=L0+atan2((E-FE),(N-FN));
    case 11, %Type 'A', north pole case
        L0=ProjParam(1)/180*pi;K0=ProjParam(2);FE=ProjParam(3);FN=ProjParam(4);
        ro=sqrt((E-FE).^2+(N-FN).^2);
        t=ro.*sqrt((1+et).^(1+et).*(1-et).^(1-et))./(2.*a.*K0);
        ksi=pi./2-2.*atan(t);
        B=ksi+(et.^2./2+5.*et.^4./24+et.^6./12+13.*et.^8./360).*sin(2.*ksi)+(7.*et.^4./48+29.*et.^6./240+811.*et.^8./115200).*sin(4.*ksi)+(7.*et.^6./120+81.*et.^8./1120).*sin(6.*ksi)+(4279.*et.^8./161280).*sin(8.*ksi);
        LL=E==FE;L=zeros(size(B));
        L(LL)=L0;L(~LL)=L0+atan2((E-FE),(FN-N));
    case 20, %Type 'B', south pole case
        Bf=ProjParam(1)/180*pi;L0=ProjParam(2)/180*pi;FE=ProjParam(3);FN=ProjParam(4);
        tf=tan(pi./4+Bf./2)./((1+et.*sin(Bf))./(1-et.*sin(Bf))).^(et./2);
        mf=cos(Bf)./sqrt(1-(et.*sin(Bf)).^2);
        K0=mf.*sqrt((1+et).^(1+et).*(1-et).^(1-et))./2./tf;
        ro=sqrt((E-FE).^2+(N-FN).^2);
        t=ro.*sqrt((1+et).^(1+et).*(1-et).^(1-et))./(2.*a.*K0);
        ksi=2.*atan(t)-pi./2;
        B=ksi+(et.^2./2+5.*et.^4./24+et.^6./12+13.*et.^8./360).*sin(2.*ksi)+(7.*et.^4./48+29.*et.^6./240+811.*et.^8./115200).*sin(4.*ksi)+(7.*et.^6./120+81.*et.^8./1120).*sin(6.*ksi)+(4279.*et.^8./161280).*sin(8.*ksi);
        LL=E==FE;L=zeros(size(B));
        L(LL)=L0;L(~LL)=L0+atan2((E-FE),(N-FN));
    case 21, %Type 'B', north pole case
        Bf=ProjParam(1)/180*pi;L0=ProjParam(2)/180*pi;FE=ProjParam(3);FN=ProjParam(4);
        tf=tan(pi./4-Bf./2).*((1+et.*sin(Bf))./(1-et.*sin(Bf))).^(et./2);
        mf=cos(Bf)./sqrt(1-(et.*sin(Bf)).^2);
        K0=mf.*sqrt((1+et).^(1+et).*(1-et).^(1-et))./2./tf;
        ro=sqrt((E-FE).^2+(N-FN).^2);
        t=ro.*sqrt((1+et).^(1+et).*(1-et).^(1-et))./(2.*a.*K0);
        ksi=pi./2-2.*atan(t);
        B=ksi+(et.^2./2+5.*et.^4./24+et.^6./12+13.*et.^8./360).*sin(2.*ksi)+(7.*et.^4./48+29.*et.^6./240+811.*et.^8./115200).*sin(4.*ksi)+(7.*et.^6./120+81.*et.^8./1120).*sin(6.*ksi)+(4279.*et.^8./161280).*sin(8.*ksi);
        LL=E==FE;L=zeros(size(B));
        L(LL)=L0;L(~LL)=L0+atan2((E-FE),(FN-N));
    case 30, %Type 'C', south pole case
        Bf=ProjParam(1)/180*pi;L0=ProjParam(2)/180*pi;EF=ProjParam(3);NF=ProjParam(4);
        tf=tan(pi./4+Bf./2)./((1+et.*sin(Bf))./(1-et.*sin(Bf))).^(et./2);
        mf=cos(Bf)./sqrt(1-(et.*sin(Bf)).^2);
        rof=a.*mf;
        ro=sqrt((E-EF).^2+(N-NF+rof).^2);
        t=ro.*tf./rof;
        ksi=2.*atan(t)-pi./2;
        B=ksi+(et.^2./2+5.*et.^4./24+et.^6./12+13.*et.^8./360).*sin(2.*ksi)+(7.*et.^4./48+29.*et.^6./240+811.*et.^8./115200).*sin(4.*ksi)+(7.*et.^6./120+81.*et.^8./1120).*sin(6.*ksi)+(4279.*et.^8./161280).*sin(8.*ksi);
        LL=E==EF;L=zeros(size(B));
        L(LL)=L0;L(~LL)=L0+atan2((E-EF),(N-NF+rof));
    case 31, %Type 'C', north pole case
        Bf=ProjParam(1)/180*pi;L0=ProjParam(2)/180*pi;EF=ProjParam(3);NF=ProjParam(4);
        tf=tan(pi./4-Bf./2).*((1+et.*sin(Bf))./(1-et.*sin(Bf))).^(et./2);
        mf=cos(Bf)./sqrt(1-(et.*sin(Bf)).^2);
        rof=a.*mf;
        ro=sqrt((E-EF).^2+(N-NF-rof).^2);
        t=ro.*tf./rof;
        ksi=pi./2-2.*atan(t);
        B=ksi+(et.^2./2+5.*et.^4./24+et.^6./12+13.*et.^8./360).*sin(2.*ksi)+(7.*et.^4./48+29.*et.^6./240+811.*et.^8./115200).*sin(4.*ksi)+(7.*et.^6./120+81.*et.^8./1120).*sin(6.*ksi)+(4279.*et.^8./161280).*sin(8.*ksi);
        LL=E==EF;L=zeros(size(B));
        L(LL)=L0;L(~LL)=L0+atan2((E-EF),(NF+rof-N));
end;
B=B./pi.*180;L=L./pi.*180;

%mail@ge0mlib.com 09/12/2020