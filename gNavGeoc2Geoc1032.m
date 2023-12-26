function [X2,Y2,Z2]=gNavGeoc2Geoc1032(X1,Y1,Z1,conv_dat)
%Convert coordinates from first geocentric reference system to second
%function [X2,Y2,Z2]=gNavGeoc2Geoc1032(X1,Y1,Z1,conv_dat), where
%X1,Y1,Z1 - input/first geocentric coordinates rows, meters;
%conv_dat - conversion parameters [dx dy dz wx wy wz m] or conversion key; wx wy wz is arcsec;
%X2,Y2,Z2 - output/second geocentric coordinates rows, meters;
%Used Coordinate Frame Rotation (geocentric domain)/EPSG Dataset coordinate operation method code 1032, where wxyz has changed sign relative to Helmert 7-parameter transformations (Position Vector transformation /EPSG Dataset coordinate operation method code 1033).
%Example:
%GpsEllipseParam=[6378137 0.081819190842];[X,Y,Z]=gNavGeog2Geoc(51:.1:52,142:.1:143,100,GpsEllipseParam);pr=[23.57 -140.95 -79.8 0.000 -0.35 -0.79 -0.22e-6];
%[X2,Y2,Z2]=gNavGeoc2Geoc1032inv(X,Y,Z,pr);[X1,Y1,Z1]=gNavGeoc2Geoc1032(X2,Y2,Z2,pr);dXYZ_inv=[X;Y;Z]-[X1;Y1;Z1];
%[X2,Y2,Z2]=gNavGeoc2Geoc1032(X,Y,Z,pr);[X1,Y1,Z1]=gNavGeoc2Geoc1032(X2,Y2,Z2,pr);dXYZ=[X;Y;Z]-[X1;Y1;Z1];

dxyz=conv_dat(1:3);wxyz=conv_dat(4:6);m=conv_dat(7);
wxyz=wxyz./3600.*(pi./180);
w=[1 wxyz(3) -wxyz(2);-wxyz(3) 1 wxyz(1);wxyz(2) -wxyz(1) 1];
XYZ1=[X1;Y1;Z1];
XYZ2=(1+m).*w*XYZ1+repmat(dxyz',1,size(XYZ1,2));
X2=XYZ2(1,:);Y2=XYZ2(2,:);Z2=XYZ2(3,:);

%mail@ge0mlib.com 28/01/2018

%'pulkovo1942_pulkovo1995', dxyz=[-0.9 -10.06 1.76];wxyz=[0 -0.35 -0.66];m=0; %no name
%'pulkovo1995_pulkovo1942', dxyz=-[-0.9 -10.06 1.76];wxyz=-[0 -0.35 -0.66];m=-0; %no name
%'pulkovo1942_pz90', dxyz=[25 -141 -80];wxyz=[0 -0.35 -0.66];m=0; %√Œ—“ – 51794-2008
%'pz90_pulkovo1942', dxyz=-[25 -141 -80];wxyz=-[0 -0.35 -0.66];m=-0; %√Œ—“ – 51794-2008
%'pulkovo1942_pz90.02', dxyz=[23.93 -141.03 -79.98];wxyz=[0 -0.35 -0.79];m=-0.22e-6; %√Œ—“ – 51794-2008
%'pz90.02_pulkovo1942', dxyz=-[23.93 -141.03 -79.98];wxyz=-[0 -0.35 -0.79];m=0.22e-6; %√Œ—“ – 51794-2008
%'pulkovo1942_wgs84', dxyz=[23.900 -141.300 -80.900];wxyz=[0.000 0.350 0.820];m=-0.12e-6; %no name √Œ—“ 2001
%'wgs84_pulkovo1942', dxyz=-[23.900 -141.300 -80.900];wxyz=-[0.000 0.350 0.820];m=0.12e-6; %no name √Œ—“ 2001
%'pulkovo1942_wgs84', dxyz=[23.57 -140.95 -79.8];wxyz=[0.000 -0.35 -0.79];m=-0.22e-6; %no name √Œ—“ 2008
%'pulkovo1942_wgs84', dxyz=[23.92 -141.27 -80.9];wxyz=[0 0.35 0.82];m=-0.12e-6; %EPSG::1267
%'pulkovo1942_wgs84', dxyz=[27 -135 -84.5];wxyz=[0 0 -2.686e-6];m=2.263e-7; %ERDAS IMAGINE Pulkovo 1942
%'pulkovo1942_wgs84', dxyz=[24 -123 -94];wxyz=[-9.69e-7 1.212e-6 6.3e-7];m=1.1e-6; %ERDAS IMAGINE System 42/83 (Pulkow)
%'pulkovo1942_wgs84', dxyz=[25 -141 -78.5];wxyz=[0 -0.35 -0.736];m=0; %EPSG::15865
%'pulkovo1942_wgs84', dxyz=[24 -123 -94];wxyz=[0.02 -0.25 -0.13];m=1.1e-6; %Mapinfo 1001 inversed
%'pulkovo1995_pz90', dxyz=[25.90 -130.94 -81.76];wxyz=[0.00 0.00 0.00];m=0;
%'pz90_pulkovo1995', dxyz=-[25.90 -130.94 -81.76];wxyz=-[0.00 0.00 0.00];m=-0;
%'pulkovo1995_pz90.02', dxyz=[24.83 -130.97 -81.74];wxyz=[0.00 0.00 -0.13];m=-0.22e-6; %√Œ—“ – 51794-2008
%'pz90.02_pulkovo1995', dxyz=-[24.83 -130.97 -81.74];wxyz=-[0.00 0.00 -0.13];m=0.22e-6; %√Œ—“ – 51794-2008
%'pulkovo1995_wgs84', dxyz=[24.800 -131.240 -82.660];wxyz=[0.000 0.000 -0.160];m=-0.12e-6; %no name √Œ—“ 2001
%'wgs84_pulkovo1995', dxyz=-[24.800 -131.240 -82.660];wxyz=-[0.000 0.000 -0.160];m=0.12e-6; %no name √Œ—“ 2001
%'pulkovo1995_wgs84', dxyz=[24.47 -130.89 -81.56];wxyz=[0.000 0.000 -0.13];m=-0.22e-6; %no name √Œ—“ 2008
%'pulkovo1995_wgs84', dxyz=[24.82 -131.21 -82.66];wxyz=[0.000 0.000 -0.16];m=-0.12e-6; %Mapinfo 1014
%'pz90_wgs84', dxyz=[-1.08 -0.27 -0.9];wxyz=[0 0 -0.16];m=-0.12e-6; %√Œ—“ 51794-2001/EPSG::1244/Mapinfo 1012
%'wgs84_pz90', dxyz=-[-1.08 -0.27 -0.9];wxyz=-[0 0 -0.16];m=0.12e-6; %√Œ—“ 51794-2001/EPSG::1244/Mapinfo 1012
%'pz90_wgs84', dxyz=[0 0 1.5];wxyz=[0 0 -0.076];m=0; %EPSG:15843
%'pz90_wgs84', dxyz=[-1.10 -0.30 -0.90];wxyz=[0.00 0.00 -0.20];m=-0.12e-6; %√Œ—“ 51794-2008
%'pz90.02_wgs84', dxyz=[-0.36 0.08 0.18];wxyz=[0 0 0];m=0; %√Œ—“ – 51794-2008
%'wgs84_pz90.02', dxyz=-[-0.36 0.08 0.18];wxyz=-[0 0 0];m=-0; %√Œ—“ – 51794-2008
%'pz90.02_pz90', dxyz=[1.07 0.03 -0.02];wxyz=[0 0 0.13];m=0.22e-6; %√Œ—“ – 51794-2008
%'pz90_pz90.02', dxyz=-[1.07 0.03 -0.02];wxyz=-[0 0 0.13];m=-0.22e-6; %√Œ—“ – 51794-2008
%'pz90.02_pz90.11', dxyz=[-0.373 0.186 0.202];wxyz=[-0.0023 0.00354 -0.00421];m=-0.008e-6; %no name
%'pz90.11_pz90.02', dxyz=-[-0.373 0.186 0.202];wxyz=-[-0.0023 0.00354 -0.00421];m=0.008e-6; %no name
%'ITRF2008_pz90.11', dxyz=[-0.003 -0.001 0];wxyz=[0.019e-3 -0.042e-3 0.002e-3];m=0; %no name
%'pz90.11_ITRF2008', dxyz=-[-0.003 -0.001 0];wxyz=-[0.019e-3 -0.042e-3 0.002e-3];m=-0; %no name
