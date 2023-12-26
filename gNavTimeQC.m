function [PRfnm,ProcLog]=gNavTimeQC(PRfnm,PRLLog,gKey)
%"Script's command function" used for QC-mask creation, spikes handle deleting, Time smooth and de-repeat. Reasonable to use for data with "approximately constant" time-step measurements.
%function [PRfnm,ProcLog]=gNavTimeQC(PRfnm,PRLLog,gKey), where
%PRfnm - is the survey line's sensor PR{n}.(fnm), which includes '..Day' and '..Time' fields;
%PRLLog - the information about survey line PR{n}.LLog, which includes 'LName' field;
%gKey - the input command parameters:
%gKey{1} - comn='Time_QC'  script's command key or same;
%gKey{2} - nn              survey lines numbers for time's handle de-spike and smooth (outside from gNavTimeQC);
%gKey{3} - fnm             sensor name will used for PR (outside from gNavTimeQC);
%gKey{4} - fnpt            prefix for '..Day' and '..Time' fields; usually 'Comp' or 'Gps';
%gKey{5} - TimeSmooth      window for smooth(...,'loess');
%gKey{6} - BitQD=1        bit-mask for Handle-despike for "Time's diff calculated";
%gKey{7} - BitQRep=2      bit-mask for RepeatTime, used with bitand(...); not processed if empty;
%gKey{8} - BitQL=4        bit-mask for Handle-despike for "Time's linear trend removed";
%gKey{9} - BitQReset=4    bit-mask for previous QC-mask reset;
%PRfnm - output sensor's data with fields 'QMask', [fnpt 'DayRaw'], [fnpt 'TimeRaw'] and processed fields [fnpt 'Day'],[fnpt 'Time'];
%ProcLog - string for add to processing log.
%Example:
%{'Time_QC','StTp','Gps',1,1:3};gUhrGeoEelGeomR02;
%where gUhrGeoEelGeomR02 command script is:
%if strcmp(gKey{1},'Time_QC'),
%    for n=gKey{2}, [PR{n}.(gKey{3}),ProcLog]=gNavTimeQC(PR{n}.(gKey{3}),PR{n}.LLog,gKey);PR{n}.ProcLog=[PR{n}.ProcLog ProcLog];end; %PRfnm=PR{n}.(gKey{3});PRLLog=PR{n}.LLog;
%    clearvars n ProcLog;
%end;
    
fnpt=gKey{4}; %get preffix for '..Day' and '..Time' fields
if numel(gKey)>5,BitQD=gKey{6};else BitQD=1;end; %bit-mask for Handle-despike for "Time's diff calculated"; no result if 0
if numel(gKey)>6,BitQRep=gKey{7};else BitQRep=2;end; %bit-mask for RepeatTime, used with bitand(...); no result if 0
if numel(gKey)>7,BitQL=gKey{8};else BitQL=4;end; %bit-mask for Handle-despike for "Time's linear trend removed"; no result if 0
if numel(gKey)>8,BitQReset=gKey{9};else BitQReset=1+2;end; %bit-mask for previous QC-mask reset
if ~isfield(PRfnm,'QMask'), PRfnm.QMask=uint8(zeros(size(PRfnm.([fnpt 'Day']))));end; %create QMask
if ~isfield(PRfnm,[fnpt 'DayRaw']),PRfnm.([fnpt 'DayRaw'])=PRfnm.([fnpt 'Day']);end; if ~isfield(PRfnm,[fnpt 'TimeRaw']),PRfnm.([fnpt 'TimeRaw'])=PRfnm.([fnpt 'Time']);end; %create Raw-fields with Day and Time
PRfnm.QMask=bitand(PRfnm.QMask,255-BitQReset); %reset defined previous QMask bits
PRfnm.([fnpt 'Day'])=PRfnm.([fnpt 'DayRaw']);PRfnm.([fnpt 'Time'])=PRfnm.([fnpt 'TimeRaw']);%renew Day&Time
dd=PRfnm.([fnpt 'Day'])(1);ddt=(PRfnm.([fnpt 'Day'])-dd).*86400+PRfnm.([fnpt 'Time']);ddn=1:length(PRfnm.([fnpt 'Day']));
%=== Handle despike for "Time's diff calculated" // see that: (1) mean(diff) is constant; (2) spikes are time-de-syncronze with big or small step; (3) zero is time-stop.
    a=figure('Name',['SpikeDel 1- Time''s diff calculated // ' PRLLog.LName],'NumberTitle','off');hold on;plot(ddn(2:end),diff(ddt),'-r');
    mask1=bitand(PRfnm.QMask,BitQD);L=~mask1;
    p=gMapPickHandleNan(ddn(L(2:end)),diff(ddt(L)),a);pause;mask1(L)=[false ~get(p,'UserData')];close(a); %Handle de-spike for "Time's diff calculated"
    PRfnm.QMask(mask1)=bitor(PRfnm.QMask(mask1),BitQD);
%=== De-repeat time // see that: zero is time-repeat.
    a=figure('Name',['SpikeDel 1- Time''s diff calculated // ' PRLLog.LName],'NumberTitle','off');hold on;plot(ddn(2:end),diff(ddt),'-r');
    mask2=bitand(PRfnm.QMask,BitQRep);
    L=(~isnan(ddt));mask2(L)=[false abs(diff(ddt(L)))<=eps(diff(ddt(L)))];
    plot(ddn(L(2:end)),diff(ddt(L)));pause;close(a);
    PRfnm.QMask(mask2)=bitor(PRfnm.QMask(mask2),BitQRep);
%=== Handle despike for "Time's linear trend removed" // see that: not horizontal line is a time-trends
    a=figure('Name',['SpikeDel 2- Time''s linear trend removed // ' PRLLog.LName],'NumberTitle','off');hold on;
    mask3=bitand(PRfnm.QMask,BitQL);
    L=~mask3;pl=polyfit(ddn(L),ddt(L),1);plot(ddn,ddt-polyval(pl,ddn),'-r');plot(ddn(bitand(PRfnm.QMask,BitQD)),ddt(bitand(PRfnm.QMask,BitQD)),'+r');plot(ddn(bitand(PRfnm.QMask,BitQRep)),ddt(bitand(PRfnm.QMask,BitQRep)),'or');
    p=gMapPickHandleNan(ddn(L),ddt(L)-polyval(pl,ddn(L)),a);pause;mask3(L)=~get(p,'UserData');close(a); %Handle de-spike for "Time's linear trend removed"
    PRfnm.QMask(mask3)=bitor(PRfnm.QMask(mask3),BitQL);
%=== Interpolate and smooth Handle de-spiked values    
L=~(bitand(PRfnm.QMask,BitQD)|bitand(PRfnm.QMask,BitQRep)|bitand(PRfnm.QMask,BitQL));
tL=smooth(ddn(L),ddt(L),gKey{5},'loess')';ddtZ=interp1(ddn(L),tL,ddn,'linear','extrap');
PRfnm.([fnpt 'Day'])=floor(ddtZ./86400)+dd;PRfnm.([fnpt 'Time'])=ddtZ-(PRfnm.([fnpt 'Day'])-dd).*86400;
a=figure('Name',['Despiked&Smooth Time with linear trend removed // ' PRLLog.LName],'NumberTitle','off');hold on;
pl=polyfit(ddn,ddtZ,1);plot(ddn,(PRfnm.([fnpt 'Day'])-dd).*86400+PRfnm.([fnpt 'Time'])-polyval(pl,ddn),'.r');plot(ddn,ddtZ-polyval(pl,ddn),'.-c');drawnow;pause;try close(a);catch,end;
ProcLog=['Time_QC# fnm=' gKey{3} '; fnpt=' gKey{4} '; TimeSmooth=' num2str(gKey{5}) '; nn=' num2str(gKey{2}) '; BitTQH=' num2str(BitTQH) '; flTQH=' num2str(flTQH) 10];
clearvars fnm fnpt TimeSmooth nn BitTQH flTQH n tmp dd ddt ddn ddtZ L tL a pl mask1 mask2 ;

%mail@ge0mlib.com 15/11/2020