function Head=gJsfDTEN(Head,FieldKP,NavS,NavP,CoordinateUnits,varargin)
%Create Nav's fields GpsDay,GpsTime,GpsE,GpsN,GpsH from Jsf-files fields (different for Messages Types)
%function Head=gJsfDTEN(Head,FieldKP,NavS,NavP,CoordinateUnits,varargin), where
%Head- Jsf Header;
%FieldKP- the name of Kp-field; there are 
%NavS- Sensor's Nav-structure;
%NavP- Project's Nav-structure;
%CoordinateUnits- forced value for Head.CoordinateUnits field: 1-cartesian meters;2-geographic seconds;3-geographic degree;4-geographic DMS;255-user defined in gJsfDTEN function;
%if isempty(CoordinateUnits) for HMessageType==0080, than CoordinateUnits=Head.CoordinateUnits(1) as a default;
%if isempty(CoordinateUnits) for HMessageType==0086, than "Latitude, Longitude in degrees" are used by default;
%varargin=H- height in Sensor's Nav-structure datum;
%Head- output Header fields: GpsDay,GpsTime,GpsE,GpsN,GpsH will created using fields MillisecondsToday,Year,Day,X,Y.
%Used functions: gNavTime2Time,gNavDayCheck,gNavCoord2Coord.
%Example: Head=gJsfDTEN(Head,'PingNumber',NavS,NavP,[],H);

if isempty(varargin),H=zeros(size(Head.NmeaYear));else H=varargin{1};end; if numel(H)==1,H=repmat(H,size(Head.NmeaYear));end;
if isempty(FieldKP), Head.GpsKP=1:length(Head.NmeaYear); else Head.GpsKP=Head.(FieldKP);end;%KP number
switch Head.HMessageType,
    case 0080,
        %Time Convert
        Head.GpsDay=gNavTime2Time('YDy2Dx',Head.NmeaYear,Head.NmeaDay); %Position Fix Day
        Head.GpsTime=gNavTime2Time('HMS32Sd',Head.NmeaHour,Head.NmeaMinutes,Head.NmeaSeconds); %Position Fix Time
        [Head.GpsDay,Head.GpsTime]=gNavDayCheck(Head.GpsDay,Head.GpsTime);
        Head.CompDay=gNavTime2Time('YDy2Dx',Head.Year,Head.Day); %Data Recorded Day
        Head.CompTime=Head.MillisecondsToday./1000; %Data Recorded Time
        %Nav convert
        if isempty(CoordinateUnits), CoordinateUnits=Head.CoordinateUnits(1);else Head.CoordinateUnits(:)=CoordinateUnits;end;
        if isempty(NavS)&&isempty(NavP),
            Head.GpsE=Head.X;Head.GpsN=Head.Y;Head.GpsH=H;
        elseif CoordinateUnits==1,
            if NavS.TargCode~=1, warning('CoordinateUnits==1, but NavS.TargCode~=1');end;
            if any(Head.CoordinateUnits~=1), warning('CoordinateUnits==1, but any(Head.CoordinateUnits)~=1');end;
            [Head.GpsE,Head.GpsN,Head.GpsH]=gNavCoord2Coord(Head.X./1000,Head.Y./1000,H,NavS,NavP,[1 NavP.TargCode]);%1 = X,Y in millimeters;
        elseif CoordinateUnits==2,
            if NavS.TargCode~=2, warning('CoordinateUnits==2, but NavS.TargCode~=2');end;
            if any(Head.CoordinateUnits~=2), warning('CoordinateUnits==2, but any(Head.CoordinateUnits)~=2');end;
            [Head.GpsE,Head.GpsN,Head.GpsH]=gNavCoord2Coord(Head.Y./60./10000,Head.X./60./10000,H,NavS,NavP,[2 NavP.TargCode]);%2 = Longitude, Latitude in minutes of arc times 10000;
        elseif CoordinateUnits==3,
            if NavS.TargCode~=3, warning('CoordinateUnits==3, but NavS.TargCode~=3');end;
            if any(Head.CoordinateUnits~=3), warning('CoordinateUnits==3, but any(Head.CoordinateUnits)~=3');end;
            [Head.GpsE,Head.GpsN,Head.GpsH]=gNavCoord2Coord(Head.X./10,Head.Y./10,H,NavS,NavP,[1 NavP.TargCode]);%3 = X,Y in decimeters;
        elseif CoordinateUnits==255, %forced user defined DM >> DDDMM.MMM-->DD.DDDDD
            [Head.GpsE,Head.GpsN,Head.GpsH]=gNavCoord2Coord(gNavAng2Ang('DM2D',Head.X),gNavAng2Ang('DM2D',Head.Y),H,NavS,NavP,[2 NavP.TargCode]);%255 = Longitude, Latitude in DDDMM.MMM
        else error('CoordinateUnits~=[1..4,255] for for Message 0080.');
        end;
    case 0082,
        Head.CompDay=gNavTime2Time('YDy2Dx',Head.Year,Head.Day); %Data Recorded Day
        Head.CompTime=Head.MillisecondsToday./1000; %Data Recorded Time
    case 0086,
        Head.CompDay=gNavTime2Time('YMD32Dx',Head.Year,Head.Month,Head.Day);
        Head.CompTime=gNavTime2Time('HMS32Sd',Head.Hour,Head.Minute, Head.Second);
        if isempty(NavS)&&isempty(NavP), Head.GpsE=Head.Latitude;Head.GpsN=Head.Longitude;Head.GpsH=H;
        elseif isempty(CoordinateUnits),
            [Head.GpsE,Head.GpsN,Head.GpsH]=gNavCoord2Coord(Head.Latitude,Head.Longitude,H,NavS,NavP,[2 NavP.TargCode]); %Latitude, Longitude in degrees;
        elseif CoordinateUnits==255, %CoordinateUnits==255, forced user defined DM >> DDDMM.MMM-->DD.DDDDD
            [Head.GpsE,Head.GpsN,Head.GpsH]=gNavCoord2Coord(gNavAng2Ang('DM2D',Head.Latitude),gNavAng2Ang('DM2D',Head.Longitude),H,NavS,NavP,[2 NavP.TargCode]);%255 = Longitude, Latitude in DDDMM.MMM
        else error('CoordinateUnits~=[empty,255] for for Message 0086.');
        end;
    case {0426,2000,2002,2020,2060,2080,2100,2101,2111}
        Head.CompDay=fix(Head.TimeInSeconds./3600./24)+datenum(1970,1,1); %Head.TimeInSeconds >> Time in seconds (since the start of time based on time() function) (1/1/1970)
        Head.CompTime=Head.TimeInSeconds-fix(Head.TimeInSeconds./3600./24).*3600.*24+Head.MillisecondsCurrentSecond./1000;
    case {2090,2091},
        Head.CompDay=fix(Head.MicrosecondTimestamp./1e7./3600./24)+datenum(1970,1,1); %Timestamp in the higher resolution format. This is equivalent to the Microsoft Dot Net DateTime. Ticks property. The resolution is 10-7 of a second (0.1 microsecond per increment), and is referenced to 12:00 midnight, Jan 1, 0001 C.E. in the Gregorian Calendar.
        Head.CompTime=Head.MicrosecondTimestamp./1e7-fix(Head.MicrosecondTimestamp./1e7./3600./24).*3600.*24;
    case {3000,3001,3002,3003,3005}
        Head.CompDay=fix(Head.TimeInSeconds./3600./24)+datenum(1970,1,1); %Head.TimeInSeconds >> Time in seconds (since the start of time based on time() function) (1/1/1970)
        Head.CompTime=Head.TimeInSeconds-fix(Head.TimeInSeconds./3600./24).*3600.*24+Head.NanosecondSupplementTime./1e9;
    case 3004
        Head.CompDay=fix(Head.TimeInSeconds./3600./24)+datenum(1970,1,1); %Head.TimeInSeconds >> Time in seconds (since the start of time based on time() function) (1/1/1970)
        Head.CompTime=Head.TimeInSeconds-fix(Head.TimeInSeconds./3600./24).*3600.*24+Head.NanosecondSupplementTime./1e9;
        Head.GpsE=Head.Easting;Head.GpsN=Head.Northing;
    case {9001,9002,9003},
        Head.CompDay=fix(Head.MicrosecondTimestamp./1e7./3600./24)+datenum(1970,1,1); %Timestamp in the higher resolution DISCOVER II format. This is equivalent to the Microsoft Dot Net DateTime. Ticks property. The resolution is 10-7 of a second (0.1 microsecond per increment), and is referenced to 12:00 midnight, Jan 1, 0001 C.E. in the Gregorian Calendar.
        Head.CompTime=Head.MicrosecondTimestamp./1e7-fix(Head.MicrosecondTimestamp./1e7./3600./24).*3600.*24;
    case {0182,0428,2040}, warning('There are no time or coordinates for current Message.');
    otherwise, error('Head.HMessageType is not responce.');
end;

%mail@ge0mlib.com 28/12/2020