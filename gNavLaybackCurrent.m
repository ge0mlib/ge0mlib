function EN=gNavLaybackCurrent(ENLZt,ENFA)
!!! DEAFT
%Towing fish position calculation using tow-point position, cable length, height from fish to tow-point.
%function EN=gNavLayback(ENLZt,ENFA,figDraw), where
%ENLZt- rows includes [X;Y;L;Z;H;t]; XY- tow point position, L- cable length, Z- height from fish to tow-point, H- heading (azimuth) in Cartesian; t-time in seconds
%ENFA- rows includes [X;Y;F;A]; XY- current estimation position, F- current's speed in m/sec, A- current's azimuth in Cartesian; can be empty for ignore.
%EN- towing fish position;
%figDraw- figure number for tow-point and fish trackplot drawing (not drawing if empty).
%Current algorithm is similar to "Dragging" algorithm described in Data Acquisition Software/25479-01 Rev.K/GEOMETRICS, INC.
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
%4) Z is fish depth and tow-point-height sum. 
%Example: EN=gNavLayback([GpsE;GpsN;CableCounter;TPHeigth+DepthSensor;t],ENFA,100);

if any(ENLZt(3,:)<ENLZt(4,:)), error('Error gNLayback: Cable Length less than Depth');end;
len=size(ENLZt,2);EN=zeros(2,len);

%towfish is installed back in the fist-to-second points direction; the L and Z take from first point
r=ENLZt(1:2,2)-ENLZt(1:2,1);
if all(~r), ENfish=ENLZt(1:2,1); %if fist and second points equal
else ENfish=ENLZt(1:2,1)-r.*sqrt(ENLZt(3,1).^2-ENLZt(4,1).^2)./abs(r(1)+r(2)*1i);
end;
EN(:,1)=ENfish; %XY(1,:) - fish position for fist point; XYfish - "current" fish position (will be changed from point to point).
%Current web pre-interpolate
if ~isempty(ENFA), intF=scatteredInterpolant(ENFA(1,:),ENFA(:,2),ENFA(:,3),'linear','nearest');intA=scatteredInterpolant(ENFA(1,:),ENFA(:,2),ENFA(:,4),'linear','nearest');
else dENcurrent=[0;0];
end;
%fish position calculation
for nn=2:len,
    if ~isempty(ENFA),
        F=intF(ENfish);A=intA(ENfish);%������������� �������� � ����������� ������� �� ������� ��������� ���� (ENfish)
        tmp=F.*(ENLZt(5,nn)-ENLZt(5,nn-1)).*exp((A+90)./180.*pi.*1i);dENcurrent=[real(tmp);imag(tmp)];%������������� ��������-�-������ � �������� �� EN � ������ ������� t
    end;
    r=ENfish-(ENLZt(1:2,nn)-dENcurrent); %������ 0 �� ������� ��������� ����� ����������, ������� ������������� ���������� "��������" ��������� ����; �������������� "��������" ������� ��������� ����� ���������� "������ �������" (��������� � ��������� ���������� ������ �������� ������������ ������ �����) 
    new_rL=sqrt(r(1).^2+r(2).^2+ENLZt(4,nn).^2); %������� ���������� new_rL -- �� 0 (����� ��������� ����� ����������) �� �������� ��������� ����, �� � ����� ��������
    if (new_rL>ENLZt(3,nn)), %���� new_rL ������ ������� ����� �������������� ������, �� ���� ���������� - ����������� ����� ��������� ���� (����� - ��������� ���� �� ������)
        proj_rL=abs(r(1)+r(2)*1i); %������ �������� �� x0y �� 0 �� �������� ��������� ����
        proj_cL=sqrt(ENLZt(3,nn).^2-ENLZt(4,nn).^2); %������ �������� �������������� ������ �� x0y (� ������ ������ ����������� ���� � ����� ������ ������)
        ENfish=r.*proj_cL./proj_rL+ENLZt(1:2,nn); %"�������" xy-���������� �������; ������: ����������� ��������� (��������) ����� ����������� ������� (������������� ���������) + �������� 0
    end;
    ENfish=ENfish+dENcurrent;%"��������" ������� ��������� ���� "�� �������" (��������� �������� ������ ����� ������������ ���)
    EN(:,nn)=ENfish;
end;
%draw figure
%if ~isempty(figDraw), figure(figDraw);hold on;plot(ENLZt(2,:),ENLZt(1,:),'.-r');plot(EN(2,:),EN(1,:),'.-g');end;

%mail@ge0mlib.ru 27/07/2016