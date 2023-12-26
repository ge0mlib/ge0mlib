function XYZm=gMagyModDipol(X,Y,Z,parM,keyC)
%Calculate magnetic field's X,Y,Z components for dipole with parameters [Moment_intensity, Moment_azimuth_(declination), Moment_inclination, X_dipole_coord, Y_dipole_coord, Z_dipole_coord].
%function XYZm=gMagyModDipol(X,Y,Z,parM,keyC), where
%X,Y,Z- rows with coordinates for field calculation, the "space coordinate system" used;
%XYZm- 3-rows matrix with magnetic field components (X,Y and Z);
%parM- dipole’s parameters [Moment_intensity, Moment_azimuth_(declination), Moment_inclination, X_dipole_coord, Y_dipole_coord, Z_dipole_coord];
%for example parM=[53.75,-10.29,61.18,0,0,0], for 46.61N, 141.90E, 2016 year;
%keyC- coordinate system key for parM and XYZm: 'E' is Earth magnetic field coordinate system; 'M' is Magnetization coordinate system.
%Induced magnetization Moment_intensity: Mi=4pi*ksi*Tnorm*r^3/300 (the induced magnetization is set along Earth magnetic field).
%Example:
%mmm=4*pi*100*51827*0.1^3/300;
%[X,Y]=meshgrid(-20:.1:20,-30:.1:30);Z=repmat(4,size(X));XYZm=gMagyModDipol(X(:)',Y(:)',Z(:)',[mmm,-10.29,61.18,0,0,0],'E');Zm=reshape(XYZm(3,:),size(X));figure(1);mesh(X,Y,Zm);axis ij;
%XYZn=gMagyModNormal(length(X(:)),[51827,-10.29,61.18],'E');Zn=reshape(XYZn(3,:),size(X));figure(2);mesh(X,Y,Zn);axis ij;
%XYZmn=XYZm+XYZn;Tmn=sqrt(XYZmn(1,:).^2+XYZmn(2,:).^2+XYZmn(3,:).^2)-51827;T=reshape(Tmn,size(X));figure(3);mesh(X,Y,T);axis ij;figure(4);contour(X,Y,T,20,'ShowText','on');axis equal;axis ij;
%=========================================
%The space coordinate system:
%^ x(forward/north)
%|
%o---> y(right/east)
%z(up)
%Where Zm for Heading, Ym for Pitch, Xm for Roll; all right rotation sign is +
%========================================
%The Earth magnetic field coordinate system:
%^ x(forward/north)
%|
%x---> y(right/east)
%z(down);Declination - rotation from x-to-y +;Inclination - rotation from xy-to-z +
%========================================
%The Magnetization (J) coordinate system:
%^ y(forward/north)
%|
%x---> x(right/east)
%z(down);Declination - rotation from x-to-y +;Inclination - rotation from xy-to-z +
%========================================

X=X-parM(4);Y=Y-parM(5);Z=Z-parM(6);I=parM(3)./180.*pi;
switch keyC,
    case 'E', D=(90-parM(2))./180.*pi; k1=2;k2=1; %transform D from "Earth magnetic field coordinate system" to "Magnetization coordinate system"
    case 'M', D=parM(2)./180.*pi; k1=1;k2=2;
    otherwise, error('Unexpected keyC value');
end;
k=parM(1)./(X.^2+Y.^2+Z.^2).^2.5;
XYZm=zeros(3,length(X));
XYZm(k1,:)=k.*((2.*X.^2-Y.^2-Z.^2).*cos(I).*cos(D)+3.*X.*(Y.*cos(I).*sin(D)-Z.*sin(I))); % x-axis "parameter-J coordinate system" >>> y-axis "normal-field coordinate system"
XYZm(k2,:)=k.*((2.*Y.^2-X.^2-Z.^2).*cos(I).*sin(D)+3.*Y.*(X.*cos(I).*cos(D)-Z.*sin(I))); % y-axis "parameter-J coordinate system" >>> x-axis "normal-field coordinate system"
XYZm(3,:)=k.*((2.*Z.^2-Y.^2-X.^2).*sin(I)-3.*Z.*cos(I).*(Y.*sin(D)+X.*cos(D)));

%mail@ge0mlib.com 26/12/2019