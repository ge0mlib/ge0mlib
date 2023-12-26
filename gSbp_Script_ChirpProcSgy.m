%script gTraining03_ChirpProcSgy;
%Start script with command >>> {'SgyLoad','c:\sgy\Line001.sgy'};gTraining02_ChirpSgy; <<< or the same.
%Processing for traces (mute, levelling to MBES, gain), bottom (pick, create using MBES, smoothing) and simple processing for track-coordinates (despiking, transformation, smoothing).
%The link to Chirp's sgy-files example: http://ge0mlib.com/g/example/ET3200SX512i_sgy.zip
%The link to Training detailed description: http://ge0mlib.com/g/gTraining03_ChirpProcSgy.pdf

gKey=ans;
%LoadData====================================================
if strcmp(gKey{1},'PtsLoad'), %Load bottom pts-file
    try b_name=gKey{2};catch,b_name=input('PTS-file name with X,Y,Z:');end;
    bott0=dlmread(b_name); bott1=scatteredInterpolant(bott0(:,1),bott0(:,2),bott0(:,3),'linear');
    clear bott0;
end;
if strcmp(gKey{1},'SgyLoad'),
    try name=gKey{2};catch,name=input('File name or {PR number,field name}:');end; %'d:\8\ET2000DSS_sgy\ET2000DSS_Line1.sgy' or {2,'ET2000'}
    try fiName=gKey{3};catch,fiName={'TraceSequenceLine','SourceX','SourceY'};end; %data for DTEN-fields calculation: Kp_number, X/Lat-coordinatse, Y/Lon-coordinates
    if all(ischar(name)), %Read Sgy-data from file >> {'SgyLoad','d:\8\ET2000DSS_sgy\ET2000DSS_Line1.sgy'};gTraining03_ChirpProcSgy;
        NavS=struct('TargCode',2); %create Survey datum
        NavP=struct('EllipParam',[6378137 0.0818191908426215],'ProjParam',[0 57 0.9996 500000 0], 'ProjForvFunc','gNavGeog2ProjUtm','ProjRevFunc','gNavProjUtm2Geog','TargCode',6); %create Projects datum
        [SgyHead,Head,Data]=gSgyRead(name,'b',[]); %read Sgy from File
        Head=gSgyDTEN(Head,fiName{1},fiName{2},fiName{3},NavS,NavP); %convert coordinates to DTEN-fields
        ProcLog=['SgyLoad>> FileName=' name ';' 10];
    elseif all(iscell(name)), %Read Sgy-data from PR-variable >>{'SgyLoad',{2,'ET2000'}};gTraining03_ChirpProcSgy;
        SgyHead=PR{name{1}}.(name{2}).SgyHead;Head=PR(name{1}).(name{2}).Head;Data=PR(name{1}).(name{2}).Data; if all(ischar(Data)),Data=gDataLoad(SgyHead.fNameTmp);end; %read Sgy from PR-variable
        ProcLog=['SgyLoad>> FileName=' SgyHead.fName ';' 10];
    else error('SgyLoad: name must be File name or PR number.');
    end;
    Head.UnassignedInt1(:)=0;Head.UnassignedInt2(:)=0;Head.WeatheringVelocity(:)=0;Head.DataUse(:)=0; %set bottom-fields and WaterSoundVelosity to zero
    SgyHeadRaw=SgyHead;HeadRaw=Head;DataRaw=Data; %keep Raw-Sgy-data
    ProcLog=[ProcLog 'SgyLoad>> .UnassignedInt1=0; .UnassignedInt2=0; .WeatheringVelocity=0; .DataUse=0;' 10];
end;
%Position====================================================
if strcmp(gKey{1},'PositionRawDespike'), %Position Handle de-spike >> {'PositionRawDespike'};gTraining03_ChirpProcSgy;
    ddt=1:numel(Head.GpsE);%Head.GpsE=HeadRaw.GpsE;HeadRaw.GpsN=Head.GpsN;
    a=figure('Name','PositionRawDespike_Step1','NumberTitle','off');
    p=gMapPickHandleNan(Head.GpsE,Head.GpsN,a);pause;mask1=~get(p,'UserData');close(a);Head.GpsE(mask1)=nan;Head.GpsN(mask1)=nan;
    a=figure('Name','PositionRawDespike_Step2','NumberTitle','off');L=~isnan(Head.GpsN);p=polyfit(ddt(L),Head.GpsN(L),1); %calc&remove linear for N
    p=gMapPickHandleNan(ddt,Head.GpsN-polyval(p,ddt),a);pause;mask2=~get(p,'UserData');close(a);Head.GpsE(mask2)=nan;Head.GpsN(mask2)=nan;
    a=figure('Name','PositionRawDespike_Step3','NumberTitle','off');L=~isnan(Head.GpsE);p=polyfit(ddt(L),Head.GpsE(L),1); %calc&remove linear for E
    p=gMapPickHandleNan(ddt,Head.GpsE-polyval(p,ddt),a);pause;mask3=~get(p,'UserData');close(a);Head.GpsE(mask3)=nan;Head.GpsN(mask3)=nan;
    Head.DataUse(mask1|mask2|mask3)=bitor(Head.DataUse(mask1|mask2|mask3),8); %>>>>Head.DataUse field -- set bit3, mean "handle deleted spikes for GpsE&GpsN"
    [Head.GpsE,Head.GpsN]=gNavCoordDerepeat(Head.GpsE,Head.GpsN,'linear');
    a=figure('Name','PositionRawDespike_Result','NumberTitle','off');hold on;axis equal;plot(Head.GpsE,Head.GpsN,'.-c');plot(HeadRaw.GpsE,HeadRaw.GpsN,'.r');hold off;
    ProcLog=[ProcLog 'PositionRawDespike>> Removed coordinates marked with set Bit3 for .DataUse-filed;' 10];
end;
if strcmp(gKey{1},'PositionSmooth'), %Position smooth >> {'PositionSmooth',7,'sm'};gTraining03_ChirpProcSgy;
    try winf=gKey{2};catch,winf=input('Smooth Window=');end; try fnp=gKey{3};catch,fnp=input('Coord preffix=');end;
    ddt=1:numel(Head.GpsE);
    Head.([fnp 'GpsE'])=smooth(ddt,Head.GpsE,winf,'loess')';Head.([fnp 'GpsN'])=smooth(ddt,Head.GpsN,winf,'loess')';
    figure(99);plot(Head.GpsE,Head.GpsN,'.r');hold on;axis equal;plot(Head.([fnp 'GpsE']),Head.([fnp 'GpsN']),'.-c');hold off; %draw tracks
    ProcLog=[ProcLog 'PositionSmooth>> Smooth Window=' num2str(winf) '; Coord preffix=' fnp ';' 10];
end;
%Bottom====================================================
if strcmp(gKey{1},'SBP_Pick'), %for example: CurveNumber(1)=SBP-to-Bottom; CurveNumber(2)=SBP-to-Bottom-to-WaterSurface-to-SBP;
    figure(100);imagesc(Data,[min(min(Data)) max(max(Data))]);colormap(flipud(colormap('gray')));hold on;
    try tn=gKey{2};catch,tn=input('Trace Numbers for autopick=');end; % >> 2
    try sn=gKey{3};catch,sn=input('Sample Numbers for autopick=');end; % >> 804
    try bv=gKey{4};catch,bv=input('AutoPick parameters=');end; % [6 6 3 400] >> 1)up border for "search window"; 2)down border for "search window"; 3)autopick condition 1-max, 2-min, 3-bigger than A, 4-smaller than A; 4)A for 3-4 conditions;
    try nn=gKey{5};catch,nn=input('Curve Number will picked=');end; % >> outCurRaw(nn) will created
    if ~exist(outCur1,'var'),outCur1=[];end; if ~exist(outCur2,'var'),outCur2=[];end; %set up&down borders for horizon picking to empty
    if ~isempty(outCur1), plot(outCur1.PickL(2,:),'b');end; if ~isempty(outCur2), plot(outCur2.PickL(2,:),'b');end;
    outCurRaw(nn)=gDataPLPickAuto(Data,[tn(1),sn]',bv,outCur1,outCur2,'123','.-b'); %
    %outCur1=gMapPickHandleImg([],1); outCur2=gMapPickHandleImg([],1); outCurRaw(nn)=gMapPickHandleImg(outCurRaw(nn),1);
    ProcLog=[ProcLog 'SBP_Pick>> Trace Numbers=' num2str(tn) '; Sample Numbers=' sn '; AutoPick parameters=' num2str(bv) '; Curve Number=' num2str(nn) ';' 10];
    figure(100);plot(outCurRaw(nn).PickL(2,:),'r');hold off;
end;
if strcmp(gKey{1},'SBP_BottomCreate'),
    try sh=gKey{2};catch,sh=input('Picked-bottom shift (to lineup from picked-line) in samples=');end; %for example, picking was done with "bigger than A"-condition, and it must be shifred to "lineup" center
    try key=gKey{3};catch,key=input('SBP-bottom create parameters [Method BottomCurNum AuxCurNum]=');end; %There are three methods 1,2,3; see description and figures in gTraining03_ChirpProcSgy.pdf
    try winf=gKey{4};catch,winf=input('SwellFilterWindow to smooth SBP-bottom=');end; %if SBP-bottom need not smooth, than set Window==1
    imagesc(Data,[min(min(Data)) max(max(Data))]);colormap(flipud(colormap('gray')));hold on;
    switch key(1),
        case 1,outCur=outCurRaw(key(2));outCur.PickL(2,:)=outCur.PickL(2,:)+sh; %BottomCurNum=Fish>Bottom>Fish;
        case 2,outCur=outCurRaw(key(3));outCur.PickL(2,:)=outCurRaw(key(2)).PickL(2,:)+outCur.PickL(2,:)+sh.*2; %BottomCurNum=Fish>Bottom>Fish; AuxCurNum=Fish>WaterSurface>Fish;
        case 3,outCur=outCurRaw(key(3));outCur.PickL(2,:)=outCur.PickL(2,:)+sh; %BottomCurNum=Fish>Bottom>Fish; AuxCurNum=(Fish>Bottom>WaterSurface>Fish)+(Fish>WaterSurface>Bottom>Fish)=WaterSurface>Bottom>WaterSurface;
        otherwise, error('SBP_BottomCreate: Bad Method key.');
    end;
    tmp=outCur.PickL(2,:);outCur.PickL(2,:)=round(smooth(outCur.PickL(2,:)',winf,'loess'))'; %weight_k=gausswin(winf,3);outCur.PickL(2,:)=round(gDataTraceFilt(outCur.PickL(2,:)',weight_k,1))';
    DataTmp=gDataToPL(Data,outCurRaw(1),outCur);
    figure(100);imagesc(DataTmp,[min(min(DataTmp)) max(max(DataTmp))]);colormap(flipud(colormap('gray')));hold on;plot(outCurRaw(1).PickL(2,:),'r');plot(tmp,'c');plot(outCur.PickL(2,:),'b');hold off; %r- picked bottom; c- SBP-bottom was created; b-smoothed SBP-bottom;
    if input('Save? 1/0>>'),
        Data=DataTmp;Head.UnassignedInt1=outCur.PickL(2,:);Head.UnassignedInt2=outCurRaw(key(2)).PickL(2,:); %Head.UnassignedInt1-- SBP-bottom was created and smoothed; Head.UnassignedInt2-- Picked-bottom;
        ProcLog=[ProcLog 'SBP_BottomCreate>> Picked-bottom shift in samples=' num2str(sh) '; SBP-bottom create parameters [Method BottomCurNum AuxCurNum]=[' num2str(key) ']; SwellFilterWindow=' winf ';' 10];
        ProcLog=[ProcLog 'SBP_BottomCreate>> .UnassignedInt1=SBP-bottom in samples; .UnassignedInt2=Picked-bottom in samples;' 10];        
    end;
end;
if strcmp(gKey{1},'SBP_BottomToMBES'),
    try key=gKey{2};catch,key=input('Method=');end; %There are three methods: 1)constant for shift for SBP-bottom to MBES-bottom; 2)each trace shift to MBES-bottom, when SBP-bottom is "deformed";
    switch key,
        case 1, %Calculate constant for shift for SBP-bottom
            try stdB=gKey{3};catch,stdB=input('Stigmation coefficients to calculate shift [3,2.5]=');end;
            try Vwater=gKey{4};catch,Vwater=input('Sound velosity for water (m/s)=');end;
            Sbo=Head.UnassignedInt1;Mbo=bott1(Head.GpsE,Head.GpsN)./Vwater.*2./(SgyHead.dt.*1e-6); %SBP-bottom and MBES-bottom in samples
            dd=Mbo-Sbo;dd(isnan(dd))=[]; %difference between SBP-bottom and MBES-bottom in samples
            L=1;for n=stdB;while ~isempty(L), L=find(abs(dd-mean(dd))>std(dd).*stdB(n));dd(L)=[];end;end; %robust stigmation
            Sbo2=round(mean(dd)+Sbo); %Sbo2-- shifted SBP-bottom to MBES-bottom
        case 2, %MBES-bottom smoothed and shift each trace from SBP-bottom to MBES-smoothed-bottom
            try winf=gKey{3};catch,winf=input('SwellFilterWindow  to smooth MBES-bottom=');end;
            try Vwater=gKey{4};catch,Vwater=input('Sound velosity for water (m/s)=');end;
            Sbo=Head.UnassignedInt1;Mbo=bott1(Head.GpsE,Head.GpsN)./Vwater.*2./(SgyHead.dt.*1e-6); %SBP-bottom and MBES-bottom in samples
            dd=Mbo-Sbo;z=find(~isnan(dd));dd(1:z(1)+10)=dd(z(1)+10);dd(z(end)-10:end)=dd(z(end)-10); %find edges without MBES-bottom values; set constant difference for edges (means that 10 MBES-bottom values are bad)
            nnn=(1:size(Data,2))';z=~isnan(dd);dd2=interp1(nnn(z),dd(z),nnn,'linear','extrap'); %interpolate nan-holes for middle part
            Mbo2=Sbo+dd2; %create MBES-bottom without holes
            Sbo2=round(smooth(Mbo2',winf,'loess'))'; %create new SBP-bottom as the smoothed MBES-bottom without holes
        otherwise, error('SBP_BottomToMBES: Bad Method key.');
    end;
    DataTmp=gDataToPL(Data,Sbo,Sbo2);
    figure(100);imagesc(DataTmp,[min(min(DataTmp)) max(max(DataTmp))]);colormap(flipud(colormap('gray')));hold on;plot(Mbo,'r');plot(Sbo,'c');plot(Sbo2,'b');hold off; %r-MBES bottom; c-SBP-bottom; b-shifted SBP
    if input('Save? 1/0>>'), Data=DataTmp;Head.UnassignedInt1=Sbo2;Head.WeatheringVelocity(:)=Vwater; %Head.UnassignedInt1-- smoothed bottom;
        ProcLog=[ProcLog 'SBP_BottomToMBES>> PTS-file ' b_name ' was used to calculate MBES-bottom;' 10];
        switch key,
            case 1, ProcLog=[ProcLog 'SBP_BottomToMBES>> Method=' num2str(key) ' (Calculate constant shift); Stigmation coefficients=' num2str(stdB) '; Sound velosity for water (m/s)=' num2str(Vwater) ';' 10];
            case 2, ProcLog=[ProcLog 'SBP_BottomToMBES>> Method=' num2str(key) ' (Shift each point); Swell Filter Window=' winf '; Sound velosity for water (m/s)=' num2str(Vwater) ';' 10];
        end;
        ProcLog=[ProcLog 'SBP_BottomToMBES>> .UnassignedInt1=SBP-bottom leveled to MBES-bottom; Head.WeatheringVelocity= Sound velosity for water (m/s);' 10];
    end;
end;
%Traces====================================================
if strcmp(gKey{1},'SgyMute'),
    try dv=gKey{2};catch,dv=input('Divider for colormap trim=');end;
    Data=gDataFillPL(Data,1,Head.UnassignedInt1-1,0); figure(100);imagesc(Data,[min(min(DataTmp))./dv max(max(Data))./dv]);colormap(flipud(colormap('gray')));
    ProcLog=[ProcLog 'SgyMute>> Sgy traces were muted to .UnassignedInt1;' 10];
end;
if strcmp(gKey{1},'SgyGain'),
    try key=gKey{2};catch,key=input('Parameters [Method ...]=');end; try dv=gKey{3};catch,dv=input('Divider for colormap trim=');end;
    switch key,
        case 1,[DataTmp,tp]=gDataGainPL(Data,'nn',[100,0.05],Head.UnassignedInt1,1); %decrease bottom reflection
        case 2, [DataTmp,tp]=gDataGainPL(Data,'exp',[0 0.001 0 1],Head.UnassignedInt1,1.5);
        case 3, wk1=gausswin(40,3);[DataTmp,tp]=gDataGainPL(Data,'agc',wk1,[],[]);
        otherwise, error('SgyGain: Bad Method key.');
    end;
    figure(101);plot(DataRaw(:,20));hold on;plot(DataTmp(:,20));plot(tp);hold off;
    figure(103);imagesc(DataTmp,[min(min(DataTmp))./dv max(max(DataTmp))./dv]);colormap(flipud(colormap('gray')));
    if input('Save? 1/0>>'), Data=DataTmp;end;
end;
%SaveData====================================================
if strcmp(gKey{1},'SgySave'), %Save Sgy-file with XY-coordinates corrected >> {'SgySave','sm',[],[],[],-100,0};gTraining03_ChirpProcSgy;
    try fnp=gKey{2};catch,fnp=input('Coordinates preffix=');end; %preffix for GpsE, GpsN
    try clipL=gKey{3};catch,clipL=input('Clipping Level (empty is not used)=');end; %Clipping Level
    try scaleM=gKey{4};catch,scaleM=input('Scale Max (uint16 is 32767; empty is not used)=');end; %rescale data (Clipping Level) to scaleM
    try DataSampleFormat=gKey{5};catch,DataSampleFormat=input('DataSampleFormat (uint16 is 3; empty is no changes)=');end; %DataSampleFormat >> 1=4-byte IBM floating-point; 2=4-byte, two's complement integer; 3=2-byte, two's complement integer; 4=4-byte fixed-point with gain (obsolete); 5=4-byte IEEE floating-point; 6=Not currently used; 7=Not currently used; 8=1-byte, two's complement integer.
    try SourceGroupScalar=gKey{6};catch,SourceGroupScalar=input('SourceGroupScalar value for XY-coordinates (-100)=');end;
    try ProcLogFl=gKey{7};catch,ProcLogFl=input('Is the ProcLog save to ExtTextualHeaders? (0/1)=');end;
    Head.CoordinateUnits(:)=1;
    if ~isempty(SourceGroupScalar),Head.SourceGroupScalar(:)=SourceGroupScalar;else Head.SourceGroupScalar(:)=-100;end;sc=abs(Head.SourceGroupScalar).^sign(Head.SourceGroupScalar);
    GpsE=Head.([fnp 'GpsE'])./sc;GpsN=Head.([fnp 'GpsN'])./sc; Head.SourceX=GpsE;Head.SourceY=GpsN;Head.GroupX=GpsE;Head.GroupY=GpsN;Head.cdpX=GpsE;Head.cdpY=GpsN; %set coordinates to XY-corrected
    if ~isempty(clipL),Data(Data<-clipL)=-clipL;Data(Data>clipL)=clipL;else clipL=1;end;
    if ~isempty(scaleM),Data=Data./clipL.*scaleM;end;
    if ~isempty(DataSampleFormat),SgyHead.FDataSampleFormat=DataSampleFormat;SgyHead.DataSampleFormat=DataSampleFormat;end;
    if ProcLogFl,SgyHead.ExtTextualHeaders=ProcLog;end;
    gSgyWrite(SgyHead,Head,Data,[name(1:end-4) '_corr.sgy']);
end;

%mail@ge0mlib.com 13/02/2020