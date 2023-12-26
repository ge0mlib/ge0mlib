function U=gSssSWizTargRead(fName,cD)
%Read target file exported from SonarWiz7
%function U=gSssSWizTargRead(fName), where
%fName- reading file name with SonarWiz targets;
%cD- delimiter used;
%Example:
%U=gSssSWizTargRead('d:\SSS\Block52_20221115_rev9S.csv',',');

if ~strcmp(fName(end-3:end),'.db3'),
    fId=fopen(fName,'r');C=textscan(fId,'%s',1,'Delimiter','','MultipleDelimsAsOne',0,'EndOfLine','\r\n');
    tmp=['TargetName' cD 'CaptureDateTimeLocal' cD 'CaptureDateTimeUTC' cD 'SonarDateTime' cD 'ClickLat' cD 'ClickLon' cD 'ClickX' cD 'ClickY' cD 'FishHeight' cD 'FishCmg' cD 'PingNumber' cD 'NadirDistanceFromLeftEdge' cD 'RangeAtLeftEdge' cD 'RangeAtRightEdge' cD 'SonarRange' cD 'RangeToTarget' cD 'PortOrStarboard' cD 'TargetOnPortSide' cD 'TargetSpansChannels' cD 'SamplesPerChan' cD 'CSFFile' cD 'CsfTargetRow' cD 'FirstCsfRow' cD 'LastCsfRow' cD 'OriginalAcousticFile' cD 'MapImageName' cD 'MapProjection' cD 'ImageUnits' cD 'ImageHeightMeters' cD 'ImageWidthMeters' cD 'ImageHeightPixels' cD 'ImageWidthPixels' cD 'TopLeftLat' cD 'TopLeftLon' cD 'BotLeftLat' cD 'BotLeftLon' cD 'UserClass1' cD 'UserClass2' cD 'Description' cD 'MeasuredHeight' cD 'MeasuredLength' cD 'MeasuredShadow' cD 'MeasuredScour' cD 'MeasuredWidth' cD 'EventNumber' cD 'LineName' cD 'DisplayYN' cD 'ContactVersion' cD 'SoftwareVersion' cD 'PositioningSystemToSensor' cD 'AvoidanceArea' cD 'LocationArea' cD 'LocationBlock' cD 'MagAnomaly' cD 'MeasuredDepthBelowSeafloor'];
    if ~strcmp(C{1},tmp),warning('The first string is not SonarWiz targetlist format.');end;
    %1-TargetName(vchar50) -- SSS_W52_0001s
    %2-8-CaptureDateTimeLocal(timestamp), 9-14-CaptureDateTimeUTC(timestamp), 15-20-SonarDateTime(timestamp) -- 2022-11-15T13:12:56+0000,2022-11-15T13:12:56Z,2022-11-14T14:28:16.298
    %21-ClickLat(float),22-ClickLon(float),23-ClickX(float),24-ClickY(float) -- 53.7091263,4.819100371,620156.9115,5952908.233
    %25-FishHeight(float),26-FishCmg(float),27-PingNumber(integer),28-NadirDistanceFromLeftEdge(float),29-RangeAtLeftEdge(float),30-RangeAtRightEdge(float),31-SonarRange(float),32-RangeToTarget(float) -- 11.00072126,0,937157,0,0,74.74942648,0,45.37733807
    %33-PortOrStarboard(vchar8) -- Stbd
    %34-TargetOnPortSide(logical),35-TargetSpansChannels(logical),36-SamplesPerChan(integer) -- 0,0,0
    %37-CSFFile(vchar64),38-CsfTargetRow(integer),39-FirstCsfRow(integer),40-LastCsfRow(integer) -- D:\$$NL5025H-657_Wintershall-PINS 2022\01_SSS\NL5025H-657_Wintershall_W52_HF\CSF\Added_from_Boxin_L6-B\0251-W52B-U_jsf-CH34.CSF,1020,923,1117
    %41-OriginalAcousticFile(vchar256) -- D:\$$NL5025H-657_Wintershall-PINS 2022\01_SSS\NL5025H-657_Wintershall_L6-B_HF\SSS\Nav_Inject_JSF\0251-W52B-U.jsf
    %42-MapImageName(vchar256) -- D:\$$NL5025H-657_Wintershall-PINS 2022\01_SSS\NL5025H-657_Wintershall_W52_HF\targets\SSS_W52_0001s.JPG
    %43-MapProjection(vchar32),44-ImageUnits(vchar16),45-ImageHeightMeters(float),46-ImageWidthMeters(float),47-ImageHeightPixels(integer),48-ImageWidthPixels(integer),49-TopLeftLat(float),50-TopLeftLon(float),51-BotLeftLat(float),52-BotLeftLon(float) -- ED50-UTM31,Meters,75.00215157,74.74942648,2145,2145,53.70884342,4.819837238,53.70863541,4.818756721
    %53-UserClass1(vchar64),54-UserClass2(vchar64),55-Description(vchar128) -- C1,C2,Dump
    %56-MeasuredHeight(float),57-MeasuredLength(float),58-MeasuredShadow(float),59-MeasuredScour(float),60-MeasuredWidth(float),61-EventNumber(float) -- 0,0,0,0,0,0
    %62-LineName(vchar64),63-DisplayYN(logical),64-ContactVersion(integer),65-SoftwareVersion(vchar64) -- 0251-W52B-U,1,3,SonarWiz 7 V7.09.02
    %66-PositioningSystemToSensor(???),67-AvoidanceArea(vchar32),68-LocationArea(vchar32),69-LocationBlock(vchar32),70-MagAnomaly(vchar32),71-MeasuredDepthBelowSeafloor(float) -- 0,A1,LA1,LB1,Mag1,0
    %                1  2  3  4  5  6  7  8  9 10  11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33  34  35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62  63 64 65 66 67 68 69 70 71
    C=textscan(fId,'%s %d-%d-%dT%d:%d:%f+%d %d-%d-%dT%d:%d:%dZ %d-%d-%dT%d:%d:%f %f %f %f %f %f %f %d %f %f %f %f %f %s %u8 %u8 %d %s %d %d %d %s %s %s %s %f %f %d %d %f %f %f %f %s %s %s %f %f %f %f %f %f %s %u8 %d %s %f %s %s %s %s %f','Delimiter',cD,'MultipleDelimsAsOne',0,'EndOfLine','\r\n');fclose(fId);
    U=struct('TargetName',{C{1}'},'CaptureDateTimeLocalY',C{2}','CaptureDateTimeLocalM',C{3}','CaptureDateTimeLocalD',C{4}','CaptureDateTimeLocalHH',C{5}','CaptureDateTimeLocalMM',C{6}','CaptureDateTimeLocalSS',C{7}','CaptureDateTimeLocalDS',C{8}',...
        'CaptureDateTimeUTCY',C{9}','CaptureDateTimeUTCM',C{10}','CaptureDateTimeUTCD',C{11}','CaptureDateTimeUTCHH',C{12}','CaptureDateTimeUTCMM',C{13}','CaptureDateTimeUTCSS',C{14}','SonarDateTimeY',C{15}','SonarDateTimeM',C{16}','SonarDateTimeD',C{17}','SonarDateTimeHH',C{18}','SonarDateTimeMM',C{19}','SonarDateTimeSS',C{20}',...
        'GpsLat',C{21}','GpsLon',C{22}','GpsE',C{23}','GpsN',C{24}','FishHeight',C{25}','FishCmg',C{26}','PingNumber',C{27}','NadirDistanceFromLeftEdge',C{28}','RangeAtLeftEdge',C{29}','RangeAtRightEdge',C{30}','SonarRange',C{31}','RangeToTarget',C{32}',...
        'PortOrStarboard',{C{33}'},'TargetOnPortSide',logical(C{34})','TargetSpansChannels',logical(C{35})','SamplesPerChan',C{36}','CSFFile',{C{37}'},'CsfTargetRow',C{38}','FirstCsfRow',C{39}','LastCsfRow',C{40}','OriginalAcousticFile',{C{41}'}',...
        'MapImageName',{C{42}'},'MapProjection',{C{43}'},'ImageUnits',{C{44}'},'ImageHeightMeters',C{45}','ImageWidthMeters',C{46}','ImageHeightPixels',C{47}','ImageWidthPixels',C{48}','TopLeftLat',C{49}','TopLeftLon',C{50}','BotLeftLat',C{51}','BotLeftLon',C{52}',...
        'UserClass1',{C{53}'},'UserClass2',{C{54}'},'Description',{C{55}'},'MeasuredHeight',C{56}','MeasuredLength',C{57}','MeasuredShadow',C{58}','MeasuredScour',C{59}','MeasuredWidth',C{60}','EventNumber',C{61}',...
        'LineName',{C{62}'},'DisplayYN',logical(C{63})','ContactVersion',C{64}','SoftwareVersion',{C{65}'},'PositioningSystemToSensor',C{66}','AvoidanceArea',{C{67}'},'LocationArea',{C{68}'},'LocationBlock',{C{69}'},'MagAnomaly',{C{70}'},'MeasuredDepthBelowSeafloor',C{71}');
else
    mksqlite('open',fName);C=mksqlite('SELECT * FROM ContactData');mksqlite('close');
    L=numel([C.ID]);
    cc=[reshape([C.CaptureDTLocal],24,L);repmat(',',1,L);reshape([C.CaptureDTUTC],20,L);repmat(',',1,L);reshape([C.SonarDateTime],23,L);repmat(char(10),1,L)];c=textscan(cc(:)','%d-%d-%dT%d:%d:%f+%d %d-%d-%dT%d:%d:%dZ %d-%d-%dT%d:%d:%f','Delimiter',cD,'MultipleDelimsAsOne',0);
    U=struct('TargetName',{{C.Name}},'CaptureDateTimeLocalY',c{1}','CaptureDateTimeLocalM',c{2}','CaptureDateTimeLocalD',c{3}','CaptureDateTimeLocalHH',c{4}','CaptureDateTimeLocalMM',c{5}','CaptureDateTimeLocalSS',c{6}','CaptureDateTimeLocalDS',c{7}',...
        'CaptureDateTimeUTCY',c{8}','CaptureDateTimeUTCM',c{9}','CaptureDateTimeUTCD',c{10}','CaptureDateTimeUTCHH',c{11}','CaptureDateTimeUTCMM',c{12}','CaptureDateTimeUTCSS',c{13}','SonarDateTimeY',c{14}','SonarDateTimeM',c{15}','SonarDateTimeD',c{16}','SonarDateTimeHH',c{17}','SonarDateTimeMM',c{18}','SonarDateTimeSS',c{19}',...
        'GpsLat',[C.ClickLat],'GpsLon',[C.ClickLon],'GpsE',[C.ClickX],'GpsN',[C.ClickY],'FishHeight',[C.FishHeight],'FishCmg',[C.FishCmg],'PingNumber',[C.PingNumber],'NadirDistanceFromLeftEdge',[C.NadirDistanceFromLeftEdge],'RangeAtLeftEdge',[C.RangeAtLeftEdge],'RangeAtRightEdge',[C.RangeAtRightEdge],'SonarRange',[C.SonarRange],'RangeToTarget',[C.RangeToTarget],...
        'PortOrStarboard',{{C.PortOrStarboard}},'TargetOnPortSide',logical([C.TargetOnPortSide]),'TargetSpansChannels',logical([C.TargetSpansChannels]),'SamplesPerChan',[C.SamplesPerChan],'CSFFile',{{C.CSFFilename}},'CsfTargetRow',[C.CsfTargetRow],'FirstCsfRow',[C.FirstCsfRow],'LastCsfRow',[C.LastCsfRow],'OriginalAcousticFile',{{C.OriginalAcousticFile}},...
        'MapImageName',{{C.MapImageName}},'MapProjection',{{C.MapProjection}},'ImageUnits',{{C.ImageUnits}},'ImageHeightMeters',[C.ImageHeightMeters],'ImageWidthMeters',[C.ImageWidthMeters],'ImageHeightPixels',[C.ImageHeightInPixels],'ImageWidthPixels',[C.ImageWidthInPixels],'TopLeftLat',[C.TopLeftLat],'TopLeftLon',[C.TopLeftLon],'BotLeftLat',[C.BotLeftLat],'BotLeftLon',[C.BotLeftLon],...
        'UserClass1',{{C.UserClass1}},'UserClass2',{{C.UserClass2}},'Description',{{C.Description}},'MeasuredHeight',[C.MeasuredHeight],'MeasuredLength',[C.MeasuredLength],'MeasuredShadow',[C.MeasuredShadow],'MeasuredScour',[C.MeasuredScour],'MeasuredWidth',[C.MeasuredWidth],'EventNumber',[C.EventNumber],...
        'LineName',{{C.LineName}},'DisplayYN',logical([C.displayYN]),'ContactVersion',[C.ContactVersion],'SoftwareVersion',{{C.SoftwareVersion}},'PositioningSystemToSensor',[C.distance_ship_to_fish],'AvoidanceArea',{{C.AvoidanceArea}},'LocationArea',{{C.LocationArea}},'LocationBlock',{{C.LocationBlock}},'MagAnomaly',{{C.MagAnomaly}},'MeasuredDepthBelowSeafloor',[C.MeasuredDepthBelowSeafloor]);
    %CSFFile
    %z=mksqlite('SELECT name FROM sqlite_master WHERE type=''table'';'); %>> get table list
    %z=mksqlite('UPDATE ContactData SET Name=''Hello World'' WHERE ID=3'); %>> set to table==ContactData, where value in column ID==3, data in column Name=Hello World
end;

%mail@ge0mlib.com 19/11/2022