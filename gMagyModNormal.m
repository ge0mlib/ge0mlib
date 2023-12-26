function XYZm=gMagyModNormal(siz,parM,keyC)
%Create Normal magnetic field's X,Y,Z components matrix for [Module,Declination,Inclination] parameters.
%function XYZm=gMagyModNormal(siz,parM), where
%siz- elements number for output matrix (3xN vector) creation;
%XYZm- 3-rows matrix with magnetic field components (X,Y and Z);
%parM- normal field [T,D,I] values in "Earth magnetic field coordinate system"; for example [51872,-10.29,61.18] for 46.61N, 141.90E, 2016 year.
%keyC- coordinate system key for XYZm: 'E' is Earth magnetic field coordinate system; 'M' is Magnetization coordinate system.
%Example:
%[X,Y]=meshgrid(-20:.1:20,-30:.1:30);XYZn=gMagyModNormal(numel(X),[51872,-10.29,61.18],'E');
%Zn=reshape(XYZn(3,:),size(X));mesh(X,Y,Zn);axis ij;
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

[Xm,Ym,Zm]=gNavTiat(parM(2),parM(3),0);XYZn=Xm*Ym*Zm*[parM(1);0;0];%rotate T(along X) to angles D,I
XYZn(3)=-XYZn(3);%inverse Z
switch keyC,
    case 'E', 
    case 'M', tmp=XYZn(2);XYZn(2)=XYZn(1);XYZn(1)=tmp;%swap x and y axis if "Magnetization coordinate system"
    otherwise, error('Unexpected keyC value');
end;
XYZm=repmat(XYZn,1,siz);%create output

%mail@ge0mlib.com 26/12/2019