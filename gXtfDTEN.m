function Head=gXtfDTEN(XtfHead,Head,FieldKP,FieldX,FieldY,NavS,NavP,HNavUnitsForce,varargin)
%Create Nav's fields GpsDay,GpsTime,GpsE,GpsN,GpsH from Xtf-files fields (different for Messages Types)
%function Head=gXtfDTEN(XtfHead,Head,FieldKP,FieldX,FieldY,NavS,NavP,HNavUnitsForce,varargin), where
%[XtfHead,Head]- Xtf structure;
%FieldKP- the name of Kp-field; there are HMessageNum, HPingNumber
%FieldX,FieldY- the names of X and Y fields; there are Head.HShipYcoordinate,Head.HShipXcoordinate,Head.HSensorYcoordinate,Head.HSensorXcoordinate;
%NavS- Sensor's Nav-structure (for xtf-file);
%NavP- Project's Nav-structure;
%HNavUnitsForce- forced HNavUnits for XtfHead: 0-meters; 3-geographic degree; 5-user defined in gXtfDTEN function; if empty, than no forced changes;
%varargin{1}=H- height in Sensor's Nav-structure datum;
%Head- output Header with fields: GpsDay,GpsTime,GpsE,GpsN,GpsH.
%Used functions: gNavTime2Time,gNavDayCheck,gNavCoord2Coord.
%Example: Head=gXtfDTEN(XtfHead,Head,'HPingNumber','HShipYcoordinate','HShipXcoordinate',NavS,NavP,[],H);

switch Head.HMessageType,
    case 000,
        if isempty(varargin),H=zeros(size(Head.HYear));else H=varargin{1};end; if numel(H)==1,H=repmat(H,size(Head.HYear));end;
        if isempty(FieldKP), Head.GpsKP=1:length(Head.HYear); else Head.GpsKP=Head.(FieldKP);end;%KP number
        %Time Convert
        Head.GpsDay=gNavTime2Time('YDy2Dx',Head.HYear,Head.HJulianDay); %Position Fix Day
        Head.GpsTime=gNavTime2Time('HMS32Sd',Head.HHour,Head.HMinute,Head.HSecond+Head.HHSeconds/100); %Position Fix Time
        [Head.GpsDay,Head.GpsTime]=gNavDayCheck(Head.GpsDay,Head.GpsTime);
        Head.CompTime=gNavTime2Time('HMS32Sd',Head.HComputerClockHour,Head.HComputerClockMinute,Head.HComputerClockSecond+Head.HComputerClockHsec/100); %Data Recorded Time
        %set HNavUnitsForce
        if isempty(HNavUnitsForce), HNavUnitsForce=XtfHead.HNavUnits;else XtfHead.HNavUnits=HNavUnitsForce;end;
        %Nav convert
        if isempty(NavS)&&isempty(NavP),
            Head.GpsE=Head.(FieldX);Head.GpsN=Head.(FieldY);Head.GpsH=H;
        elseif HNavUnitsForce==0, %Coordinate Units:
            if NavS.TargCode~=1, warning('CoordinateUnits==0, but NavS.TargCode~=1');end;
            [Head.GpsE,Head.GpsN,Head.GpsH]=gNavCoord2Coord(Head.(FieldX),Head.(FieldY),zeros(size(Head.(FieldX))),NavS,NavP,[1 NavP.TargCode]);%0 = meters
        elseif HNavUnitsForce==3,
            if NavS.TargCode~=2, warning('CoordinateUnits==3, but NavS.TargCode~=2');end;
            [Head.GpsE,Head.GpsN,Head.GpsH]=gNavCoord2Coord(Head.(FieldX),Head.(FieldY),zeros(size(Head.(FieldX))),NavS,NavP,[2 NavP.TargCode]);%3 = geographic degree;
        elseif HNavUnitsForce==255, %forced user defined DM >> DDDMM.MMM-->DD.DDDDD
            if NavS.TargCode~=2, warning('CoordinateUnits==255, but NavS.TargCode~=2');end;
            [Head.GpsE,Head.GpsN,Head.GpsH]=gNavCoord2Coord(gNavAng2Ang('DM2D',Head.(FieldX)),gNavAng2Ang('DM2D',Head.(FieldY)),zeros(size(Head.(FieldX))),NavS,NavP,[2 NavP.TargCode]);%3 = geographic degree;
        else error('CoordinateUnits~=[0,3,255] for Message 000.');
        end;
    otherwise, error('Head.HMessageType is not responce.');
end;

%mail@ge0mlib.com 28/12/2020