function [d,mask]=gMapGeomSegments2DCross(a1,a2,b1,b2)
%Find cross points for segments pairs a1_to_a2 and b1_to_b2 (2D only); nan, if segments in pair are parallel.
%The a1 and a2 are first and last a-segment’s points; b1 and b2 are first and last b-segment’s points. The number of a and b segments must be equal; if only one a-segment was define for several b-segments, than a-segment will be replicate to b-segments number.
%function [d,mask]=gMapGeomSegments2DCross(a1,a2,b1,b2), where
%a1- rows with a1(x,y) points coordinates for segments a1_to_a2;
%a2- rows with a2(x,y) points coordinates for segments a1_to_a2;
%b1- rows with b1(x,y) points coordinates for segments b1_to_b2;
%b2- rows with b2(x,y) points coordinates for segments b1_to_b2;
%d- rows with cross point (x,y) for segments, created on a1_to_a2 and b1_to_b2;
%mask- row mask for "cross point in borders of segments a1_to_a2 and b1_to_b2";
%One a1_to_a2 segment replicate to number b1_to_b2 segments.
%^y
%|
%---->x
%Function Example:
%[d,mask]=gMapGeomSegments2DCross([0 0;0 0;0 0]',[10 10;10 10;10 10]',[-8 9;-3 5;6 -1]',[-3 5;6 -1;10 -2]');
%[d,mask]=gMapGeomSegments2DCross([1 1]',[10 10]',[-8 9;-3 5;6 -1]',[-3 5;6 -1;10 -2]');

len=size(a1,2);
%replicate one a1_to_a2 segment to number b1_to_b2 segments
if (len==1)&&(size(b1,2)~=1), a1=repmat(a1,1,size(b1,2));a2=repmat(a2,1,size(b1,2));len=size(b1,2);end;
%shift point of origin
a1z=a1;a1=a1-a1z;a2=a2-a1z;b1=b1-a1z;b2=b2-a1z;
%general lines equation A1x+A2y+A3=0, for points a1 and a2 formed
a=cross([a1(1,:);a1(2,:);ones(1,len)],[a2(1,:);a2(2,:);ones(1,len)],1);
%general lines equation B1x+B2y+B3=0, for points b1 and b2 formed
b=cross([b1(1,:);b1(2,:);ones(1,len)],[b2(1,:);b2(2,:);ones(1,len)],1);
%cross point (x,y) for A1x+A2y+A3=0 and B1x+B2y+B3=0 lines; if collinear, then c=[0 0 0];d=[nan nan];
c=cross(a,b,1);d=[c(1,:)./c(3,:);c(2,:)./c(3,:)];
%mask for "cross point in borders of segments a1_to_a2 and b1_to_b2"
mask=((a1(1,:)-d(1,:)).*(a2(1,:)-d(1,:))<=(eps(a1(1,:))+eps(d(1,:))).*(eps(a2(1,:))+eps(d(1,:))))&...
    ((a1(2,:)-d(2,:)).*(a2(2,:)-d(2,:))<=(eps(a1(2,:))+eps(d(2,:))).*(eps(a2(2,:))+eps(d(2,:))))&...
    ((b1(1,:)-d(1,:)).*(b2(1,:)-d(1,:))<=(eps(b1(1,:))+eps(d(1,:))).*(eps(b2(1,:))+eps(d(1,:))))&...
    ((b1(2,:)-d(2,:)).*(b2(2,:)-d(2,:))<=(eps(b1(2,:))+eps(d(2,:))).*(eps(b2(2,:))+eps(d(2,:))));
%shift point of origin to original
d=d+a1z;

%mail@ge0mlib.com 22/07/2016