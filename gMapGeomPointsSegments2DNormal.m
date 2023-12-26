function [d,r,mask]=gMapGeomPointsSegments2DNormal(a1,b1,b2)
%Find cross_points for pairs normal from points a1 and segments b1_to_b2 (2D only).
%The number of a1 points and b segments must be equal; if only one a1-point was define for several b-segments, than a1-point will be replicate to b-segments number. Functions works correctly if point on line formed on b1_to_b2 segment.
%function [d,r,mask]=gMapGeomPointsSegments2DNormal(a1,b1,b2), where
%a1- rows with a1(x,y) points coordinates;
%b1- rows with b1(x,y) points coordinates for segments b1_to_b2;
%b2- rows with b2(x,y) points coordinates for segments b1_to_b2;
%d- rows with cross point coordinates (x,y) for normal from a1 to line formed on b1_to_b2;
%r- row "signed" distance from a1 to cross point (x,y);if we go from fist to second Kp then left side "sign" is negativ.
%mask- mask for "cross point in borders of b1_to_b2 segment".
%One a1 point replicate to number b1_to_b2 segments (special case).
%Functions works correctly if point on line formed on b1_to_b2 segment.
%^y
%|
%---->x
%Function Example:
%[d,r,mask]=gMapGeomPointsSegments2DNormal([0 0;0 0;0 0]',[-8 9;-3 5;6 -1]',[-3 5;6 -1;10 -2]');
%[d,r,mask]=gMapGeomPointsSegments2DNormal([1 1]',[-8 9;-3 5;6 -1]',[-3 5;6 -1;10 -2]');

len=size(a1,2);
%replicate one a1 point to number b1_to_b2 segments
if (len==1)&&(size(b1,2)~=1), a1=repmat(a1,1,size(b1,2));len=size(b1,2);end;
%shift point of origin
b1=b1-a1;b2=b2-a1;
%general lines equation A1x+A2y+A3=0, for normal (a1 is point of origin); used dot product condition x1*y1+x2*y2=0 for normal lines equation
a=[b1(1,:)-b2(1,:);b1(2,:)-b2(2,:);zeros(1,len)];
%general lines equation B1x+B2y+B3=0, for points b1 and b2 formed
b=cross([b1(1,:);b1(2,:);ones(1,len)],[b2(1,:);b2(2,:);ones(1,len)],1);
%cross point (x,y) for A1x+A2y+A3=0 and B1x+B2y+B3=0 lines; if collinear, then c=[0 0 0];d=[nan nan];
c=cross(a,b,1);d=[c(1,:)./c(3,:);c(2,:)./c(3,:)];
%calculate sign as sign(complex(d_b2)/complex(d_a))
as=0-d;bs=b2-d;s=sign(angle(complex(bs(1,:),bs(2,:))./complex(as(1,:),as(2,:))));%as=a1-d;
%calculate distance from a1 (a1 is point of origin) to cross points
r=s.*abs(complex(d(1,:),d(2,:)));
%mask for "cross point in borders of segments a1_to_a2 and b1_to_b2"
mask=((b1(1,:)-d(1,:)).*(b2(1,:)-d(1,:))<=(eps(b1(1,:))+eps(d(1,:))).*(eps(b2(1,:))+eps(d(1,:))))&...
    ((b1(2,:)-d(2,:)).*(b2(2,:)-d(2,:))<=(eps(b1(2,:))+eps(d(2,:))).*(eps(b2(2,:))+eps(d(2,:))));
%shift point of origin to original
d=d+a1;

%mail@ge0mlib.com 23/03/2017