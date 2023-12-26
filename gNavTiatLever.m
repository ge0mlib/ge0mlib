function XYZ_Lev=gNavTiatLever(Head,Pitch,Roll,Lever,RotDirect)
%A number LeverArm's coordinates calculation using scalar Head,Pitch,Roll (3D Tait–Bryan matrixes rotation).
%function XYZ_Lev=gNavTiatLever(Head,Pitch,Roll,Lever,RotDirect), where
%Head - row, rotation angle for x0y in degree [H_t1... H_tn];
%Pitch - row, rotation angle for z0x in degree [P_t1... P_tn];
%Roll - row, rotation angle for y0z in degree [R_t1... R_tn];
%Lever - 3 rows with lever arms coordinates [Lx_1 Ly_1 Lz_1; Lx_2 Ly_2 Lz_2; ...; Lx_m Ly_m Lz_m]';
%RotDirect - 'frw' for forward rotation; 'rev' for reverse rotation;
%XYZ_Lev - "moved" lever arms coordinates: column is [Lx;Ly;Lz]; rows is t1...tn; 3rd-size is Lever_1...Lever_m
%if Roll or Pitch or Head is scalar, then vector with necessary length will be created.
%-----------------------
%Coordinate system is:
%^ x(forward/roll)
%| 
%o---> y(right/pitch)
%z(up/head)
%All right/clockwise rotation sign is + (if vector is rotated relatively axis);
%All left/unclockwise rotation sign is + (if axis are rotated relatively vector);
%-----------------------
%Example: tr=[120;60;-80];tmp001=gNavTiatLever(-2,-2,-2,tr,'frw');

Head=Head./180.*pi;Pitch=Pitch./180.*pi;Roll=Roll./180.*pi;
Len=max([size(Roll,2) size(Pitch,2) size(Head,2)]);Len=Len(1);
if all(size(Head)==1), Head=repmat(Head,1,Len);end;
if all(size(Pitch)==1), Pitch=repmat(Pitch,1,Len);end;
if all(size(Roll)==1), Roll=repmat(Roll,1,Len);end;
if all(size(Head)~=size(Roll))||all(size(Pitch)~=size(Roll)), error('Roll,Pitch,Head length must be equal or scalar');end;
if size(Lever,1)~=3, error('Levers must be 3 rows with lever arms coordinates');end;
NumL=size(Lever,2);

XYZ_Lev=zeros(3,Len,NumL);%allocate memory for output
for n=1:Len, %calculate rotation for all levers
    if isempty(RotDirect)||strcmp(RotDirect,'frw'), %forward rotation >> Head-Pitch-Roll >> RollM*PitchM*HeadM*Lever
        XYZ_Lev(:,n,:)=[1 0 0; 0 cos(Roll(n)) -sin(Roll(n)); 0 sin(Roll(n)) cos(Roll(n))]*[cos(Pitch(n)) 0 sin(Pitch(n)); 0 1 0; -sin(Pitch(n)) 0 cos(Pitch(n))]*[cos(Head(n)) -sin(Head(n)) 0; sin(Head(n)) cos(Head(n)) 0; 0 0 1]*Lever;
    elseif strcmp(RotDirect,'rev'), %reverse rotation >> Roll-Pitch-Head >> HeadM*PitchM*RollM*Lever
        XYZ_Lev(:,n,:)=[cos(Head(n)) -sin(Head(n)) 0; sin(Head(n)) cos(Head(n)) 0; 0 0 1]*[cos(Pitch(n)) 0 sin(Pitch(n)); 0 1 0; -sin(Pitch(n)) 0 cos(Pitch(n))]*[1 0 0; 0 cos(Roll(n)) -sin(Roll(n)); 0 sin(Roll(n)) cos(Roll(n))]*Lever;
    else
        error('Incorrect RotDirect value');
    end;
end;

%mail@ge0mlib.com 07/06/2021