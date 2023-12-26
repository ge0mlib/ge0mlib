function HMag=gMagyReadG88Mag(fName,K)
%Read data from text file with was created MagLog Geometrics program for G882 single magnetometer (*.MAG)
%function HMag=gMagyReadG88Mag(fName,K), where
%fName - reading file name;
%K - Altimeter and Depth sensor coefficients: [AltScale AltBias DepthScale DepthBias]; if no sensor, than Scale and Bias set to nan
%HMag - data structure with reading fields: G88Koeff, CompDay, CompTime, MagAbsT, MagPrecSignal, Depth, Altitude
%*.MAG file format example:
%$ 56637.438,1204,0139,0659  06/07/14 08:43:13.359
%$ 56637.529,1208,0139,0640  06/07/14 08:43:13.468
%Mag file columns: 1)total magnetic field; 2)signal; 3)depth; 4)altitude; 5)computer date; 6)computer time.
%Example: HMag=gMagyReadG88Mag('c:\temp\123.MAG',[0.010 -1.55 0.064255 -2.55]);

[fId, mes]=fopen(fName,'r');
if ~isempty(mes), error(['Error gMagyReadG88Mag: ' mes]);end;
if ~isnan(K(1))&&(~isnan(K(3))), %Alt and Depth
    %S Mag Signal Depth Altitude DateM DateD DateY TimeH TimeM TimeS
    C=textscan(fId,'%c%f%f%f%f%c%f%f%f%f%f%f','Delimiter',' :/,', 'MultipleDelimsAsOne',0,'EndOfLine','\r\n');fclose(fId);
    if any(C{1}~='$'), error('Error gMagyReadG88Mag: first symbol~=$');end;
    if any(C{6}~=' '), error('Error gMagyReadG88Mag: double space symbol not found');end;
    HMag=struct('G88Koeff',K,'CompDay',datenum(C{9}+2000,C{7},C{8})','CompTime',(C{10}.*3600+C{11}.*60+C{12})','MagAbsT',C{2}','MagPrecSignal',C{3}','Depth',(C{4}.*K(3)+K(4))','Altitude',(C{5}.*K(1)+K(2))');
elseif ~isnan(K(1))&&(isnan(K(3))), %Alt and no Depth
    %S Mag Signal Altitude DateM DateD DateY TimeH TimeM TimeS
    C=textscan(fId,'%c%f%f%f%c%f%f%f%f%f%f','Delimiter',' :/,', 'MultipleDelimsAsOne',0,'EndOfLine','\r\n');fclose(fId);
    if any(C{1}~='$'), error('Error gMagyReadG88Mag: first symbol~=$');end;
    if any(C{5}~=' '), error('Error gMagyReadG88Mag: double space symbol not found');end;
    HMag=struct('G88Koeff',K,'CompDay',datenum(C{8}+2000,C{6},C{7})','CompTime',(C{9}.*3600+C{10}.*60+C{11})','MagAbsT',C{2}','MagPrecSignal',C{3}','Depth',C{3}'+nan,'Altitude',(C{4}.*K(1)+K(2))');
elseif ~isnan(K(1))&&(isnan(K(3))), %no Alt and Depth
    %S Mag Signal Depth DateM DateD DateY TimeH TimeM TimeS
    C=textscan(fId,'%c%f%f%f%c%f%f%f%f%f%f','Delimiter',' :/,', 'MultipleDelimsAsOne',0,'EndOfLine','\r\n');fclose(fId);
    if any(C{1}~='$'), error('Error gMagyReadG88Mag: first symbol~=$');end;
    if any(C{5}~=' '), error('Error gMagyReadG88Mag: double space symbol not found');end;
    HMag=struct('G88Koeff',K,'CompDay',datenum(C{8}+2000,C{6},C{7})','CompTime',(C{9}.*3600+C{10}.*60+C{11})','MagAbsT',C{2}','MagPrecSignal',C{3}','Depth',(C{4}.*K(3)+K(4))','Altitude',C{3}'+nan);
elseif isnan(K(1))&&(isnan(K(3))), %no Alt and no Depth
    %S Mag Signal DateM DateD DateY TimeH TimeM TimeS
    C=textscan(fId,'%c%f%f%c%f%f%f%f%f%f','Delimiter',' :/,', 'MultipleDelimsAsOne',0,'EndOfLine','\r\n');fclose(fId);
    if any(C{1}~='$'), error('Error gMagyReadG88Mag: first symbol~=$');end;
    if any(C{4}~=' '), error('Error gMagyReadG88Mag: double space symbol not found');end;
    HMag=struct('G88Koeff',K,'CompDay',datenum(C{7}+2000,C{5},C{6})','CompTime',(C{8}.*3600+C{9}.*60+C{10})','MagAbsT',C{2}','MagPrecSignal',C{3}','Depth',C{3}'+nan,'Altitude',C{3}'+nan);
end;

%mail@ge0mlib.com 15/07/2020