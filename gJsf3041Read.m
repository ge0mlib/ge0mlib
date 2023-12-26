function Head=gJsf3041Read(JsfHead)
%Read Head from JsfHead.fName (*.jsf) file for Message Type 3041 (Bathymetric Parameter Public Message; 0023492_Rev_C used).
%function Head=gJsf3041Read(JsfHead), where
%JsfHead - Jsf Header structure;
%Head - Message Header structure.
%Head include the addition fields: HMessageType, HMessageNum.
%BathymetricParameterPublicMessageType reports bathymetric processing parameters.
%Example: Head=gJsf3041Read(JsfHead);

[fId, mes]=fopen(JsfHead.fName,'r');if ~isempty(mes), error(['gJsfRead3041: ' mes]);end;
LHead=(JsfHead.HMessageType==3041);LenHead=sum(LHead);nHead=find(LHead);
%===Begin Head Allocate for Message Type 3041
Head=struct('HMessageType',2071,'HMessageNum',zeros(1,LenHead),...
    'BathymetricProcessing',zeros(1,LenHead),'ProcessingFlags',zeros(1,LenHead),'InstallationAngle',zeros(2,LenHead),'MaximumProcessingRange',zeros(1,LenHead),'MinimumProcessingRange',zeros(1,LenHead),'MaximumAltitude',zeros(1,LenHead),'MinimumAltitude',zeros(1,LenHead),'ManualAltitude',zeros(1,LenHead),...
    'ArrayElements',zeros(2,LenHead),'MountingDirection',zeros(2,LenHead),'InstallationHorizontalOffset',zeros(2,LenHead),'AutoAmplitudeSensitivity',zeros(1,LenHead),'MultiPathSuppressionLevel',zeros(1,LenHead),'CovarianceMaxRegionSize',zeros(1,LenHead),...
    'AmplitudeThreshold',zeros(1,LenHead),'MinimumQualityFactor',zeros(1,LenHead),'MaximumOutputAngle',zeros(1,LenHead),'DecimationFactor',zeros(1,LenHead),'AltitudeDataSource',zeros(1,LenHead),'TVG',zeros(1,LenHead),'MaxTVG',zeros(1,LenHead),'SNRThreshold',zeros(1,LenHead));
%===End Head Allocate for Message Type 3041
df=0;
for m=1:LenHead,
    %===Begin Head Read for Message Type 3041
    fseek(fId,JsfHead.RSeek(nHead(m))-df,'cof');
    Head.HMessageNum(m)=nHead(m);
    Head.BathymetricProcessing(m)=fread(fId,1,'uint16'); %0-1// Bathymetric Processing: 0=Off; 1=Stave’s Original Algorithm; 2=Faster Algorithm
    Head.ProcessingFlags(m)=fread(fId,1,'uint16'); %2-3// Processing Flags: Bit0=Invert Heave Sign; Bit1=Reserved; Bit2=Reserved; Bit3=Ignore NMEA time (0:NMEA time, 1:Ignore NMEA time); Bit4=Altitude method (0:track bottom, 1:manual); Bit5=Auto amplitude (0:disable, 1:enable)
    Head.InstallationAngle(2,m)=fread(fId,2,'float32'); %4-11// Installation Angle Degrees: Byte4–7=Port installation angle; Byte8-11=Starboard installation angle
    Head.MaximumProcessingRange(m)=fread(fId,1,'float32'); %12-15// Maximum Processing Range (0 – 350), Meters
    Head.MinimumProcessingRange(m)=fread(fId,1,'float32'); %16-19// Minimum Processing Range (0 – 100), Meters
    Head.MaximumAltitude(m)=fread(fId,1,'float32'); %20-23// Maximum Altitude (0 – 350), Meters
    Head.MinimumAltitude(m)=fread(fId,1,'float32'); %24-27// Minimum Altitude (0 – 100), Meters
    Head.ManualAltitude(m)=fread(fId,1,'float32'); %28-31// Manual Altitude, Meters
    Head.ArrayElements(2,m)=fread(fId,2,'uint8'); %32-33// Array Elements: Byte32=Number of port array elements; Byte33=Number of starboard elements 
    Head.MountingDirection(2,m)=fread(fId,2,'uint8'); %34-35// Mounting Direction: Byte34=Mounting direction of the port array; Byte35=Mounting direction of starboard array
    Head.InstallationHorizontalOffset(2,m)=fread(fId,2,'float32'); %36-43// Installation Horizontal Offset, Meter: Byte36-39=Port array [0.0-10.0]; Byte40-43=Starboard array [0.0-10.0]
    Head.AutoAmplitudeSensitivity(m)=fread(fId,1,'float32'); %44-47// Auto Amplitude Sensitivity, Threshold [0.5-5.0]
    Head.MultiPathSuppressionLevel(m)=fread(fId,1,'uint32'); %48-51// Multi-Path Suppression Level, Suppression Level: 1,3 & 5
    Head.CovarianceMaxRegionSize(m)=fread(fId,1,'float32'); %52-55// Covariance Max Region Size, Meter, Max size [0.0-10.0] 
    Head.AmplitudeThreshold(m)=fread(fId,1,'uint32'); %56-59// Amplitude Threshold, Rang: [0-1000]
    Head.MinimumQualityFactor(m)=fread(fId,1,'float32'); %60-63// Minimum Quality Factor, Range: [0.0–1.0]
    Head.MaximumOutputAngle(m)=fread(fId,1,'float32'); %64-67// Maximum Output Angle, Degree, Range: [0.0–120.0]
    Head.DecimationFactor(m)=fread(fId,1,'uint32'); %68-71// Decimation Factor, Range: [1–100]
    Head.AltitudeDataSource(m)=fread(fId,1,'uint8'); %72// Altitude Data Source: 0=Array selector port; 1=Array selector starboard; 3=Array selector sum; 4=Array selector product; 5=Array selector minimum
    Head.TVG(m)=fread(fId,1,'uint8'); %73// TVG
    Head.MaxTVG(m)=fread(fId,1,'uint8'); %74// Max TVG
    Head.SNRThreshold(m)=fread(fId,1,'uint8'); %75// SNR Threshold, Range: [0-40] dB
    %===End Head Read for Message Type 3041
    df=ftell(fId);
end;
fclose(fId);

%mail@ge0mlib.com 08/04/2021