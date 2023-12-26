function XYZm=gMagyModCylinder(X,Y,Z,parM,keyC)
%Warning! Need to check
%Calculate magnetic field's X,Y,Z components for Horizontal Cylinder with parameters [Moment_intensity, Moment_azimuth_(declination), Moment_inclination, X1_cylinder, Y1_cylinder, Z1_cylinder, X2_cylinder, Y2_cylinder].
%function XYZm=gMagyModCylinder(X,Y,Z,parM,keyC), where
%X,Y,Z - rows with field calculation coordinates, the "space coordinate system" used;
%XYZm - 3-rows matrix with magnetic field components (X,Y and Z);
%parM - cylinder parameters [Moment_intensity, Moment_azimuth_(declination), Moment_inclination, X1_cylinder, Y1_cylinder, Z1_cylinder, X2_cylinder, Y2_cylinder];
%for example parM=[306,-10.29,61.18,0,0,1,1,1] for 46.61N, 141.90E, 2016 year;
%keyC- coordinate system key for XYZm: 'E' is Earth magnetic field coordinate system; 'M' is Magnetization coordinate system.

%M*mu0/4/pi calculation: (R1(0.6m)^2-R2(0.58m)^2)*ksi(100)*B(51872nT)/4=30604; the calculated field will be in nT; inductive magnetization along Earth magnetic field.
%Example:
%[X,Y]=meshgrid(-20:.1:20,-30:.1:30);Z=repmat(2,size(X));XYZm=gMagyCylinder(X(:)',Y(:)',Z(:)',[204246,-10.29,61.18,0,0,0,0,30]);Zm=reshape(XYZm(3,:),size(X));figure(1);mesh(X,Y,Zm);axis ij;
%XYZn=gMagyNormal(numel(X),[51872,-10.29,61.18]);Zn=reshape(XYZn(3,:),size(X));figure(2);mesh(X,Y,Zn);axis ij;
%XYZmn=XYZm+XYZn;Tmn=sqrt(XYZmn(1,:).^2+XYZmn(2,:).^2+XYZmn(3,:).^2)-51872;T=reshape(Tmn,size(X));figure(3);mesh(X,Y,T);axis ij;figure(4);contour(X,Y,T,30,'ShowText','on');axis equal;axis ij;
%figure(100);hold on;for n=0:60:350;XYZm=gMagyCylinder(X(:)',Y(:)',Z(:)',[53.75,-10.29,n,0,0,0,0,30]);XYZmn=XYZm+XYZn;Tmn=sqrt(XYZmn(1,:).^2+XYZmn(2,:).^2+XYZmn(3,:).^2)-51872;T=reshape(Tmn,size(X));plot(X(5,:),T(5,:));end;
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

Im=parM(3)./180.*pi;Zm=parM(1).*sin(Im);Hm=parM(1).*cos(Im);%magnetization declination; inclination; vertical; horizontal
switch keyC,
    case 'E', Dm=(90-parM(2))./180.*pi; k1=2;k2=1; %transform D from "Earth magnetic field coordinate system" to "Magnetization coordinate system"
    case 'M', Dm=parM(2)./180.*pi; k1=1;k2=2;
    otherwise, error('Unexpected keyC value');
end;

Dc=angle(complex(parM(7)-parM(4),parM(8)-parM(5)));%cylinder direction (declination) from first point to second
Hmcy=Hm.*sin(Dm-Dc);Imcy=angle(complex(Hmcy,Zm));Mmcy2=2.*sqrt(Hmcy.^2+Zm.^2);%y-projection for y is perpendicular to cylinder direction; inclination for y is perpendicular to cylinder direction; M projection for y is perpendicular to cylinder direction
Yc=-(X-parM(4)).*sin(Dc)+(Y-parM(5)).*cos(Dc);%calculate y for y is perpendicular to cylinder direction and 0 is fist cylinder's point
h=Z-parM(6);%set 0 to fist cylinder's point
tmp=(h.^2+Yc.^2).^2;
Ha=Mmcy2.*((h.^2-Yc.^2).*cos(Imcy)+2.*h.*Yc.*sin(Imcy))./tmp;
%calculate XYZ magnetic
XYZm=zeros(3,numel(X));
XYZm(k1,:)=-Ha.*sin(Dc);XYZm(k2,:)=Ha.*cos(Dc);
XYZm(3,:)=Mmcy2.*((h.^2-Yc.^2).*sin(Imcy)-2.*h.*Yc.*cos(Imcy))./tmp;

%mail@ge0mlib.com 08/09/2016