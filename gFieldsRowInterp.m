function gOu=gFieldsRowInterp(xIn,gIn,xOu,meth)
%Interpolate gIn-fields from xIn-time to xOu-time (used interp1); the function will be changed.
%function gOu=gZFieldsInterp(xIn,gIn,xOu,meth),
%xIn – time [Day Time] for GIn fields;
%xOu – new time [Day Time] for GIn fields, the GOu will be created;
%gIn - input data structure with fields;
%gOu - output data structure with interpolated fields;
%meth - interpolation method: 'linear','nearest','spline','pchip','cubic'.
%Fields: CompDay,CompTime,GpsDay,GpsTime,CompTimeLocShift,CompTimeShift,CompTimeDelta;
%Fields: GpsLat,GpsLon,GpsHgtGeoid,GpsAltSea,GpsEllipseParam,GpsProjName,GpsProjParam,GpsN,GpsE;
%Fields: GpsFixQuality,GpsSatNum,GpsHorizDilution,GpsStdA,GpsStdB,GpsStdC,GpsStdD,GpsStdE,GpsStdF,GpsStdG;
%Fields: GpsDgpsUpdate,GpsDgpsId;
%Fields: GpsTrueTrack,GpsMagTrack,GpsGroundSpeed,GpsHeading,GpsCalcHead,GpsCalcSpeed,GPSLever;
%Fields: MetaLever,MetaAltSea,TowPointLever;
%Fields: MotionLAX,MotionLAY,MotionLAZ,MotionLAH,MotionARX,MotionARY,MotionARZ,MotionRoll,MotionPitch,MotionHeave,MotionRemoteHeave,MotionF,MotionHeading,MotionHeadingF,MotionLever;
%Fields: CompassHead,CompassPitch,CompassRoll,AltEcho,AltTrack,DepthPress,MagyAbsT,MagyPrecSignal,MagyPrecLength,MagyF,CableLen,CableLever.
%Example: GpsOut=gFieldsRowInterp([GpsIn.CompDay;GpsIn.CompTime],GIn,[Sens.CompDay;Sens.CompTime],'linear');Sens=gZFieldsCombine(Sens,GpsOut); %interpolate Gps data to Sensor data.

if any(isnan(xIn(:))),error('Error gZFieldsInterp: xIn containe NaN value');end;
if any(isnan(xOu(:))),error('Error gZFieldsInterp: xOu containe NaN value');end;

a=round(mean(xOu(1,:)));
gInTime=(xIn(1,:)-a).*86400+xIn(2,:);
gOuTime=(xOu(1,:)-a).*86400+xOu(2,:);
%==============Gps
%--------------Gps Time
if isfield(gIn,'CompDay')&&isfield(gIn,'CompTime'),
    L=~isnan(gIn.CompDay);a=fix(mean(gIn.CompDay(L)));
    GInComp=(gIn.CompDay-a).*86400+gIn.CompTime;
    GOuComp=interp1(gInTime,GInComp,gOuTime,meth,'extrap');gOu.CompDay=fix(GOuComp./86400)+a;gOu.CompTime=mod(GOuComp,86400);
end;
if isfield(gIn,'GpsDay')&&isfield(gIn,'GpsTime'),
    L=~isnan(gIn.GpsDay);a=fix(mean(gIn.GpsDay(L)));
    GInGps=(gIn.GpsDay-a).*86400+gIn.GpsTime;
    GOuGps=interp1(gInTime,GInGps,gOuTime,meth,'extrap');gOu.GpsDay=fix(GOuGps./86400)+a;gOu.GpsTime=mod(GOuGps,86400);
end;
if isfield(gIn,'CompTimeLocShift'), gOu.CompTimeLocShift=gIn.CompTimeLocShift;end;
if isfield(gIn,'CompTimeShift')&&isfield(gIn,'CompTimeDelta'),
    [gOu.CompTimeDelta,gOu.CompTimeShift]=gLogGpsCompTimeDelta(gOu.CompDay,gOu.CompTime,gOu.GpsDay,gOu.GpsTime);
end;
%--------------Gps Coordinate
if isfield(gIn,'GpsLat'), gOu.GpsLat=interp1(gInTime,gIn.GpsLat,gOuTime,meth,'extrap');end;
if isfield(gIn,'GpsLon'), gOu.GpsLon=interp1(gInTime,gIn.GpsLon,gOuTime,meth,'extrap');end;
if isfield(gIn,'GpsHgtGeoid'), gOu.GpsHgtGeoid=interp1(gInTime,gIn.GpsHgtGeoid,gOuTime,meth,'extrap');end;
if isfield(gIn,'GpsAltSea'), gOu.GpsAltSea=interp1(gInTime,gIn.GpsAltSea,gOuTime,meth,'extrap');end;
if isfield(gIn,'GpsEllipseParam'), gOu.GpsEllipseParam=gIn.GpsEllipseParam;end;
if isfield(gIn,'GpsProjFuncName'), gOu.GpsProjFuncName=gIn.GpsProjFuncName;end;
if isfield(gIn,'GpsProjParam'), gOu.GpsProjParam=gIn.GpsProjParam;end;
if isfield(gIn,'GpsN'), gOu.GpsN=interp1(gInTime,gIn.GpsN,gOuTime,meth,'extrap');end;
if isfield(gIn,'GpsNS'), gOu.GpsNS=interp1(gInTime,gIn.GpsNS,gOuTime,meth,'extrap');end;%for delete
if isfield(gIn,'GpsE'), gOu.GpsE=interp1(gInTime,gIn.GpsE,gOuTime,meth,'extrap');end;
if isfield(gIn,'GpsES'), gOu.GpsES=interp1(gInTime,gIn.GpsES,gOuTime,meth,'extrap');end;%for delete
if isfield(gIn,'GpsH'), gOu.GpsH=interp1(gInTime,gIn.GpsH,gOuTime,meth,'extrap');end;
%--------------Gps Quality and Errors
if isfield(gIn,'GpsFixQuality'), gOu.GpsFixQuality=interp1(gInTime,gIn.GpsFixQuality,gOuTime,'previous','extrap');end;
if isfield(gIn,'GpsSatNum'), gOu.NSatNum=interp1(gInTime,gIn.GpsSatNum,gOuTime,'previous','extrap');end;
if isfield(gIn,'GpsHorizDilution'), gOu.GpsHorizDilution=interp1(gInTime,gIn.GpsHorizDilution,gOuTime,meth,'extrap');end;
if isfield(gIn,'GpsStdA'), gOu.GpsStdA=interp1(gInTime,gIn.GpsStdA,gOuTime,meth,'extrap');end;
if isfield(gIn,'GpsStdB'), gOu.GpsStdB=interp1(gInTime,gIn.GpsStdB,gOuTime,meth,'extrap');end;
if isfield(gIn,'GpsStdC'), gOu.GpsStdC=interp1(gInTime,gIn.GpsStdC,gOuTime,meth,'extrap');end;
if isfield(gIn,'GpsStdD'), gOu.GpsStdD=interp1(gInTime,gIn.GpsStdD,gOuTime,meth,'extrap');end;
if isfield(gIn,'GpsStdE'), gOu.GpsStdE=interp1(gInTime,gIn.GpsStdE,gOuTime,meth,'extrap');end;
if isfield(gIn,'GpsStdF'), gOu.GpsStdF=interp1(gInTime,gIn.GpsStdF,gOuTime,meth,'extrap');end;
if isfield(gIn,'GpsStdG'), gOu.GpsStdG=interp1(gInTime,gIn.GpsStdG,gOuTime,meth,'extrap');end;
%--------------Gps Dgps
if isfield(gIn,'GpsDgpsUpdate'), gOu.GpsDgpsUpdate=interp1(gInTime,gIn.GpsDgpsUpdate,gOuTime,meth,'extrap');end;
if isfield(gIn,'GpsDgpsId'), gOu.GpsDgpsId=interp1(gInTime,gIn.GpsDgpsId,gOuTime,'previous','extrap');end;
%--------------Gps Orientation and speed
if isfield(gIn,'GpsTrueTrack'), gOu.GpsTrueTrack=interp1(gInTime,gIn.GpsNTrueTrack,gOuTime,meth,'extrap');end;
if isfield(gIn,'GpsMagTrack'), gOu.GpsMagTrack=interp1(gInTime,gIn.GpsMagTrack,gOuTime,meth,'extrap');end;
if isfield(gIn,'GpsGroundSpeed'), gOu.GpsGroundSpeed=interp1(gInTime,gIn.GpsGroundSpeed,gOuTime,meth,'extrap');end;
if isfield(gIn,'GpsHeading'), gOu.GpsHeading=interp1(gInTime,gIn.GpsHeading,gOuTime,meth,'extrap');end;
%--------------Gps Lever
if isfield(gIn,'GPSLever'), gOu.GPSLever=gIn.GPSLever;end;
%==============CableCounter
if isfield(gIn,'CableLen'), gOu.CableLen=zeros(size(gIn.CableLen,1),length(gOuTime)); for n=1:size(gIn.CableLen,1);gOu.CableLen(n,:)=interp1(gInTime,gIn.CableLen(n,:),gOuTime,meth,'extrap');end;end;
if isfield(gIn,'CableLenS'), gOu.CableLen=interp1(gInTime,gIn.CableLenS,gOuTime,'previous','extrap');end;%for delete
if isfield(gIn,'CableLever'), gOu.MotionLever=gIn.CableLever;end;
%==============Towed fish with Position sensors output
if isfield(gIn,'CompassHead'), gOu.CompassHead=zeros(size(gIn.CompassHead,1),length(gOuTime)); for n=1:size(gIn.CompassHead,1);gOu.CompassHead(n,:)=interp1(gInTime,gIn.CompassHead(n,:),gOuTime,meth,'extrap');end;end;
if isfield(gIn,'CompassPitch'), gOu.CompassPitch=zeros(size(gIn.CompassPitch,1),length(gOuTime)); for n=1:size(gIn.CompassPitch,1);gOu.CompassPitch(n,:)=interp1(gInTime,gIn.CompassPitch(n,:),gOuTime,meth,'extrap');end;end;
if isfield(gIn,'CompassRoll'), gOu.CompassRoll=zeros(size(gIn.CompassRoll,1),length(gOuTime)); for n=1:size(gIn.CompassRoll,1);gOu.CompassRoll(n,:)=interp1(gInTime,gIn.CompassRoll(n,:),gOuTime,meth,'extrap');end;end;
if isfield(gIn,'Altitude'), gOu.Altitude=zeros(size(gIn.Altitude,1),length(gOuTime)); for n=1:size(gIn.Altitude,1);gOu.Altitude(n,:)=interp1(gInTime,gIn.Altitude(n,:),gOuTime,meth,'extrap');end;end;
if isfield(gIn,'AltitudeS'), gOu.AltitudeS=interp1(gInTime,gIn.AltitudeS,gOuTime,meth,'extrap');end;%for delete
if isfield(gIn,'Depth'), gOu.Depth=zeros(size(gIn.Depth,1),length(gOuTime)); for n=1:size(gIn.Depth,1);gOu.Depth(n,:)=interp1(gInTime,gIn.Depth(n,:),gOuTime,meth,'extrap');end;end;
if isfield(gIn,'DepthS'), gOu.DepthPressS=interp1(gInTime,gIn.DepthS,gOuTime,meth,'extrap');end;%for delete
if isfield(gIn,'GpsNL'), gOu.GpsNL=interp1(gInTime,gIn.GpsNL,gOuTime,meth,'extrap');end;%for delete
if isfield(gIn,'GpsEL'), gOu.GpsEL=interp1(gInTime,gIn.GpsEL,gOuTime,meth,'extrap');end;%for delete
%==============Magy sensor output
if isfield(gIn,'MagAbsT'), gOu.MagAbsT=zeros(size(gIn.MagAbsT,1),length(gOuTime)); for n=1:size(gIn.MagAbsT,1);gOu.MagAbsT(n,:)=interp1(gInTime,gIn.MagAbsT(n,:),gOuTime,meth,'extrap');end;end;
if isfield(gIn,'MagAbsTRaw'), for n=1:size(gIn.MagAbsTRaw,1);gOu.MagAbsTRaw(n,:)=interp1(gInTime,gIn.MagAbsTRaw(n,:),gOuTime,meth,'extrap');end;end;%for delete
if isfield(gIn,'MagAbsTS'), for n=1:size(gIn.MagAbsTS,1);gOu.MagAbsTS(n,:)=interp1(gInTime,gIn.MagAbsTS(n,:),gOuTime,meth,'extrap');end;end;%for delete
if isfield(gIn,'MagAbsTSMask'), gOu.MagAbsTSMask=zeros(size(gIn.MagAbsTSMask,1),length(gOuTime)); for n=1:size(gIn.MagAbsTSMask,1);gOu.MagAbsTSMask(n,:)=interp1(gInTime,double(gIn.MagAbsTSMask(n,:)),gOuTime,'previous','extrap');end;end;
if isfield(gIn,'MagPrecSignal'), gOu.MagPrecSignal=zeros(size(gIn.MagPrecSignal,1),length(gOuTime)); for n=1:size(gIn.MagPrecSignal,1);gOu.MagPrecSignal(n,:)=interp1(gInTime,gIn.MagPrecSignal(n,:),gOuTime,'previous','extrap');end;end;
if isfield(gIn,'MagPrecLength'), gOu.MagPrecLength=zeros(size(gIn.MagPrecLength,1),length(gOuTime)); for n=1:size(gIn.MagPrecLength,1);gOu.MagPrecLength(n,:)=interp1(gInTime,gIn.MagPrecLength(n,:),gOuTime,'previous','extrap');end;end;
if isfield(gIn,'MagF'),
    if all(ischar(gIn.MagF(:))), gOu.MagF=char(interp1(gInTime,double(gIn.MagF),gOuTime,'previous','extrap'));
    else gOu.MagF=zeros(size(gIn.MagF,1),length(gOuTime)); for n=1:size(gIn.MagF,1);gOu.MagF(n,:)=interp1(gInTime,gIn.MagF(n,:),gOuTime,'previous','extrap');end;end;
end;


%--------------Moution/Heave Sensor (IMU)
if isfield(gIn,'MotionLAX'), gOu.MotionLAX=interp1(gInTime,gIn.MotionLAX,gOuTime,meth,'extrap');end;
if isfield(gIn,'MotionLAY'), gOu.MotionLAY=interp1(gInTime,gIn.MotionLAY,gOuTime,meth,'extrap');end;
if isfield(gIn,'MotionLAZ'), gOu.MotionLAZ=interp1(gInTime,gIn.MotionLAZ,gOuTime,meth,'extrap');end;
if isfield(gIn,'MotionLAH'), gOu.MotionLAH=interp1(gInTime,gIn.MotionLAH,gOuTime,meth,'extrap');end;
if isfield(gIn,'MotionARX'), gOu.MotionARX=interp1(gInTime,gIn.MotionARX,gOuTime,meth,'extrap');end;
if isfield(gIn,'MotionARY'), gOu.MotionARY=interp1(gInTime,gIn.MotionARY,gOuTime,meth,'extrap');end;
if isfield(gIn,'MotionARZ'), gOu.MotionARZ=interp1(gInTime,gIn.MotionARZ,gOuTime,meth,'extrap');end;
if isfield(gIn,'MotionRoll'), gOu.MotionRoll=interp1(gInTime,gIn.MotionRoll,gOuTime,meth,'extrap');end;
if isfield(gIn,'MotionPitch'), gOu.MotionPitch=interp1(gInTime,gIn.MotionPitch,gOuTime,meth,'extrap');end;
if isfield(gIn,'MotionHeave'), gOu.MotionHeave=interp1(gInTime,gIn.MotionHeave,gOuTime,meth,'extrap');end;
if isfield(gIn,'MotionRemoteHeave'), gOu.MotionRemoteHeave=interp1(gInTime,gIn.MotionRemoteHeave,gOuTime,meth,'extrap');end;
if isfield(gIn,'MotionF'),
    if all(ischar(gIn.MotionF)), gOu.MotionF=char(interp1(gInTime,double(gIn.MotionF),gOuTime,'previous','extrap'));
    else gOu.MotionF=interp1(gInTime,gIn.MotionF,gOuTime,'previous','extrap');end;
end;
if isfield(gIn,'MotionHeading'), gOu.MotionHeading=interp1(gInTime,gIn.MotionHeading,gOuTime,meth,'extrap');end;
if isfield(gIn,'MotionHeadingF'),
    if all(ischar(gIn.MotionHeadingF)), gOu.MotionHeadingF=char(interp1(gInTime,double(gIn.MotionHeadingF),gOuTime,'previous','extrap'));
    else gOu.MotionHeadingF=interp1(gInTime,gIn.MotionHeadingF,gOuTime,'previous','extrap');end;
end;
if isfield(gIn,'HeaveLever'), gOu.HeaveLever=gIn.HeaveLever;end;
%--------------Gyrocompass
if isfield(gIn,'GyroTrueHeading'), gOu.GyroTrueHeading=interp1(gInTime,gIn.GyroTrueHeading,gOuTime,meth,'extrap');end;
if isfield(gIn,'GyroTrueHeadingF'),
    if all(ischar(gIn.GyroTrueHeadingF)), gOu.GyroTrueHeadingF=char(interp1(gInTime,double(gIn.GyroTrueHeadingF),gOuTime,'previous','extrap'));
    else gOu.GyroTrueHeadingF=interp1(gInTime,gIn.GyroTrueHeadingF,gOuTime,'previous','extrap');end;
end;
if isfield(gIn,'GyroTurnRate'), gOu.GyroTurnRate=interp1(gInTime,gIn.GyroTurnRate,gOuTime,meth,'extrap');end;
if isfield(gIn,'GyroTurnRateF'),
    if all(ischar(gIn.GyroTurnRateF)), gOu.GyroTurnRateF=char(interp1(gInTime,double(gIn.GyroTurnRateF),gOuTime,'previous','extrap'));
    else gOu.GyroTurnRateF=interp1(gInTime,gIn.GyroTurnRateF,gOuTime,'previous','extrap');end;
end;
%--------------TowPoint
if isfield(gIn,'TpN'), gOu.TpN=interp1(gInTime,gIn.TpN,gOuTime,meth,'extrap');end;
if isfield(gIn,'TpE'), gOu.TpE=interp1(gInTime,gIn.TpE,gOuTime,meth,'extrap');end;
if isfield(gIn,'TpHGps'), gOu.TpHGps=interp1(gInTime,gIn.TpHGps,gOuTime,meth,'extrap');end;
if isfield(gIn,'TpHMeta'), gOu.TpHMeta=interp1(gInTime,gIn.TpHMeta,gOuTime,meth,'extrap');end;
if isfield(gIn,'TpHeave'), gOu.TpHeave=interp1(gInTime,gIn.TpHeave,gOuTime,meth,'extrap');end;
if isfield(gIn,'TpMoveHead'), gOu.TpMoveHead=interp1(gInTime,gIn.TpMoveHead,gOuTime,meth,'extrap');end;
if isfield(gIn,'TpMoveSpeed'), gOu.TpMoveSpeed=interp1(gInTime,gIn.TpMoveSpeed,gOuTime,meth,'extrap');end;
%--------------Metacenter and LeverArm
if isfield(gIn,'MetaLever'), gOu.MetaLever=interp1(gInTime,gIn.MetaLever,gOuTime,meth,'extrap');end;
if isfield(gIn,'CogAltSea'), gOu.CogAltSea=interp1(gInTime,gIn.CogAltSea,gOuTime,meth,'extrap');end;
if isfield(gIn,'TowPointLever'), gOu.TowPointLever=gIn.TowPointLever;end;


%function yOu=gZIinterp1qR(xIn,yIn,xOu)
%Interpolate time series [xIn,yIn] to [xOu,yOu] using "value repeat" along time axis.
%function yOu=gZIinterp1qR(xIn,yIn,xOu), where
%xIn - input x-row (time) for interpolation;
%yIn - input y-row for interpolation;
%xOu - output x-row (time) for interpolation
%yOu - interpolated (repeated) y-row.
%Warning! For nan-value will be used "minimun distance" criteria for value repeating (time axis direction is not take into account).
%Example:yi=char(gZIinterp1qR([1 2 3 4 5 6 7 8],'aaaatttt',1:0.5:8));yi=[gZIinterp1qR([1 2 3 4 5 6 7 8],[1 1 4 4 4 4 6 6],1:0.5:8);1:0.5:8];

%x=[xIn;xIn];y=[yIn;yIn];x(1)=[];y(end)=[];
%yOu=(interp1q(x(:),y(:),xOu(:)))';
%N=find(isnan(yOu));
%if ~isempty(N),
%    for m=N', 
%        [~,L]=min(abs(x-xOu(m))); %!!!!!!!!!!!!!! abs
%        yOu(m)=y(L(1));
%    end;
%end;
%if all(ischar(yIn)), yOu=char(yOu);end;

%mail@ge0mlib.ru 01/08/2016