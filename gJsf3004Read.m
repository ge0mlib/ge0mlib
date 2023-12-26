function Head=gJsf3004Read(JsfHead)
%Read Head from JsfHead.fName (*.jsf) file for Message Type 3004 (Position Message Type ; 0014932_REV_D March 2016 used).
%function Head=gJsf3004Read(JsfHead), where
%JsfHead - Jsf Header structure;
%Head - Message Header structure.
%Head include the addition fields: HMessageType, HMessageNum.
%PositionMessageType is a source for position (latitude/longitude), heading, speed, and antenna altitude. UTM Zone, Easting, and Northing fields are not typically used.
%Example: Head=gJsf3004Read(JsfHead);

[fId, mes]=fopen(JsfHead.fName,'r');if ~isempty(mes), error(['gJsfRead3004: ' mes]);end;
LHead=(JsfHead.HMessageType==3004);LenHead=sum(LHead);nHead=find(LHead);
%===Begin Head Allocate for Message Type 3004
Head=struct('HMessageType',3004,'HMessageNum',zeros(1,LenHead),...
    'TimeInSeconds',zeros(1,LenHead),'NanosecondSupplementTime',zeros(1,LenHead),'DataValidFlag',zeros(1,LenHead),...
    'UtmZone',zeros(1,LenHead),'Easting',zeros(1,LenHead),'Northing',zeros(1,LenHead),'Latitude',zeros(1,LenHead),'Longitude',zeros(1,LenHead),...
    'Speed',zeros(1,LenHead),'Heading',zeros(1,LenHead),'AntennaHeight',zeros(1,LenHead));
%===End Head Allocate for Message Type 3004
df=0;
for m=1:LenHead,
    %===Begin Head Read for Message Type 3004
    fseek(fId,JsfHead.RSeek(nHead(m))-df,'cof');
    Head.HMessageNum(m)=nHead(m);
    Head.TimeInSeconds(m)=fread(fId,1,'uint32'); %0-3// Time in seconds (since the start of time based on time() function) (1/1/1970)
    Head.NanosecondSupplementTime(m)=fread(fId,1,'uint32'); %4-7// Nanosecond Supplement to Time; The time stamp accuracy is 20 (?) milliseconds or better.
    Head.DataValidFlag(m)=fread(fId,1,'uint16'); %8-9// Data Valid Flag: Bit0-UTM Zone; Bit1-Easting; Bit2-Northing; Bit3-Latitude; Bit4-Longitude; Bit5-Speed; Bit6-Heading; Bit7-Antenna Height. 0 is clear, 1 is set. The validity of each field is indicated in the Data Valid Flag (bytes 8-11) and it is imperative that this is used to correctly parse the fields.
    %If a GPS device is connected and it is a dual antenna system supplying heading, then the Heading field (bytes 48-51) is also valid (or set to 1).
    Head.UtmZone(m)=fread(fId,1,'uint16'); %10-11// UTM Zone.
    Head.Easting(m)=fread(fId,1,'float64'); %12-19// Easting, Meters.
    Head.Northing(m)=fread(fId,1,'float64'); %20-27// Northing, Meters.
    Head.Latitude(m)=fread(fId,1,'float64'); %28-35// Latitude, Degrees, positive North.
    Head.Longitude(m)=fread(fId,1,'float64'); %36-43// Longitude, Degrees, positive East.
    Head.Speed(m)=fread(fId,1,'float32'); %44-47// Speed, Knots.
    Head.Heading(m)=fread(fId,1,'float32'); %48-51// Heading (0 to 359.9), Degrees, always positive.
    Head.AntennaHeight(m)=fread(fId,1,'float32'); %52-55// Antenna Height, Meters, positive up. Antenna Height, or ellipsoid height, (bytes 52-55) may or may not be populated and depends on the GPS device connected.
    %===End Head Read for Message Type 3004
    df=ftell(fId);
end;
fclose(fId);

%mail@ge0mlib.com 19/03/2018