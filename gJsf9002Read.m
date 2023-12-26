function Head=gJsf9002Read(JsfHead)
%Read Head from JsfHead.fName (*.jsf) file for Message Type 9002 (DISCOVER II Situation Data Message; 0004824_REV_1.18 used). Warning: NOT TESTED.
%function Head=gJsf9002Read(JsfHead), where
%JsfHead - Jsf Header structure;
%Head - Message Header structure.
%Head include the addition fields: HMessageType,HMessageNum.
%A typical towed system often contains two Sensor Platforms - a boat doing the towing and towed sonar. This message is a summary of the "situation data" for a sensor platform.
%This data is written for every defined sensor platform, normally at a 5Hz rate. A sensor platform may contain multiple sensors that provide the same type of data (e.g. Lat/Lon from RMC and GGL).
%In this case, the configuration of the run time system contains a prioritized list situation data sources, and it only reports the highest priority available source data.
%Example: Head=gJsf9002Read(JsfHead);

[fId, mes]=fopen(JsfHead.fName,'r');if ~isempty(mes), error(['gJsfRead9002: ' mes]);end;
LHead=(JsfHead.HMessageType==9002);LenHead=sum(LHead);nHead=find(LHead);
%===Begin Head Allocate for Message Type 9002
Sit=struct('SituationIdCode',0,'SizeEntry',0,'DerivationSource',0,'DerivationFlags',0,'DataFormatCode',0,'Data',[]);
Head=struct('HMessageType',9002,'HMessageNum',zeros(1,LenHead),'Timestamp',zeros(1,LenHead),'DataSourceSerialNumber',zeros(1,LenHead),'MessageVersionNumber',zeros(4,LenHead),'DataSourceDevice',zeros(1,LenHead),...
    'GuidPlatform',zeros(16,LenHead),'SensorPlatformType',zeros(1,LenHead),'PlatformEnumerator',zeros(1,LenHead),'NumberSituationIds',zeros(1,LenHead),'Situation',repmat(Sit,1,LenHead));
%===End Head Allocate for Message Type 9002
df=0;
for m=1:LenHead,
    %===Begin Head Read for Message Type 9002
    fseek(fId,JsfHead.RSeek(nHead(m))-df,'cof');
    Head.HMessageNum(m)=nHead(m);
    Head.Timestamp(m)=fread(fId,1,'int64'); %0-7// Timestamp in the higher resolution DISCOVER II format. This is equivalent to the Microsoft Dot Net DateTime. Ticks property. The resolution is 10^-7 of a second (0.1 microsecond per increment), and is referenced to 12:00 midnight, Jan 1, 0001 C.E. in the Gregorian Calendar.
    Head.DataSourceSerialNumber(m)=fread(fId,1,'int32'); %8-11// Data Source Serial Number. A unique serial number, which could for example distinguish one tow fish from another, otherwise identically configured tow fish.
    Head.MessageVersionNumber(m)=fread(fId,1,'int16'); %12-13// Message Version Number. This is the version number of this message. This number may differ from the protocol version number in the main message header.
    Head.DataSourceDevice(m)=fread(fId,1,'int16'); %14-15// Data Source Device. For each Serial Number, there may be multiple devices.
    Head.GuidPlatform(:,m)=fread(fId,16,'uint8'); %16-31// GUID of platform. This is a unique value used to represent the source sensor platform. When DISCOVER II is configured and sensor platforms are defined the GUID is generated.
    Head.SensorPlatformType(m)=fread(fId,1,'uint16'); %32-33// Sensor Platform Type: 0=Boat; 1=Towed Sensor Platform (towfish).
    Head.PlatformEnumerator(m)=fread(fId,1,'uint16'); %34-35// Platform enumerator (1..N).
    Head.NumberSituationIds(m)=fread(fId,1,'uint32'); %36-39// Number of Situation IDs Present in the List to follow.
    for mm=1:Head.NumberSituationIds(m),
        Head.Situation(m).SituationIdCode(mm)=fread(fId,1,'uint16'); %0-1// Situation ID Code.
        %0=Altitude - in Meters; 1=Cable Angle - in Degrees; 2=Cable Out - in Meters; 3=Cable Tension - in TBD Units; 4=Cable Velocity - in Meters/Second; 5=Course - in Degrees (0 to 360);
        %6=Depth - in Meters; 7=Heading - in Degrees (0 to 360); 8=Heave - in Meters; 9=Ice Draft - in Meters; 10=KP - Kilometer Point; 11=Layback - in Meters;12=Navigation Position - units Vary;
        %13=Pitch - in Degrees (-180 to 180); 14=Pressure - in PSI Absolute; 15=Roll - in Degrees (-180 to 180); 16=Salinity in PPM; 17=Sediment Sound Speed 1 - Meters/Second;
        %18=Sediment Sound Speed 2 - Meters/Second; 19=Speed - Meters/Second; 20=Water Sound Speed - Meters/Second; 21=Water Temperature - in Degrees C; 22=Clearance;
        %23=Velocity X Meters/Second; 24=Velocity Y Meters/Second; 25=Velocity Z Meters/Second; 26=Yaw; 27=Reflection Coefficient; 28=Northing/Easting Position; 29=Heave Compensated Depth;
        %Others may be added in the future. 
        Head.Situation(m).SizeEntry(mm)=fread(fId,1,'uint8'); %2// Size of entry in bytes. This allows the skipping of unsupported types. To go from one list item to the next, add the size in bytes to the reference point.
        Head.Situation(m).DerivationSource(mm)=fread(fId,1,'uint8'); %3// Derivation Source: 0=Unknown - There is no data available; 2=Un-interpolated - Most recent value used; 3=Interpolated for the specified timestamp time.
        if Head.Situation(m).DerivationSource(mm)==0, %Derivation Source is 0
            Head.Situation(m).DerivationFlags(mm)=nan;Head.Situation(m).DataFormatCode(mm)=nan;Head.Situation(m).Data{mm}=[];
        else %Derivation Source is ~0
            Head.Situation(m).DerivationFlags(mm)=fread(fId,1,'uint16'); %4-5// Derivation Flags: Only present if the Derivation Source is 2 or 3.
            %These are hints of how the value was derived. An example is if water temperature or salinity were not available in calculating depth from pressure (and therefore, the nominal value for these was used). The state flag bit definitions will vary with the situation ID, and are presently TBD.
            Head.Situation(m).DataFormatCode(mm)=fread(fId,1,'uint16'); %6-7// Data format code: Only present if the Derivation Source is 2 or 3.
            switch Head.Situation(m).DataFormatCode(mm), %The data format codes are as follows:
                case 1, Head.Situation(m).Data{mm}=fread(fId,1,'float64'); %8-15// 1=Double - An 8 byte double precision float follows;
                case 2, Head.Situation(m).Data{mm}=fread(fId,1,'float32'); %8-11// 2=Float - A 4 byte single precision float follows;
                case 3, Head.Situation(m).Data{mm}=fread(fId,2,'float64'); %8-23// 3=Lat Lon - What follows are 2 values: Longitude is 8 byte double precision float - Degrees, Longitude is 8 byte double precision float - Degrees;
                case 4, Head.Situation(m).Data{mm}=fread(fId,2,'float64'); %8-23// 4=X Y - What follows are 2 values: X is 8 byte double precision float - Meters, Y is 8 byte double precision float - Meters;
                case 5, Head.Situation(m).Data{mm}=[fread(fId,2,'float64') fread(fId,2,'int32')]; %8-27// 5= Northing Easting Position - What follows are 3 values: Northing is 8 byte double precision float - Meters, Easting is 8 byte double precision float - Meters, Zone is 4 byte integer representing the UTM Zone;
                case 6, Head.Situation(m).Data{mm}=fread(fId,3,'float64'); %8-31// 6= XYZ - What follows are 3 values: X is 8 byte double precision float - Meters, Y is 8 byte double precision float - Meters, Z is 8 byte double precision float - Meters;
                case 7, Head.Situation(m).Data{mm}=fread(fId,2,'float64'); %8-23// 7= Range and Bearing - What follows are 2 values: Range is 8 byte double precision float - Meters, Bearing is 8 byte double precision float - Degrees.
                otherwise, sz=Head.Situation(m).SizeEntry(mm)-8; Head.Situation(m).Data{mm}=fread(fId,sz,'uint8'); %8-end// xx= Number of bytes.
            end;
        end;
    end;
    %===End Head Read for Message Type 9002
    df=ftell(fId);
end;
fclose(fId);

%mail@ge0mlib.com 19/03/2018