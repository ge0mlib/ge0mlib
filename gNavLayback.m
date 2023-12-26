function ENout=gNavLayback(ENLZA,angL)
%Towing fish position calculation using tow-point position, cable length, height from fish to tow-point.
%function ENout=gNavLayback(ENLZA,angL), where
%ENLZA- rows includes [E;N;L;Z;A]; EN- tow point position, L- cable length, Z- height from fish to tow-point;A- TowBody heading angle;
%angL- survey line direction;
%ENout- towing fish position.
%Current algorithm is similar to "Dragging" algorithm described in Data Acquisition Software/25479-01 Rev.K/GEOMETRICS, INC with rotation at feather angle.
%-----------------------
%The coordinate system:
%^ N
%|
%x---> E
%z(down)
%-----------------------
%Model's conditions:
%1) tow point is joint;
%2) if "cable is sag", then fish position is not changed;
%3) for fist point - towfish is installed back in the fist-to-second points direction;
%4) Z is fish depth and tow-point-height sum;
%5) if A-heading angle is presented, than rotate TowPoint-to-TowBoby vector in direction opposite A.
%Example: EN=gNavLayback([GpsE;GpsN;CableCounter;TPHeigth+DepthSensor;VesselHeading],25);

if any(ENLZA(3,:)<ENLZA(4,:)), error('Error gNavLayback: Cable Length less than Depth');end;
len=size(ENLZA,2);EN=zeros(2,len);
%towfish is installed back in the fist-to-second points direction; the L and Z take from first point
r=ENLZA(1:2,2)-ENLZA(1:2,1);
if all(~r), ENfish=ENLZA(1:2,1); %if fist and second points equal
else ENfish=ENLZA(1:2,1)-r.*sqrt(ENLZA(3,1).^2-ENLZA(4,1).^2)./abs(r(1)+r(2)*1i);
end;

EN(:,1)=ENfish; %EN(1,:) - fish position for fist point; ENfish - "current" fish position (will be changed from point to point).
%fish position calculation using "Draging method"
for nn=2:len,
    r=ENfish-ENLZA(1:2,nn); %ставим 0 на текущее положение точки буксировки, считаем относительные координаты "прошлого" положения рыбы
    new_rL=sqrt(r(1).^2+r(2).^2+ENLZA(4,nn).^2); %считаем расстояние new_rL -- от 0 (новое положение точки буксировки) до прошлого положения рыбы, но с новой глубиной
    if (new_rL>ENLZA(3,nn)), %если new_rL больше текущей длины буксировочного кабеля, то рыба сдвинулась - расчитываем новое положение рыбы (иначе - положение рыбы не меняем)
        proj_rL=abs(r(1)+r(2)*1i); %длинна проекции на x0y от 0 до прошлого положения рыбы
        proj_cL=sqrt(ENLZA(3,nn).^2-ENLZA(4,nn).^2); %длина проекции буксировочного кабеля на x0y (с учетом нового заглубления рыбы и новой длинны кабеля)
        ENfish=r.*proj_cL./proj_rL+ENLZA(1:2,nn); %"текущие" xy-координаты прибора; расчет: соотношение гипотенуз (проекций) равно соотношению катетов (относительных координат) + смещение 0
    end;
    EN(:,nn)=ENfish;
end;
ENout=EN;

%rotate layback's value if Heading presents
if size(ENLZA,1)==5,
    EN2=zeros(2,len);
    if isempty(angL),angL=angle(real(ENLZA(2,end)-ENLZA(2,1))+(ENLZA(1,end)-ENLZA(1,1)).*1i)./pi.*180;end;%if isempty Bearing, than calculate, using first and last point coordinates
    rI=(ENLZA(1,:)-EN(1,:)).*1i+real(ENLZA(2,:)-EN(2,:));
    rI=rI.*exp((ENLZA(5,:)-angL)./180.*pi.*1i);
    EN2(1,:)=ENLZA(1,:)-imag(rI);EN2(2,:)=ENLZA(2,:)-real(rI);
    ENout=EN2;
end;
%figure(f);hold on;plot(ENLZA(2,:),ENLZA(1,:),'.-r');plot(EN(2,:),EN(1,:),'.-g');plot(EN2(2,:),EN2(1,:),'.-c');

%mail@ge0mlib.com 18/10/2019