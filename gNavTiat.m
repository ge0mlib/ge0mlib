function [HeadM,PitchM,RollM]=gNavTiat(Head,Pitch,Roll)
%The basic rotation matrixes calculation.
%function [HeadM,PitchM,RollM]=gNavTiat(Head,Pitch,Roll), where
%Head- rotation angle for x0y in degree;
%Pitch- rotation angle for z0x in degree;
%Roll- rotation angle for y0z in degree;
%HeadM-  Z-basic rotation matrix for rotation in x0y (Heading);
%PitchM-  Y-basic rotation matrix for rotation in z0x (Pitch);
%RollM-  X-basic rotation matrix for rotation in y0z (Roll).
%The rotated vector is defined in primary coordinate system.
%-----------------------
%The primary coordinate system:
%^ x(forward/roll)
%|
%o---> y(right/pitch)
%z(up/head)
%All right/clockwise rotation sign is + (if vector is rotated relatively axis);
%All left/unclockwise rotation sign is + (if axis are rotated relatively vector);
%-----------------------
%Example:
%[HeadM,PitchM,RollM]=gNavTiat(30,0,0);a=HeadM*[1 0 0]'; %right rotation to 30 degree for x0y
%[Xm,Ym,Zm]=gNavTiat(8,5,30);a=Xm*Ym*Zm*[1.2 5 3]'; %right rotation for Heading - Pitch - Roll angles.
%[HeadM,PitchM,RollM]=gNavTiat(10,5,8);z1=HeadM*PitchM*RollM;[HeadM,PitchM,RollM]=gNavTiat(-10,-5,-8);z2=RollM*PitchM*HeadM;z3=(z1)^(-1);disp(z2);disp(z3);

Head=Head./180.*pi;Pitch=Pitch./180.*pi;Roll=Roll./180.*pi;
if all(size(Head)==1),
    HeadM=[cos(Head) -sin(Head) 0; sin(Head) cos(Head) 0; 0 0 1]; %around Z
    PitchM=[cos(Pitch) 0 sin(Pitch); 0 1 0; -sin(Pitch) 0 cos(Pitch)]; %around Y
    RollM=[1 0 0; 0 cos(Roll) -sin(Roll); 0 sin(Roll) cos(Roll)]; %around X
elseif numel(size(Head)==3)&&size(Head,1)==1&&size(Head,2)==1,
    m0=zeros(size(Head));m1=ones(size(Head));
    HeadM=[cos(Head) -sin(Head) m0; sin(Head) cos(Head) m0; m0 m0 m1];
    PitchM=[cos(Pitch) m0 sin(Pitch); m0 m1 m0; -sin(Pitch) m0 cos(Pitch)];
    RollM=[m1 m0 m0; m0 cos(Roll) -sin(Roll); m0 sin(Roll) cos(Roll)];
else error('Head,Pitch,Roll must be scalar or vector along 3rd direction');
end;

%mail@ge0mlib.com 18/09/2017