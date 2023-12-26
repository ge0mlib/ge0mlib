function [Head,varargout]=gSgyDTENinv(Head,FieldKP,FieldX,FieldY,NavS,NavP,CoordinateUnits,SourceGroupScalar)
%Re-calculate Sgy-fields YearDataRecorded,DayOfYear,HourOfDay,MinuteOfHour,SecondOfMinute,SourceGroupScalar,CoordinateUnits,Head.SourceX,Head.SourceY using GpsDay,GpsTime,GpsE,GpsN,GpsH.
%function [Head,varargout]=gSgyDTENinv(Head,FieldX,FieldY,NavS,NavP,CoordinateUnits,SourceGroupScalar), where
%Head- input sgy's Header; need fields: GpsDay,GpsTime,GpsE,GpsN,GpsH;
%FieldKP- the name of Kp-field; there are MessageNum,TraceSequenceLine,TraceSequenceFile,FieldRecord,EnergySourcePoint;
%FieldX,FieldY- the names of X and Y fields; there are SourceX, SourceY, GroupX, GroupY, cdpX, cdpY.
%NavS- sensor's Nav-structure (for sgy-file);
%NavP- project's Nav-structure;
%CoordinateUnits- forced value for Head.CoordinateUnits field: 1-cartesian meters;2-geographic seconds;3-geographic degree;4-geographic DMS; if empty, than Head.CoordinateUnits(:)=Head.CoordinateUnits(1);
%SourceGroupScalar- forced value for Head.SourceGroupScalar (-100,-10,-1,1,10,100,etc); if empty, than no forced changes;
%Head- output sgy's Header; create fields: YearDataRecorded,DayOfYear,HourOfDay,MinuteOfHour,SecondOfMinute,SourceGroupScalar,CoordinateUnits,Head.SourceX,Head.SourceY.
%varargout=H- height in sensor's Nav-structure datum.
%Example: Head=gSgyDTENinv(Head,'TraceSequenceFile','SourceX','SourceY',NavS,NavP,2,-100);

if ~isempty(FieldKP),Head.(FieldKP)=Head.GpsKP;end;%KP number
%Time Convert
[Head.YearDataRecorded,Head.DayOfYear]=gNavTime2Time('Dx2YDy',Head.GpsDay);
[Head.HourOfDay,Head.MinuteOfHour,Head.SecondOfMinute]=gNavTime2Time('Sd2HMS3',Head.GpsTime);
%Nav convert
if ~all(Head.CoordinateUnits==Head.CoordinateUnits(1)),warning('~all(Head.CoordinateUnits==Head.CoordinateUnits(1)) for file!');end;
if isempty(CoordinateUnits), CoordinateUnits=Head.CoordinateUnits(1);else Head.CoordinateUnits(:)=CoordinateUnits;end;
if isempty(NavS)&&isempty(NavP),
    X=Head.GpsE;Y=Head.GpsN;H=Head.GpsH;
elseif CoordinateUnits==1,
    if NavS.TargCode~=1, warning('CoordinateUnits==1, but NavS.TargCode~=1');end;
    [X,Y,H]=gNavCoord2Coord(Head.GpsE,Head.GpsN,Head.GpsH,NavS,NavP,[NavP.TargCode 1]);                                              %from cartesian meters
elseif CoordinateUnits==2,
    if NavS.TargCode~=2, warning('CoordinateUnits==2, but NavS.TargCode~=2');end;
    [X,Y,H]=gNavCoord2Coord(Head.GpsE,Head.GpsN,Head.GpsH,NavS,NavP,[NavP.TargCode 2]);X=X*3600;Y=Y*3600;                            %from geographic seconds
elseif CoordinateUnits==3,
    if NavS.TargCode~=2, warning('CoordinateUnits==3, but NavS.TargCode~=2');end;
    [X,Y,H]=gNavCoord2Coord(Head.GpsE,Head.GpsN,Head.GpsH,NavS,NavP,[NavP.TargCode 2]);                                              %from geographic degree
elseif CoordinateUnits==4,
    if NavS.TargCode~=2, warning('CoordinateUnits==4, but NavS.TargCode~=2');end;
    [X,Y,H]=gNavCoord2Coord(Head.GpsE,Head.GpsN,Head.GpsH,NavS,NavP,[NavP.TargCode 2]);X=gNAng2Ang('D2DMS',X);Y=gNAng2Ang('D2DMS',Y);%from geographic DMS
elseif CoordinateUnits==255, %forced user defined DM >> DDDMM.MMM-->DD.DDDDD
    [X,Y,H]=gNavCoord2Coord(Head.GpsE,Head.GpsN,Head.GpsH,NavS,NavP,[NavP.TargCode 2]);X=gNAng2Ang('D2DM',X);Y=gNAng2Ang('D2DM',Y);%from geographic DM
else error('CoordinateUnits~=[1..4,255] for file.');
end;
if ~all(Head.SourceGroupScalar==Head.SourceGroupScalar(1)),warning('~all(Head.SourceGroupScalar==Head.SourceGroupScalar(1)) for file!');end;
if ~isempty(SourceGroupScalar), Head.SourceGroupScalar(:)=SourceGroupScalar;end;
sc=abs(SourceGroupScalar).^sign(SourceGroupScalar);
Head.(FieldX)=X./sc;Head.(FieldY)=Y./sc; %set scale to coordinate
varargout{1}=H;

%mail@ge0mlib.com 01/01/2021