function [dd,rrr]=gMapGeomPointsPolyline2DNormal(a,b)
%Find cross points for minimal-distance-normal from points a to polyline b (2D only).
%function [dd,rrr]=gMapGeomPointsPolyline2DNormal(a,b), where
%a- rows with a(x,y) points coordinates;
%b- rows with b(kp,x,y) points coordinates for polyline;
%dd- rows with cross point coordinates (kp,x,y) for normal from points to polyline;
%rrr- row "signed" distance from points to cross points (x,y);if we go from fist to second kp then left side "sign" is negativ.
%Algorithm: 1)find minimal distance from point to polyline points, 2)try to draw normal for two segments near minimal-distance-point.
%Function Example:
%[dd,r]=gMapGeomPointsPolyline2DNormal([1;1],[1 2 3;-5 -1 7;8 -3 -6]);
%a=dlmread('d:\pointsXY.txt')';b=dlmread('e:\KpXY.txt')';[dd,r]=gMapGeomPointsPolyline2DNormal(a,b);
%plot(b(2,:),b(3,:),'.-');hold on;plot(a(1,:),a(2,:),'o');plot(dd(2,:),dd(3,:),'x');axis equal;
%dlmwrite('d:\pointsDist.txt',[dd;r]','precision','%.3f','delimiter','\t','newline','pc');

dd=nan(3,size(a,2));rrr=nan(1,size(a,2));
for n=1:size(a,2),
    %find min-distance pipe index
    r=b(2:3,:)-repmat(a(:,n),1,size(b,2));
    d=abs(complex(r(1,:),r(2,:)));
    I=find(d==min(d));if length(I)>1, warning(['More than 1 minimum; index:' num2str(I)]);I=I(1);end;
    %fist segmetn analyse
    fl=0;
    if I~=size(b,2),
        rr=sqrt((b(2,I+1)-b(2,I)).^2+(b(3,I+1)-b(3,I)).^2);cosa=(b(2,I+1)-b(2,I))./rr;sina=(b(3,I+1)-b(3,I))./rr;%segment length, cos and sin
        EN=[cosa sina;-sina cosa]*(a(:,n)-b(2:3,I));%rotate segment to E-axis
        if (EN(1)>=0)&&(EN(1)<=rr),%if p-point E on the segment
            k=EN(1)./rr;%proportionality kooficient
            dd(:,n)=b(:,I)+(b(:,I+1)-b(:,I)).*k;%calc kp/x/y+"proportional kp/x/y"
            rrr(n)=-EN(2);%distance
            fl=1;
        end;
        sg1=-sign(EN(2));
    end;
    %fist segmetn analyse
    if (I~=1)&&(fl==0),%step back Iback=I-1;
        rr=sqrt((b(2,I)-b(2,I-1)).^2+(b(3,I)-b(3,I-1)).^2);cosa=(b(2,I)-b(2,I-1))./rr;sina=(b(3,I)-b(3,I-1))./rr;%segment length, cos and sin
        EN=[cosa sina;-sina cosa]*(a(:,n)-b(2:3,I-1));%rotate segment to E-axis
        if (EN(1)>=0)&&(EN(1)<=rr),%if p-point E on the segment
            k=EN(1)./rr;%proportionality kooficient
            dd(:,n)=b(:,I-1)+(b(:,I)-b(:,I-1)).*k;%calc kp/x/y+"proportional kp/x/y"
            rrr(n)=-EN(2);%distance
            fl=1;
        end;
        sg2=-sign(EN(2));
    end;
    %point-is-angle _^_ analyse
    if (I~=size(b,2))&&(I~=1),
        if (fl==0),
            if (sg1==sg2), dd(:,n)=b(:,I);rrr(n)=sg1.*d(I);
            else dd(:,n)=nan;rrr(n)=nan;warning('Position incorrect, set NaN value');end;
        end;
    else dd(:,n)=nan;rrr(n)=nan;warning('Point not in interval, set NaN value');
    end;
end;

%mail@ge0mlib.com 29/08/16