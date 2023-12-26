function varargout=gNavTiatLeverN(HPR,Lx,Ly,Lz,RotDirect)
%LeverArm's coordinates calculation using dimensions LeverX,LeverY,LeverZ (3D Tait–Bryan matrixes rotation). About 90 times faster for [Head,Pitch,Roll] dimensions, than the loop using gNavTiatLever function.
%function varargout=gNavTiatNLever(Head,Pitch,Roll,Lever,RotDirect), where
%HPR - 3 rows with [Head;Pitch;Roll] coordinates  [Head1...Headm; Pitch1...Pitchm; Roll1...Rollm];
%Lx - dimension of LeverX coordinates;
%Ly - dimension of LeverY coordinates;
%Lz - dimension of LeverZ coordinates;
%RotDirect - 'frw' for forward rotation; 'rev' for reverse rotation;
%varargout=[X1,Y1,Z1...Xn,Yn,Zn] - "moved" lever arm coordinates, with size same [Lx,Ly,Lz] for different [Head,Pitch,Roll]
%if Lx or Ly or Lz is scalar, then vector with necessary size will be created.
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
%[X,Y,Z]=gNavTiatLeverN([-10;-11;-12],[20;21;22],[15;16;17],[10;15;20],'frw');[x,y,z]=gNavTiatLeverN([10;11;12],X,Y,Z,'rev');
%[X1,Y1,Z1,X2,Y2,Z2]=gNavTiatNLever([10 15 20;10 15 20]',[10;11;12],[20;21;22],[15;16;17],'frw');
%[Lx,Ly,Lz]=meshgrid(-3:.02:3,-3:.02:3,-3:.02:3);[X1,Y1,Z1]=gNavTiatNLever([10;15;20],Lx,Ly,Lz,'frw');

if (numel(Lx)>=numel(Ly))&&(numel(Lx)>=numel(Lz)),SZ=size(Lx);end;if (numel(Ly)>=numel(Lx))&&(numel(Ly)>=numel(Lz)),SZ=size(Ly);end; if (numel(Lz)>=numel(Ly))&&(numel(Lz)>=numel(Lx)),SZ=size(Lz);end;
if all(size(Lx)==1), Lx=repmat(Lx,SZ);end; if all(size(Ly)==1), Ly=repmat(Ly,SZ);end; if all(size(Lz)==1), Lz=repmat(Lz,SZ);end;
if ~(all(SZ==size(Lx))&&all(SZ==size(Ly))&&all(SZ==size(Lz))),error('Lx,Ly,Lz size must be equal size');end;
Head=HPR(1,:)./180.*pi;Pitch=HPR(2,:)./180.*pi;Roll=HPR(3,:)./180.*pi;
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
varargout=cell(size(HPR,2).*3);
for n=1:size(HPR,2),
    varargout{(n-1).*3+1}=M(1,1,n).*Lx+M(1,2,n).*Ly+M(1,3,n).*Lz;
    varargout{(n-1).*3+2}=M(2,1,n).*Lx+M(2,2,n).*Ly+M(2,3,n).*Lz;
    varargout{(n-1).*3+3}=M(3,1,n).*Lx+M(3,2,n).*Ly+M(3,3,n).*Lz;
end;

%mail@ge0mlib.com 07/06/2021