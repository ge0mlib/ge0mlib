function HMag=gMagyReadG88tvgMag(fName,K)
%Read data from text file with was created MagLog Geometrics program for G882-TVG double magnetometer (*.MAG)
%function HMag=gFMagReadG88tvgMag(fName,K), where
%fName - reading file name;
%K - Altimeter and Depth sensor coefficients: [AltScale1 AltBias1 DepthScale1 DepthBias1; AltScale2 AltBias2 DepthScale2 DepthBias2];
%HMag - data structure with reading fields: G88Koeff, CompDay, CompTime, MagAbsT, MagPrecSignal, Depth, Altitude
%*.MAG file format example:
%$ 35179.070,1047,0603,1550, 35177.225,1121,0574,0112  09/12/07 10:41:21.791
%$ 35178.779,1047,0610,1567, 35176.918,1123,0574,0112  09/12/07 10:41:21.901
%1      2      3    4    5  6   7       8    9   10 11 12 13 14 15 16  17
%Mag file columns: 1)total magnetic field1; 2)signal1; 3)depth1; 4)altitude1; 5)total magnetic field2; 6)signal2; 7)depth2; 8)altitude2; 9)computer date; 10)computer time.
%Example: HMag=gFMagyReadG88tvgMag('c:\temp\123.MAG',[0.010 -1.55 0.064255 -2.55; 0.010 -1.55 0.064255 -2.55]);

[fId, mes]=fopen(fName,'r');
if ~isempty(mes), error(['Error gFMagyReadG88Mag: ' mes]);end;
%S Mag Signal Depth Altitude DateM DateD DateY TimeH TimeM TimeS
C=textscan(fId,'%c%f%f%f%f%c%f%f%f%f%c%f%f%f%f%f%f','Delimiter',' :/,', 'MultipleDelimsAsOne',0,'EndOfLine','\r\n');fclose(fId);
if any(C{1}~='$'), error('Error gFMagyReadG88Mag: first symbol~=$');end;
if any(C{11}~=' '), error('Error gFMagyReadG88Mag: double space symbol not found');end;
if any(C{6}~=' '), error('Error gFMagyReadG88Mag: double space symbol not found');end;
HMag=struct('G88Koeff',K,'CompDay',datenum(C{14}+2000,C{12},C{13})','CompTime',...
    (C{15}.*3600+C{16}.*60+C{17})','MagAbsT',[C{2} C{7}]','MagPrecSignal',[C{3} C{8}]','Depth',[C{4}.*K(1,3)+K(1,4) C{9}.*K(2,3)+K(2,4)]','Altitude',[C{5}.*K(1,1)+K(1,2) C{10}.*K(2,1)+K(2,2)]');

%mail@ge0mlib.ru 09/02/2017