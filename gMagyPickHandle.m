function fM=gMagyPickHandle(PR,WF,WP,ProfNum,f)
%Interactive Survey Lines parts (Targets) selection. Each Target's data includes start and end makers time and ID.
%function p=gMapPickHandleNan(X,Y,f), where
%PR- Survey Lines structure;
%WF- field names for Wiggle drawing {PrName,DayName,TimeName,XName,YName,{GraphsFieldsName},QMaskName,QMaskValue}, for example: {'PrName','Mag.CompDay','Mag.CompTime','Mag.GpsEL','Mag.GpsNL',{'Mag.DepthRaw','Mag.AltitudeRaw'},'Mag.QMask',1024+2048}
%WP- WiggleParam=[Row number of Value; divider A=Value/divScl; limit for wiggle clipping from -lim to lim; wiggle direction for plane], for example: [1,0.2,70,0];
%ProfNum- profiles numbers for wiggle;
%f- handle for figure or figure number.
%======Keys=====
%Keys for "pick mode" (target window must be active):
%q- switch the MapWindow and GraphsWindow; b- stop piking (exit from MapWindow/GraphsWindow);
%z- zoom mode on/off; x- pan mode on/off; c- datacursormode on/off;
%need to realized >> 0..9-- save user-markers (datacursor) form 0 to 9 for selected target; user-markers showing only when target is selected.
%s- select Line when MapWindow picking; s- select Graph for piking/axis_scale when GraphsWindow picking;
%LMB- set marker_1; RMB- set marker_2; MMB- create target from marker_1 to marker_2 and input target's number;
%a- Select Target for current Line or Deselect Target; new target (MMB created) is auto-selected;
%e- erase selected target; t- input comment for selected target.
%=============
%Example: fMap=gMagyPickHandle(PR,{'PrName','Mag.CompDay','Mag.CompTime','Mag.GpsEL','Mag.GpsNL',{'Mag.MagAbsTSHi','Mag.MagAbsTS','Mag.AltitudeS','Mag.DepthS'},'Mag.QMask',1024+2048},[1,0.2,70,0],1:74,1);
%Example, take data: PR=getappdata(fMap,'PR');
%The PR-variable (when data taken) includes field PR{...}.Targ.Dat for survey lines where targets were marked. There are a number of rows: [tm1 tm2 CompDay1 CompDay2 CompTime1 CompTime2 TargetId]
%where,
%tm1, tm2 – numbers for marker_1 and marker_2;
%CompDay1, CompDay2, CompTime1, CompTime2 – computer’s day and time for marker_1 and marker_2;
%TargetId – target’s number.

%create Prof-structure "duplicate" with predefined fields
Pr=cell(size(PR));Nm1=gFieldsTakeFData([],WF{1});Nm2=gFieldsTakeFData([],WF{2});Nm3=gFieldsTakeFData([],WF{3});Nm4=gFieldsTakeFData([],WF{4});Nm5=gFieldsTakeFData([],WF{5});
Nm6=cell(numel(WF{6}),1);for n=1:numel(WF{6}),Nm6{n}=gFieldsTakeFData([],WF{6}{n});end; Nm7=gFieldsTakeFData([],WF{7});
for n=1:numel(PR),
    if ~isempty(PR{n}),
        Pr{n}=struct('PrName','','CompDay',[],'CompTime',[],'GpsE',[],'GpsN',[],'Ta',[],'NAB',struct('Name','','a',[],'b',[]));
        Pr{n}.PrName=getfield(PR{n},Nm1{:});Pr{n}.CompDay=getfield(PR{n},Nm2{:});Pr{n}.CompTime=getfield(PR{n},Nm3{:});Pr{n}.GpsE=getfield(PR{n},Nm4{:});Pr{n}.GpsN=getfield(PR{n},Nm5{:});
        %add graphs from different fields to one matrix and create "Name" for each graph
        n2=1;tmp_mask=getfield(PR{n},Nm7{:});
        for n1=1:numel(WF{6});
            tmp=getfield(PR{n},Nm6{n1}{:});
            if n1==3,tmp=tmp(PR{n}.Mag.AltitudeSensor,:);end;%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            n3=size(tmp,1);
            for n5=1:n3,L=bitand(tmp_mask(n5,:),WF{8})~=0;tmp(n5,L)=nan;end; %set mask for "bad" values ????????? >> external from cycle
            Pr{n}.Ta(n2:n2+n3-1,:)=tmp;
            for n4=1:n3, Pr{n}.NAB(n2+n4-1).Name=[WF{6}{n1} '_' num2str(n4)];Pr{n}.NAB(n2+n4-1).a=1;Pr{n}.NAB(n2+n4-1).b=nanmean(tmp(n4,:));end;%set values ax+b for graphs
            n2=n2+n3;
        end;
    end;
end;
clear('Nm1','Nm2','Nm3','Nm4','Nm5','Nm6','n','n1','n2','n3','n4','n5','WF');
%Pr: PrName, CompDay, CompTime, GpsE, GpsN, Ta, NAB.Name, NAB.a, NAB.b

%prepare MapWindow
if isnumeric(f), fM=figure(f); elseif isgraphics(f,'figure'), fM=f; else error('input var "f" must be figure_number or figure_handle.');end;
fM.Name='Base Map';fM_axs=fM.CurrentAxes;gMapTickLabel(fM,'%.2f',10);set(fM,'WindowKeyPressFcn',@fig_KPF);%set(fM_axs,'DataAspectRatio',[1 1 1],'DataAspectRatioMode','manual','PlotBoxAspectRatio',[3 4 4],'PlotBoxAspectRatioMode','manual'); %link for Map figure
tbh=findall(fM,'Type','uitoolbar');Ic=ones(16,16,3);Ic(1,:,1:2)=0;Ic(3,:,1:2)=0;BtM=uitoggletool(tbh,'CData',Ic,'Separator','off','HandleVisibility','off','OnCallback',@gWinPick); %create button for pick in BaseMap Window
%draw wiggles and targets
for n=ProfNum,
    tmp1=Pr{n}.Ta(WP(1),:)./WP(2);LL=abs(tmp1)>WP(3);tmp1(LL)=WP(3).*sign(tmp1(LL));[p1,p2]=gMagyDrawWiggle(fM,Pr{n}.GpsE,Pr{n}.GpsN,tmp1,WP(4));hold on; %draw Ta as Wiggles
    if isfield(PR{n},'Targ')&&~isempty(PR{n}.Targ),%if any Targets for selected Profile than draw it and create pointers
        for n1=1:numel(PR{n}.Targ),
            Pr{n}.Targ(n1).MP=line([Pr{n}.GpsE(PR{n}.Targ(n1).Dat(1)) Pr{n}.GpsE(PR{n}.Targ(n1).Dat(2))],[Pr{n}.GpsN(PR{n}.Targ(n1).Dat(1)) Pr{n}.GpsN(PR{n}.Targ(n1).Dat(2))],'Color','y','Marker','*','MarkerSize',5,'MarkerEdgeColor','k','LineWidth',2);
            Pr{n}.Targ(n1).MPt=text(Pr{n}.GpsE(PR{n}.Targ(n1).Dat(1)),Pr{n}.GpsN(PR{n}.Targ(n1).Dat(1)),num2str(PR{n}.Targ(n1).Dat(7)),'BackgroundColor','y','FontSize',8,'VerticalAlignment','top');
        end;
    end;
end;
LS=0;hold on;LS_title=title('Select Line','Interpreter','none','FontWeight','normal','FontSize',10);LS_line=line(Pr{1}.GpsE(1),Pr{1}.GpsN(1),'Color','g','LineWidth',2);%mark first profile as "selected" for Map
TS=[0 0]; %the Line number and Index of selected Target
mr1=matlab.graphics.primitive.Line.empty;mr2=matlab.graphics.primitive.Line.empty;
clear('f','tbh','Ic','tmp1','LL','n','n1');
%fM- pointer to MapWindow; fM_axs- pointer to MapWindow axis; BtM- picking button for MapWindow;
%LS- selected SurveyLine for MapWindow; LS_title- selected SurveyLine title; LS_line- pointer to marcer-line for selected SurveyLine;
%mr1,mr2- handles to markers in MapWindow;

%prepare GraphsWindow
fG=figure('Name','Select Line','NumberTitle','on');hold on;fG_axs=fG.CurrentAxes;GrYLim=fG_axs.YLim;gMapTickLabel(fG,'%.2f',10);hold on;set(fG,'WindowKeyPressFcn',@fig_KPF);
set(datacursormode(fG),'UpdateFcn',{@gGrWinCallback}); %callback function for GraphsWindow
GrColor=[[0 0 1];[1 0 0];[0 1 0];[0 1 1];[1 0 1];[1 1 0];[0 0 0]]; %Graphs colors >> b-r-g-c-m-y-k;
LSx=[];GrH=matlab.graphics.primitive.Line.empty;WG=WP(1);
GS_title=title('','Interpreter','none','FontWeight','normal','FontSize',10);
tbh=findall(fG,'Type','uitoolbar');Ic=ones(16,16,3);Ic(1,:,1:2)=0;Ic(3,:,1:2)=0;BtG=uitoggletool(tbh,'CData',Ic,'Separator','off','HandleVisibility','off','Enable','off','OnCallback',@gWinPick); %create button for pick in GraphsWindow
mr1G=matlab.graphics.primitive.Line.empty;mr2G=matlab.graphics.primitive.Line.empty;
clear('tbh','Ic','n');
%fG- pointer to GraphsWindow; fG_axs- pointer to GraphsWindow axis; BtG- picking button for GraphsWindow; GrYLim- limits along Yaxis for GraphsWindow;
%LSx- selected SurveyLine X-vector; GrH- pointers to Graphs; GrColor- color set for Graphs; WG- selected Graph;
%mr1G,mr2G- handles to markers in GraphsWindow.

gWinPick([],[]);setappdata(fM,'Prof',PR); %set initial value for Output

%====Pick in MapWindow/GraphsWindow=====
function gWinPick(~,~)
 drawnow;hold on;set(BtM,'Enable','off');set(BtG,'Enable','off');k='~';figure(fG);fCur=gcf;
 while (k~='b'),
    if fCur.Number==fG.Number, figure(fM);fCur=gcf;else figure(fG);fCur=gcf;end;if k=='q',k='~';end;
    while (k~='q')&&(k~='b'),
        if ~isempty(LSx),[xi,yi,k]=ginput(1);if isempty(k),k='~';end; else xi=Pr{1}.GpsE(1);yi=Pr{1}.GpsN(1);k='s';end;
        if fCur.Number==fM.Number, rr=get(fM_axs,'DataAspectRatio');elseif fCur.Number==fG.Number, rr=get(fG_axs,'DataAspectRatio');end; rr=rr./rr(1);
        %===select Line for MapWindow; key 's'
        if (k=='s'),r0=inf;
            if fCur.Number==fM.Number,
                for nn=ProfNum,r=((Pr{nn}.GpsE-xi).*rr(1)).^2+((Pr{nn}.GpsN-yi).*rr(2)).^2;rmin=min(r);if rmin(1)<r0, r0=rmin(1);LS=nn;end;end;
            elseif fCur.Number==fG.Number,
                for nn=1:size(Pr{LS}.Ta,1),r=(((LSx-xi).*rr(1)).*rr(1)).^2+(((Pr{LS}.Ta(nn,:)-Pr{LS}.NAB(nn).b)./Pr{LS}.NAB(nn).a-yi).*rr(2)).^2;rmin=min(r);if rmin(1)<r0, r0=rmin(1);WG=nn;end;end;
                an=inputdlg({[Pr{LS}.NAB(WG).Name ' >> A'],[Pr{LS}.NAB(WG).Name ' >> B']},'',1,{num2str(Pr{LS}.NAB(WG).a),num2str(Pr{LS}.NAB(WG).b)});
                if ~isempty(an),Pr{LS}.NAB(WG).a=str2double(an{1});Pr{LS}.NAB(WG).b=str2double(an{2});end;
            end;
            GS_title.String=[Pr{LS}.NAB(WG).Name '  AB: ' num2str(Pr{LS}.NAB(WG).a) '; ' num2str(Pr{LS}.NAB(WG).b)];delete([mr1 mr1G mr2 mr2G]);mr1=matlab.graphics.primitive.Line.empty;mr1G=matlab.graphics.primitive.Line.empty;mr2=matlab.graphics.primitive.Line.empty;mr2G=matlab.graphics.primitive.Line.empty;mr2Gt=matlab.graphics.primitive.Text.empty; %delete Marker_1 and Marker_2 before next Profile will be selected
            cla(fG_axs);fG.Name=[Pr{LS}.PrName ' Num:' num2str(LS)];%clear all primitives and set new Profile Name
            LSx=1:size(Pr{LS}.Ta,2);GrH=repmat(matlab.graphics.primitive.Line.empty,size(Pr{LS}.Ta,1),1);
            for nn=1:size(Pr{LS}.Ta,1),
                GrH(nn)=line(LSx,(Pr{LS}.Ta(nn,:)-Pr{LS}.NAB(nn).b)./Pr{LS}.NAB(nn).a,'Parent',fG_axs,'Marker','.','Color',GrColor(nn,:),'MarkerEdgeColor',GrColor(nn,:));
                text(LSx(end),(Pr{LS}.Ta(nn,end)-Pr{LS}.NAB(nn).b)./Pr{LS}.NAB(nn).a,['(' Pr{LS}.NAB(nn).Name '-' num2str(Pr{LS}.NAB(nn).b) ')/(' num2str(Pr{LS}.NAB(nn).a) ')'],'FontSize',10,'Interpreter','none','Parent',fG_axs);
            end;%draw plots
            if fCur.Number==fM.Number,zoom(fG_axs,'out');GrYLim=fG_axs.YLim;end; %set zoom to 'all' for New Profile
            if isfield(PR{LS},'Targ')&&~isempty(PR{LS}.Targ),%if any Targets for selected Profile than draw it and create pointers
                for nn=1:numel(PR{LS}.Targ),
                    tm1=PR{LS}.Targ(nn).Dat(1);tm2=PR{LS}.Targ(nn).Dat(2);
                    Pr{LS}.Targ(nn).PL1=line([tm1 tm1],GrYLim,'Color','k','Parent',fG_axs);Pr{LS}.Targ(nn).PL2=line([tm2 tm2],GrYLim,'Color','k','Parent',fG_axs);
                    if (LS==TS(1))&&(nn==TS(2)),
                        Pr{LS}.Targ(nn).PP=line([tm1 tm2],([Pr{LS}.Ta(WG,tm1) Pr{LS}.Ta(WG,tm2)]-Pr{LS}.NAB(WG).b)./Pr{LS}.NAB(WG).a,'Color','y','Marker','*','MarkerSize',7,'MarkerEdgeColor','r','MarkerFaceColor',[0.5,0.5,0.5],'LineWidth',2,'Parent',fG_axs);
                        Pr{LS}.Targ(nn).PPt=text(tm1,(Pr{LS}.Ta(WG,tm1)-Pr{LS}.NAB(WG).b)./Pr{LS}.NAB(WG).a,num2str(PR{LS}.Targ(nn).Dat(7)),'BackgroundColor','r','FontSize',8,'VerticalAlignment','top','Parent',fG_axs);
                    else
                        Pr{LS}.Targ(nn).PP=line([tm1 tm2],([Pr{LS}.Ta(WG,tm1) Pr{LS}.Ta(WG,tm2)]-Pr{LS}.NAB(WG).b)./Pr{LS}.NAB(WG).a,'Color','y','Marker','*','MarkerSize',5,'MarkerEdgeColor','k','MarkerFaceColor',[0.5,0.5,0.5],'LineWidth',2,'Parent',fG_axs);
                        Pr{LS}.Targ(nn).PPt=text(tm1,(Pr{LS}.Ta(WG,tm1)-Pr{LS}.NAB(WG).b)./Pr{LS}.NAB(WG).a,num2str(PR{LS}.Targ(nn).Dat(7)),'BackgroundColor','y','FontSize',8,'VerticalAlignment','top','Parent',fG_axs);
                    end;
                end;
            end;
            LS_title.String=Pr{LS}.PrName;set(LS_line,'XData',Pr{LS}.GpsE,'YData',Pr{LS}.GpsN); %set new Profile Name and mark line as "selected" for Map
        end;
        %===set Marker_1 to MapWin and GraphsWin; key LB
        if (k==1), if fCur.Number==fM.Number, r=((Pr{LS}.GpsE-xi).*rr(1)).^2+((Pr{LS}.GpsN-yi).*rr(2)).^2;elseif fCur.Number==fG.Number, r=((LSx-xi).*rr(1)).^2+(((Pr{LS}.Ta(WG,:)-Pr{LS}.NAB(WG).b)./Pr{LS}.NAB(WG).a-yi).*rr(2)).^2;end;
            [~,di]=min(r);
            if isempty(mr1),
                mr1G=line(di(1),(Pr{LS}.Ta(WG,di(1))-Pr{LS}.NAB(WG).b)./Pr{LS}.NAB(WG).a,'Marker','^','MarkerSize',10,'MarkerEdgeColor','k','MarkerFaceColor',[0.5,0.5,0.5],'Parent',fG_axs);
                mr1=line(Pr{LS}.GpsE(di(1)),Pr{LS}.GpsN(di(1)),'Marker','^','MarkerSize',10,'MarkerEdgeColor','k','MarkerFaceColor',[0.5,0.5,0.5],'Parent',fM_axs);
            else
                set(mr1G,'XData',di(1),'YData',(Pr{LS}.Ta(WG,di(1))-Pr{LS}.NAB(WG).b)./Pr{LS}.NAB(WG).a);
                set(mr1,'XData',Pr{LS}.GpsE(di(1)),'YData',Pr{LS}.GpsN(di(1)));
            end;
        end;
        %===set Marker_2 to MapWin and GraphsWin; key RB
        if (k==3), if fCur.Number==fM.Number, r=((Pr{LS}.GpsE-xi).*rr(1)).^2+((Pr{LS}.GpsN-yi).*rr(2)).^2;elseif fCur.Number==fG.Number, r=((LSx-xi).*rr(1)).^2+(((Pr{LS}.Ta(WG,:)-Pr{LS}.NAB(WG).b)./Pr{LS}.NAB(WG).a-yi).*rr(2)).^2;end;
            [~,di]=min(r);
            if isempty(mr2),
                mr2G=line(di(1),(Pr{LS}.Ta(WG,di(1))-Pr{LS}.NAB(WG).b)./Pr{LS}.NAB(WG).a,'Marker','v','MarkerSize',10,'MarkerEdgeColor','k','MarkerFaceColor',[0.5,0.5,0.5],'Parent',fG_axs);
                mr2=line(Pr{LS}.GpsE(di(1)),Pr{LS}.GpsN(di(1)),'Marker','v','MarkerSize',10,'MarkerEdgeColor','k','MarkerFaceColor',[0.5,0.5,0.5],'Parent',fM_axs);
            else
                set(mr2G,'XData',di(1),'YData',(Pr{LS}.Ta(WG,di(1))-Pr{LS}.NAB(WG).b)./Pr{LS}.NAB(WG).a);
                set(mr2,'XData',Pr{LS}.GpsE(di(1)),'YData',Pr{LS}.GpsN(di(1)));
            end;
        end;
        %===if was set Marker_1 or Marker_2 then print Distance to GraphsWin; key LB/RB
        if (k==1)||(k==3),
            if (~isempty(mr1))&&(~isempty(mr2)),
                tm1=get(mr1G,'XData');tm2=get(mr2G,'XData');r=sqrt((Pr{LS}.GpsE(tm2)-Pr{LS}.GpsE(tm1)).^2+(Pr{LS}.GpsN(tm2)-Pr{LS}.GpsN(tm1)).^2);tr=(Pr{LS}.CompDay(tm2)-Pr{LS}.CompDay(tm1)).*24*3600+(Pr{LS}.CompTime(tm2)-Pr{LS}.CompTime(tm1));
                GS_title.String=[Pr{LS}.NAB(WG).Name '  AB: ' num2str(Pr{LS}.NAB(WG).a) '; ' num2str(Pr{LS}.NAB(WG).b) '  Dist: ' num2str(r) 'm; ' num2str(tr) 's'];
            end;
        end;
        %===convert Marker_1 and Marker_2 from MapWin to Target in TargetList; key MB
        if (k==2),
            if ~isempty(mr1)&&~isempty(mr2),
                if (TS(1)~=0)&&(TS(2)~=0),set(Pr{TS(1)}.Targ(TS(2)).MP,'MarkerSize',5,'MarkerEdgeColor','k');set(Pr{TS(1)}.Targ(TS(2)).MPt,'BackgroundColor','y');if TS(1)==LS, set(Pr{TS(1)}.Targ(TS(2)).PP,'MarkerSize',5,'MarkerEdgeColor','k');set(Pr{TS(1)}.Targ(TS(2)).PPt,'BackgroundColor','y');end;TS=[0 0];end;%deselect current target
                if ~isfield(PR{LS},'Targ')||isempty(PR{LS}.Targ), nn=1; else nn=numel(PR{LS}.Targ)+1;end;
                if get(mr1G,'XData')<get(mr2G,'XData'),tm1=get(mr1G,'XData');tm2=get(mr2G,'XData');else tm2=get(mr1G,'XData');tm1=get(mr2G,'XData');end; %take data from graph-marker; format >> [num1 num2 day1 day2 time1 time2 ID]
                Tid=str2double(inputdlg({'ID:'}));
                PR{LS}.Targ(nn).Dat=[tm1 tm2 Pr{LS}.CompDay(tm1) Pr{LS}.CompDay(tm2) Pr{LS}.CompTime(tm1) Pr{LS}.CompTime(tm2) Tid];
                Pr{LS}.Targ(nn).PL1=line([tm1 tm1],GrYLim,'Color','k','Parent',fG_axs);Pr{LS}.Targ(nn).PL2=line([tm2 tm2],GrYLim,'Color','k','Parent',fG_axs);
                Pr{LS}.Targ(nn).PP=line([tm1 tm2],([Pr{LS}.Ta(WG,tm1) Pr{LS}.Ta(WG,tm2)]-Pr{LS}.NAB(WG).b)./Pr{LS}.NAB(WG).a,'Color','y','Marker','*','MarkerSize',7,'MarkerEdgeColor','r','MarkerFaceColor',[0.5,0.5,0.5],'LineWidth',2,'Parent',fG_axs);
                Pr{LS}.Targ(nn).PPt=text(tm1,(Pr{LS}.Ta(WG,tm1)-Pr{LS}.NAB(WG).b)./Pr{LS}.NAB(WG).a,num2str(Tid),'BackgroundColor','r','VerticalAlignment','top','Parent',fG_axs);
                Pr{LS}.Targ(nn).MP=line([Pr{LS}.GpsE(tm1) Pr{LS}.GpsE(tm2)],[Pr{LS}.GpsN(tm1) Pr{LS}.GpsN(tm2)],'Color','y','Marker','*','MarkerSize',9,'MarkerEdgeColor','r','MarkerFaceColor',[0.5,0.5,0.5],'LineWidth',2,'Parent',fM_axs);
                Pr{LS}.Targ(nn).MPt=text(Pr{LS}.GpsE(tm1),Pr{LS}.GpsN(tm1),num2str(Tid),'BackgroundColor','r','VerticalAlignment','top','Parent',fM_axs);
                TS=[LS nn];
            end;
        end;
        %===select/deselect Target; key 'a'
        if (k=='a'),
            if (TS(1)==0)&&(TS(2)==0),
                if isfield(PR{LS},'Targ')&&~isempty(PR{LS}.Targ),
                    Targ=cell2mat({PR{LS}.Targ.Dat}');if fCur.Number==fM.Number, r=((Pr{LS}.GpsE(Targ(:,1))-xi).*rr(1)).^2+((Pr{LS}.GpsN(Targ(:,1))-yi).*rr(2)).^2;elseif fCur.Number==fG.Number, r=((LSx(Targ(:,1))-xi).*rr(1)).^2+(((Pr{LS}.Ta(WG,Targ(:,1))-Pr{LS}.NAB(WG).b)./Pr{LS}.NAB(WG).a-yi).*rr(2)).^2;end;
                    [~,TSi]=min(r);TS=[LS TSi];set(Pr{LS}.Targ(TSi).PP,'MarkerSize',7,'MarkerEdgeColor','r');set(Pr{LS}.Targ(TSi).MP,'MarkerSize',9,'MarkerEdgeColor','r');set(Pr{LS}.Targ(TSi).PPt,'BackgroundColor','r');set(Pr{LS}.Targ(TSi).MPt,'BackgroundColor','r');
                end;
            else
                set(Pr{TS(1)}.Targ(TS(2)).MP,'MarkerSize',5,'MarkerEdgeColor','k');set(Pr{TS(1)}.Targ(TS(2)).MPt,'BackgroundColor','y');if TS(1)==LS, set(Pr{TS(1)}.Targ(TS(2)).PP,'MarkerSize',5,'MarkerEdgeColor','k');set(Pr{TS(1)}.Targ(TS(2)).PPt,'BackgroundColor','y');end;
                TS=[0 0];
            end;
        end;
        %===erase Target from MapWin and TargetList (used Point_1 position); key 'e'
        if (k=='e')&&(TS(1)~=0)&&(TS(2)~=0)&&(strcmp(questdlg('Delete Selected Target?','','Yes','No','No'),'Yes')),
            delete([Pr{TS(1)}.Targ(TS(2)).PP Pr{TS(1)}.Targ(TS(2)).PPt Pr{TS(1)}.Targ(TS(2)).PL1 Pr{TS(1)}.Targ(TS(2)).PL2 Pr{TS(1)}.Targ(TS(2)).MP Pr{TS(1)}.Targ(TS(2)).MPt]);
            Pr{TS(1)}.Targ(TS(2))=[];PR{TS(1)}.Targ(TS(2))=[];TS=[0 0];
        end;
        %===input comment for selected Target; key 't'
        if (k=='t')&&(TS(1)~=0)&&(TS(2)~=0),
            if isfield(PR{TS(1)}.Targ(TS(2)),'Comment'), ctxt=PR{TS(1)}.Targ(TS(2)).Comment;else ctxt='';end;
            an=inputdlg({[Pr{LS}.NAB(WG).Name ' >> Comment']},'',[4 40],{ctxt});if ~isempty(an), PR{TS(1)}.Targ(TS(2)).Comment=an{:};end;
        end;
        %===zoom/pan/datacursormode; keys 'z', 'x', 'c'
        if (k=='z'),zoom on;pause;zoom off;end;
        if (k=='x'),pan on;pause;pan off;end;
        if (k=='c'),datacursormode on;pause;datacursormode off;end;
    end;
 end;
 %un-push button
 hold off;set(BtM,'Enable','on');set(BtM,'State','off');set(BtG,'Enable','on');set(BtG,'State','off'); %un-push buttons
 setappdata(fM,'PR',PR);
end

%=======Callback function -- Datacursormode for GraphsWindow==========
function out_txt=gGrWinCallback(~,event_obj)
pos=get(event_obj,'Position');di=get(event_obj,'DataIndex');PrN=find(event_obj.Target==GrH);
out_txt={['Num: ',num2str(di,'%d')],['X: ',num2str(pos(1),'%f')],['Y: ',num2str(Pr{LS}.Ta(PrN(1),di),'%f')],['E: ',num2str(Pr{LS}.GpsE(di),'%f')],['N: ',num2str(Pr{LS}.GpsN(di),'%f')]};
clipboard('copy', [Pr{LS}.PrName '	' Pr{LS}.NAB(PrN(1)).Name '	' num2str(di,'%d') '	' num2str(pos(1),'%f') '	' num2str(Pr{LS}.Ta(PrN(1),di),'%f') '	' num2str(Pr{LS}.GpsE(di),'%f') '	' num2str(Pr{LS}.GpsN(di),'%f')]);
end

%=======Callback function -- WindowKeyPressFcn for MapWindow and GraphsWindow==========
function fig_KPF(varargin)
end

end