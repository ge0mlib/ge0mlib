function [Head,varargout]=gJsfDTENinv(Head,FieldKP,NavS,NavP,CoordinateUnits)
%Use Nav's fields [GpsDay,GpsTime,GpsE,GpsN,GpsH,FieldKP] from Head's-Jsf-files-fields to calculate Jsf-files fields (different for Messages Types)
%function [Head,varargout]=gJsfDTENinv(Head,FieldKP,NavS,NavP,CoordinateUnits), where
%Head- Jsf Header;
%FieldKP- the name of Kp-field; there are 
%NavS- Sensor's Nav-structure;
%NavP- Project's Nav-structure;
%CoordinateUnits- forced value for Head.CoordinateUnits field: 1-cartesian meters;2-geographic seconds;3-geographic degree;4-geographic DMS;255-user defined in gJsfDTEN function;
%if isempty(CoordinateUnits) for HMessageType==0080, than CoordinateUnits=Head.CoordinateUnits(1) as a default;
%if isempty(CoordinateUnits) for HMessageType==0086, than "Latitude, Longitude in degrees" are used by default;
%Head- output Header renew fields MillisecondsToday,Year,Day,X,Y.
%varargout=H- output height in Sensor's Nav-structure datum;
%Used functions: gNavTime2Time,gNavDayCheck,gNavCoord2Coord.
%Example: [Head,H]=gJsfDTENinv(Head,'PingNumber',NavS,NavP,[]);

varargout{1}=[];
if ~isempty(FieldKP),Head.(FieldKP)=Head.GpsKP;end;%set new KP number
switch Head.HMessageType,
    case 0080,
        %Time Convert
        [Head.NmeaYear,Head.NmeaDay]=gNavTime2Time('Dx2YDy',Head.GpsDay); %Position Fix Day
        [Head.NmeaHour,Head.NmeaMinutes,Head.NmeaSeconds]=gNavTime2Time('Sd2HMS3',Head.GpsTime); %Position Fix Time
        [Head.Year,Head.Day]=gNavTime2Time('Dx2YDy',Head.CompDay); %Data Recorded Day
        Head.MillisecondsToday=round(Head.CompTime.*1000); %Data Recorded Time
        %Nav convert
        if isempty(CoordinateUnits), CoordinateUnits=Head.CoordinateUnits(1);else Head.CoordinateUnits(:)=CoordinateUnits;end;
        if isempty(NavS)&&isempty(NavP),
            Head.X=Head.GpsE;Head.Y=Head.GpsN;H=Head.GpsH;
        elseif CoordinateUnits==1,
            if NavS.TargCode~=1, warning('CoordinateUnits==1, but NavS.TargCode~=1');end;
            if any(Head.CoordinateUnits~=1), warning('CoordinateUnits==1, but any(Head.CoordinateUnits)~=1');end;
            [Head.X,Head.Y,H]=gNavCoord2Coord(Head.GpsE,Head.GpsN,Head.GpsH,NavS,NavP,[NavP.TargCode 1]);%1 = X,Y in millimeters;
            Head.X=round(Head.X.*1000);Head.Y=round(Head.Y.*1000);
        elseif CoordinateUnits==2,
            if NavS.TargCode~=2, warning('CoordinateUnits==2, but NavS.TargCode~=2');end;
            if any(Head.CoordinateUnits~=2), warning('CoordinateUnits==2, but any(Head.CoordinateUnits)~=2');end;
            [Head.X,Head.Y,H]=gNavCoord2Coord(Head.GpsE,Head.GpsN,Head.GpsH,NavS,NavP,[NavP.TargCode 2]);%2 = Longitude, Latitude in minutes of arc times 10000;
            Head.X=round(Head.X.*10000.*60);Head.Y=round(Head.Y.*10000.*60);
        elseif CoordinateUnits==3,
            if NavS.TargCode~=1, warning('CoordinateUnits==3, but NavS.TargCode~=1');end;
            if any(Head.CoordinateUnits~=3), warning('CoordinateUnits==3, but any(Head.CoordinateUnits)~=3');end;
            [Head.X,Head.Y,H]=gNavCoord2Coord(Head.GpsE,Head.GpsN,Head.GpsH,NavS,NavP,[NavP.TargCode 1]);%3 = X,Y in decimeters;
            Head.X=round(Head.X.*10);Head.Y=round(Head.Y.*10);
        elseif CoordinateUnits==255, %forced user defined DDDMM.MMM
            [Head.X,Head.Y,H]=gNavCoord2Coord(Head.GpsE,Head.GpsN,Head.GpsH,NavS,NavP,[2 NavP.TargCode]);%255 = Longitude, Latitude in DDDMM.MMM
            Head.X=round(gNavAng2Ang('D2DM',Head.X));Head.Y=round(gNavAng2Ang('D2DM',Head.Y));
        else error('CoordinateUnits~=[1..4,255] for for Message 0080.');
        end;
        varargout{1}=H;
    case 0082,
        [Head.Year,Head.Day]=gNavTime2Time('Dx2YDy',Head.CompDay); %Data Recorded Day
        Head.MillisecondsToday=round(Head.CompTime.*1000); %Data Recorded Time
    case 0086,
        [Head.Year,Head.Month,Head.Day]=gNavTime2Time('Dx2YMD3',Head.CompDay);
        [Head.Hour,Head.Minute, Head.Second]=gNavTime2Time('Sd2HMS3',Head.CompTime);
        if isempty(NavS)&&isempty(NavP), Head.Latitude=Head.GpsE;Head.Longitude=Head.GpsN;H=Head.GpsH;
        elseif isempty(CoordinateUnits),
            [Head.Latitude,Head.Longitude,H]=gNavCoord2Coord(Head.GpsE,Head.GpsN,Head.GpsH,NavS,NavP,[NavP.TargCode 2]); %Latitude, Longitude in degrees;
        elseif CoordinateUnits==255, %CoordinateUnits==255, forced user defined DDDMM.MMM
            [Head.Latitude,Head.Longitude,H]=gNavCoord2Coord(Head.GpsE,Head.GpsN,Head.GpsH,NavS,NavP,[2 NavP.TargCode]);%255 = Longitude, Latitude in DDDMM.MMM
            Head.Latitude=gNavAng2Ang('D2DM',Head.Latitude);Head.Longitude=gNavAng2Ang('D2DM',Head.Longitude);
        else error('CoordinateUnits~=[empty,255] for for Message 0086.');
        end;
        varargout{1}=H;
    case {0426,2000,2002,2020,2060,2080,2100,2101,2111}
        Head.TimeInSeconds=fix((Head.CompDay-datenum(1970,1,1)).*24.*3600+Head.CompTime); %Head.TimeInSeconds >> Time in seconds (since the start of time based on time() function) (1/1/1970)
        Head.MillisecondsCurrentSecond=round((Head.CompTime-fix(Head.CompTime)).*1000);
    case {2090,2091},
        Head.MicrosecondTimestamp=(Head.CompDay-datenum(1970,1,1)).*24.*3600.*1e7+Head.CompTime.*1e7; %Timestamp in the higher resolution format. This is equivalent to the Microsoft Dot Net DateTime. Ticks property. The resolution is 10-7 of a second (0.1 microsecond per increment), and is referenced to 12:00 midnight, Jan 1, 0001 C.E. in the Gregorian Calendar.
    case {3000,3001,3002,3003,3005}
        Head.TimeInSeconds=fix((Head.CompDay-datenum(1970,1,1)).*24.*3600+Head.CompTime);%Head.TimeInSeconds >> Time in seconds (since the start of time based on time() function) (1/1/1970)
        Head.NanosecondSupplementTime=round((Head.CompTime-fix(Head.CompTime)).*1e9);
    case 3004
        Head.TimeInSeconds=fix((Head.CompDay-datenum(1970,1,1)).*24.*3600+Head.CompTime);%Head.TimeInSeconds >> Time in seconds (since the start of time based on time() function) (1/1/1970)
        Head.NanosecondSupplementTime=round((Head.CompTime-fix(Head.CompTime)).*1e9);
        Head.Easting=Head.GpsE;
        Head.Northing=Head.GpsN;
    case {9001,9002,9003},
        Head.MicrosecondTimestamp=(Head.CompDay-datenum(1970,1,1)).*24.*3600.*1e7+Head.CompTime.*1e7; %Timestamp in the higher resolution DISCOVER II format. This is equivalent to the Microsoft Dot Net DateTime. Ticks property. The resolution is 10-7 of a second (0.1 microsecond per increment), and is referenced to 12:00 midnight, Jan 1, 0001 C.E. in the Gregorian Calendar.
    case {0182,0428,2040}, warning('There are no time or coordinates for current Message.');
    otherwise, error('Head.HMessageType is not responce.');
end;

%mail@ge0mlib.com 01/01/2021