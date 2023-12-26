function varargout=gNavTiatNLever(Head,Pitch,Roll,Lever,RotDirect)
%LeverArm's coordinates calculation using dimensions Head,Pitch,Roll (3D Tait–Bryan matrixes rotation). About 90 times faster for [Head,Pitch,Roll] dimensions, than the loop using gNavTiatLever function.
%function varargout=gNavTiatNLever(Head,Pitch,Roll,Lever,RotDirect), where
%Head - dimension of heading; rotation angle for x0y in degree [H_t1... H_tn];
%Pitch - dimension of pitch; rotation angle for z0x in degree [P_t1... P_tn];
%Roll - dimension of roll; rotation angle for y0z in degree [R_t1... R_tn];
%Lever - 3 rows with lever arms coordinates  [Lx1...Lxm; Ly1...Lym; Lz1...Lzm];
%RotDirect - 'frw' for forward rotation; 'rev' for reverse rotation;
%varargout=[X1,Y1,Z1...Xn,Yn,Zn] - "moved" lever arm coordinates, with size same [Head,Pitch,Roll] for different Levers
%if Roll or Pitch or Head is scalar, then vector with necessary size will be created.
%-----------------------
%Coordinate system is:
%^ x(forward/roll)
%| 
%o---> y(right/pitch)
%z(up/head)
%All right/clockwise rotation sign is + (if vector is rotated relatively axis);
%All left/unclockwise rotation sign is + (if axis are rotated relatively vector);
%-----------------------
%Example
%[X,Y,Z]=gNavTiatNLever([10;11;12],[20;21;22],[15;16;17],[10;15;20],'frw');[x,y,z]=gNavTiatNLever([-10;-11;-12],[-20;-21;-22],[-15;-16;-17],[X;Y;Z],'rev');
%[X1,Y1,Z1,X2,Y2,Z2]=gNavTiatNLever([10;11;12],[20;21;22],[15;16;17],[10 15 20;10 15 20]','frw');
%[dH,dP,dR]=meshgrid(-3:.02:3,-3:.02:3,-3:.02:3);[X1,Y1,Z1]=gNavTiatNLever(dH,dP,dR,[10;15;20],'frw');

if (numel(Head)>=numel(Pitch))&&(numel(Head)>=numel(Roll)),SZ=size(Head);end;if (numel(Pitch)>=numel(Head))&&(numel(Pitch)>=numel(Roll)),SZ=size(Pitch);end; if (numel(Roll)>=numel(Pitch))&&(numel(Roll)>=numel(Head)),SZ=size(Roll);end;
if all(size(Head)==1), Head=repmat(Head,SZ);end; if all(size(Pitch)==1), Pitch=repmat(Pitch,SZ);end; if all(size(Roll)==1), Roll=repmat(Roll,SZ);end;
if ~(all(SZ==size(Head))&&all(SZ==size(Pitch))&&all(SZ==size(Roll))),error('Heading,Pitch,Roll size must be equal size');end;
Head=Head./180.*pi;Pitch=Pitch./180.*pi;Roll=Roll./180.*pi;
Len=numel(Head);Head=reshape(Head,[1 1 Len]);Pitch=reshape(Pitch,[1 1 Len]);Roll=reshape(Roll,[1 1 Len]);
if isempty(RotDirect)||strcmp(RotDirect,'frw'), %forward rotation >> Head-Pitch-Roll >> RollM*PitchM*HeadM*Lever
    M=[cos(Pitch).*cos(Head) -cos(Pitch).*sin(Head) sin(Pitch);...
        cos(Roll).*sin(Head)+cos(Head).*sin(Roll).*sin(Pitch) cos(Roll).*cos(Head)-sin(Roll).*sin(Pitch).*sin(Head) -cos(Pitch).*sin(Roll);...
        sin(Roll).*sin(Head)-cos(Roll).*cos(Head).*sin(Pitch) cos(Head).*sin(Roll)+cos(Roll).*sin(Pitch).*sin(Head) cos(Roll).*cos(Pitch)];
elseif strcmp(RotDirect,'rev'), %reverse rotation >> Roll-Pitch-Head >> HeadM*PitchM*RollM*Lever
    M=[cos(Head).*cos(Pitch) cos(Head).*sin(Pitch).*sin(Roll)-sin(Head).*cos(Roll) cos(Head).*sin(Pitch).*cos(Roll)+sin(Head).*sin(Roll);...
        sin(Head).*cos(Pitch) sin(Head).*sin(Pitch).*sin(Roll)+cos(Head).*cos(Roll) sin(Head).*sin(Pitch).*cos(Roll)-cos(Head).*sin(Roll);...
        -sin(Pitch) cos(Pitch).*sin(Roll) cos(Pitch).*cos(Roll)];
else
    error('Incorrect RotDirect value');
end;
varargout=cell(size(Lever,2).*3);
for n=1:size(Lever,2),
    X=M(1,1,:).*Lever(1,n)+M(1,2,:).*Lever(2,n)+M(1,3,:).*Lever(3,n);varargout{(n-1).*3+1}=reshape(X,SZ);
    Y=M(2,1,:).*Lever(1,n)+M(2,2,:).*Lever(2,n)+M(2,3,:).*Lever(3,n);varargout{(n-1).*3+2}=reshape(Y,SZ);
    Z=M(3,1,:).*Lever(1,n)+M(3,2,:).*Lever(2,n)+M(3,3,:).*Lever(3,n);varargout{(n-1).*3+3}=reshape(Z,SZ);
end;

%mail@ge0mlib.com 07/06/2021