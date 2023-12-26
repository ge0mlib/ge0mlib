function Head=gSgyDTEN(Head,FieldKP,FieldX,FieldY,NavS,NavP,CoordinateUnits,SourceGroupScalar,varargin)
%Create Nav's fields GpsKP,GpsDay,GpsTime,GpsE,GpsN,GpsH from YearDataRecorded,DayOfYear,HourOfDay,MinuteOfHour,SecondOfMinute,SourceGroupScalar,CoordinateUnits,Head.SourceX,Head.SourceY.
%function Head=gSgyDTEN(Head,FieldKP,FieldX,FieldY,NavS,NavP,CoordinateUnits,SourceGroupScalar,varargin), where
%Head- input sgy's Header; need fields: YearDataRecorded,DayOfYear,HourOfDay,MinuteOfHour,SecondOfMinute,SourceGroupScalar,CoordinateUnits,FieldX,FieldY;
%FieldKP- the name of Kp-field; there are MessageNum,TraceSequenceLine,TraceSequenceFile,FieldRecord,EnergySourcePoint;
%FieldX,FieldY- the names of X and Y fields; there are SourceX, SourceY, GroupX, GroupY, cdpX, cdpY.
%NavS- sensor's Nav-structure (for segy-file);
%NavP- project's Nav-structure;
%CoordinateUnits- forced value for Head.CoordinateUnits field: 1-cartesian meters;2-geographic seconds;3-geographic degree;4-geographic DMS; 255-user defined in gSgyDTEN function;
%if isempty(CoordinateUnits), than CoordinateUnits=Head.CoordinateUnits(1);
%SourceGroupScalar- forced value for Head.SourceGroupScalar (-100,-10,-1,1,10,100,etc); if empty, than no forced changes;
%varargin=H- height in sensor's Nav-structure datum.
%Head- output sgy's Header; create fields: GpsDay,GpsTime,GpsE,GpsN,GpsH.
%Example: Head=gSgyDTEN(Head,'TraceSequenceLine','SourceX','SourceY',NavS,NavP,[],[],H);

if isempty(FieldKP), Head.GpsKP=1:length(Head.YearDataRecorded); else Head.GpsKP=Head.(FieldKP);end;%KP number
%Time Convert
Head.GpsDay=gNavTime2Time('YDy2Dx',Head.YearDataRecorded,Head.DayOfYear);
Head.GpsTime=gNavTime2Time('HMS32Sd',Head.HourOfDay,Head.MinuteOfHour,Head.SecondOfMinute);
[Head.GpsDay,Head.GpsTime]=gNavDayCheck(Head.GpsDay,Head.GpsTime);
%Nav convert
if ~all(Head.SourceGroupScalar==Head.SourceGroupScalar(1)),warning('~all(Head.SourceGroupScalar==Head.SourceGroupScalar(1)) for file!');end;
if ~isempty(SourceGroupScalar), Head.SourceGroupScalar(:)=SourceGroupScalar;end;
sc=abs(Head.SourceGroupScalar).^sign(Head.SourceGroupScalar);X=Head.(FieldX).*sc;Y=Head.(FieldY).*sc;%set scale to coordinate
if isempty(varargin),H=zeros(size(X));else H=varargin{1};end;
if ~all(Head.CoordinateUnits==Head.CoordinateUnits(1)),warning('~all(Head.CoordinateUnits==Head.CoordinateUnits(1)) for file!');end;
if isempty(CoordinateUnits), CoordinateUnits=Head.CoordinateUnits(1);else Head.CoordinateUnits(:)=CoordinateUnits;end;
if isempty(NavS)&&isempty(NavP),
    Head.GpsE=X;Head.GpsN=Y;Head.GpsH=H;
elseif CoordinateUnits==1,
    if NavS.TargCode~=1, warning('CoordinateUnits==1, but NavS.TargCode~=1');end;
    if any(Head.CoordinateUnits~=1), warning('CoordinateUnits==1, but any(Head.CoordinateUnits)~=1');end;
    [Head.GpsE,Head.GpsN,Head.GpsH]=gNavCoord2Coord(X,Y,H,NavS,NavP,[1 NavP.TargCode]);                                      %from cartesian meters
elseif CoordinateUnits==2,
    if NavS.TargCode~=2, warning('CoordinateUnits==2, but NavS.TargCode~=2');end;
    if any(Head.CoordinateUnits~=2), warning('CoordinateUnits==2, but any(Head.CoordinateUnits)~=2');end;
    [Head.GpsE,Head.GpsN,Head.GpsH]=gNavCoord2Coord(X./3600,Y./3600,H,NavS,NavP,[2 NavP.TargCode]);                          %from geographic seconds
elseif CoordinateUnits==3,
    if NavS.TargCode~=2, warning('CoordinateUnits==3, but NavS.TargCode~=2');end;
    if any(Head.CoordinateUnits~=3), warning('CoordinateUnits==3, but any(Head.CoordinateUnits)~=3');end;
    [Head.GpsE,Head.GpsN,Head.GpsH]=gNavCoord2Coord(X,Y,H,NavS,NavP,[2 NavP.TargCode]);                                      %from geographic degree
elseif CoordinateUnits==4,
    if NavS.TargCode~=2, warning('CoordinateUnits==4, but NavS.TargCode~=2');end;
    if any(Head.CoordinateUnits~=4), warning('CoordinateUnits==4, but any(Head.CoordinateUnits)~=4');end;
    [Head.GpsE,Head.GpsN,Head.GpsH]=gNavCoord2Coord(gNavAng2Ang('DMS2D',X),gNavAng2Ang('DMS2D',Y),H,NavS,NavP,[2 NavP.TargCode]);%from geographic DMS
elseif CoordinateUnits==255, %forced user defined DM >> DDDMM.MMM-->DD.DDDDD
    [Head.GpsE,Head.GpsN,Head.GpsH]=gNavCoord2Coord(gNavAng2Ang('DM2D',X),gNavAng2Ang('DM2D',Y),H,NavS,NavP,[2 NavP.TargCode]);%from geographic DM
else error('CoordinateUnits~=[1..4,255] for file.');
end;

%mail@ge0mlib.com 28/12/2020