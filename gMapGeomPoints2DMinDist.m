 function [nk2,nK2,Dmin]=gMapGeomPoints2DMinDist(kxy,dk,KXY,dK,key_one)
%Find minimal distance from each kxy-points to all KXY-points (2D only).
%function [nk2,nK2,Dmin]=gMapGeomPoints2DMinDist(kxy,dk,KXY,dK,key_one), where
%kxy- rows [kp;x;y] with points_1 (polyline_1) coordinates;
%dk- kp-step for points_1 (polyline_1) point to point; if isrmpty, than kp is not recalc;
%KXY- rows [KP;X;Y] with points_2 or polyline_2 coordinates;
%dK- KP-step for polyline_2 point to point; if isrmpty, than kp is not recalc;
%key_one- if key==1 then the least distance from all kxy-points to all KXY-points be founded.
%nk2- points_1 [numbers;X;Y] or polyline_1 [kp;X;Y] for minimal distance search;
%nK2- points_2 [numbers;X;Y] or polyline_2 [KP;X;Y] for minimal distance with k2(n) was founded;
%Dmin- minimal distance value between k2 and nK2;
%^y
%|
%---->x
%Function Example:
%[k2,nK2,Dmin]=gMapGeomPoints2DMinDist(kxy,[],KXY,[],0);
%[k2,nK2,Dmin]=gMapGeomPoints2DMinDist(kxy,0.1,KXY,0.1,0);

%Kp interpolation if polylines
if ~isempty(dk), k2=kxy(1,1):dk:kxy(1,end);x=interp1(kxy(1,:),kxy(2,:),k2,'linear');y=interp1(kxy(1,:),kxy(3,:),k2,'linear');xy=[x;y];
else k2=kxy(1,:);xy=kxy(2:3,:);end;
if ~isempty(dK), K2=KXY(1,1):dK:KXY(1,end);X=interp1(KXY(1,:),KXY(2,:),K2,'linear');Y=interp1(KXY(1,:),KXY(3,:),K2,'linear');XY=[X;Y];
else K2=KXY(1,:);XY=KXY(2:3,:);end;
%minimal distance from each kxy-points to all KXY-points
Len=size(k2,2);LenK2=size(K2,2);
nk2=[k2;xy];nK2=[nan(size(k2));nan(size(xy))];Dmin=nan(size(k2));
for n=1:Len,
    r=XY-repmat(xy(:,n),1,LenK2);d=abs(complex(r(1,:),r(2,:)));[D,I]=min(d);
    if length(I)>1, warning('More than 1 min');end;
    nK2(:,n)=[K2(I);XY(:,I)];Dmin(n)=D;
end;
%the least distance from all kxy-points to all KXY-points
if key_one==1,
    [D,I]=min(Dmin);
    if length(I)>1, warning('More than 1 min');end;
    nk2=nk2(:,I);nK2=nK2(:,I);Dmin=D;
end;

%mail@ge0mlib.com 22/07/2016