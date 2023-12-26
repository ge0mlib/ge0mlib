function dXY=gNavArc2Len(B,L,EllipParam)
%Length in meters along Latitude and Longitude arc in degrees.
%function dXY=gNavArc2Len(B,L,EllipParam), where
%B - Latitude, 2 values in degrees;
%L - Longitude, 2 values in degrees;
%EllipParam - ellipsoid parameters [Semi major axis_a  Eccentricity_et];
%dXY=[dX dY] - length along Latitude and Longitude.
%The Simpsons equation used for dX calculation. The (B(1)+B(2))/2 used for dY calculation.
%Example: dXY=gNavArc2Len([29.99 30.01],[141.99 142.01],[6378137 0.081819190842]);

a=EllipParam(1);et=EllipParam(2);B=B/180*pi;L=L/180*pi;Bm=(B(1)+B(2))/2;dXY=[0;0];
dXY(1)=a.*cos(Bm).*(L(2)-L(1))./sqrt(1-(et.*sin(Bm)).^2);
M1=a.*(1-et.^2)./(1-(et.*sin(B(1))).^2).^1.5;
Mm=a.*(1-et.^2)./(1-(et.*sin(Bm)).^2).^1.5;
M2=a.*(1-et.^2)./(1-(et.*sin(B(2))).^2).^1.5;
dXY(2)=(B(2)-B(1))./6.*(M1+4.*Mm+M2);

%mail@ge0mlib.com 15/09/2017