function[XtfHead,Head,varargout]=gXtfDTENinv(XtfHead,Head,FieldKP,FieldX,FieldY,NavS,NavP,HNavUnitsForce)
%Use Nav's fields [GpsDay,GpsTime,GpsE,GpsN,GpsH,FieldKP] from Head's-Xtf-files-fields to calculate [(FieldX),(FieldY),HYear,HJulianDay,HHour,HMinute,HSecond,HHSeconds,(FieldKP)]
%function[XtfHead,Head,varargout]=gXtfDTENinv(XtfHead,Head,FieldKP,FieldX,FieldY,NavS,NavP,HNavUnitsForce), where
%[XtfHead,Head]- Xtf structure;
%FieldKP- the name of Kp-field; there are HMessageNum, HPingNumber
%FieldX,FieldY- the names of X and Y fields; there are Head.HShipYcoordinate,Head.HShipXcoordinate,Head.HSensorYcoordinate,Head.HSensorXcoordinate;
%NavS- Sensor's Nav-structure (for xtf-file);
%NavP- Project's Nav-structure;
%HNavUnitsForce- forced HNavUnits for XtfHead (if empty, than no forced changes);
%XtfHead- output XtfHead with updated XtfHead.HNavUnits;
%Head- output Header with updated fields [(FieldX),(FieldY),HYear,HJulianDay,HHour,HMinute,HSecond,HHSeconds,(FieldKP)];
%varargout=H- output height in Sensor's Nav-structure datum;
%Used functions: gNavTime2Time,gNavDayCheck,gNavCoord2Coord.
%Example: [XtfHead,Head]=gXtfDTENinv(XtfHead,Head,'HPingNumber','HShipYcoordinate',HShipXcoordinate',NavS,NavP,[]);

if ~isempty(FieldKP),Head.(FieldKP)=Head.GpsKP;end;%set new KP number
switch Head.HMessageType,
    case 000,
        %Time Convert
        [Head.HYear,Head.HJulianDay]=gNavTime2Time('Dx2YDy',Head.GpsDay); %Position Fix Day
        [Head.HHour,Head.HMinute,Head.HSecond]=gNavTime2Time('Sd2HMS3',Head.GpsTime); %Position Fix Time
        Head.HHSeconds=fix((Head.HSecond-fix(Head.HSecond)).*100);Head.HSecond=fix(Head.HSecond);
        [Head.HComputerClockHour,Head.HComputerClockMinute,Head.HComputerClockSecond]=gNavTime2Time('Sd2HMS3',Head.CompTime); %Position Fix Time
        Head.HComputerClockHsec=fix((Head.HComputerClockSecond-fix(Head.HComputerClockSecond)).*100);Head.HComputerClockSecond=fix(Head.HComputerClockSecond);
        %set HNavUnitsForce
        if ~isempty(HNavUnitsForce), XtfHead.HNavUnits=HNavUnitsForce;end;
        %Nav convert
        if isempty(NavS)&&isempty(NavP),
            Head.(FieldX)=Head.GpsE;Head.(FieldY)=Head.GpsN;H=Head.GpsH;
        elseif XtfHead.HNavUnits==0, %Coordinate Units: 0 = meters
            if NavS.TargCode~=1, warning('CoordinateUnits==0, but NavS.TargCode~=1');end;
            [Head.(FieldX),Head.(FieldY),H]=gNavCoord2Coord(Head.GpsE,Head.GpsN,Head.GpsH,NavS,NavP,[NavP.TargCode 1]);
        elseif XtfHead.HNavUnits==3, %Coordinate Units: 3 = geographic degree;
            if NavS.TargCode~=2, warning('CoordinateUnits==3, but NavS.TargCode~=2');end;
            [Head.(FieldX),Head.(FieldY),H]=gNavCoord2Coord(Head.GpsE,Head.GpsN,Head.GpsH,NavS,NavP,[NavP.TargCode 2]);
        elseif XtfHead.HNavUnits==255, %Coordinate Units: 255, forced user defined DDDMM.MMM
            [Head.(FieldX),Head.(FieldY),H]=gNavCoord2Coord(Head.GpsE,Head.GpsN,Head.GpsH,NavS,NavP,[NavP.TargCode 2]);
            Head.(FieldX)=gNAng2Ang('D2DM',Head.(FieldX));Head.(FieldY)=gNAng2Ang('D2DM',Head.(FieldY));
        else error('CoordinateUnits~=[0,3,255] for Message 000.');
        end;
        varargout{1}=H;
    otherwise, error('Head.HMessageType is not responce.');
end;

%mail@ge0mlib.com 01/01/2021
