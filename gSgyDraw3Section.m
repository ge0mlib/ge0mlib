function gSgyDraw3Section(fig_num,StepXY,StepZ,KZ,Head,Data,icaxis,icolor)
%Draw Sgy Data matrix as 3D image (vertical axis is the milliseconds).
%function gSgyDraw3Section(fig_num,StepXY,StepZ,KZ,Head,Data,icaxis,icolor), where
%fig_num- figure number;
%StepXY- step for traces drawing;
%StepZ- step for trace's discrete drawing;
%KZ- ratio for Z-axis drawing;
%Data- matrix for texturemap;
%icaxis- min and max data for colormap (will find from Data, if isempty);
%icolor- colormap.
%Example: gSgyDraw3Section(7,2,2,0.01,Head,Data,[0 30000],[]);

if ischar(Data),Data=gDataLoad(Data);end;
figure(fig_num);axi=gca;axi.ZDir='reverse';axi.DataAspectRatio=[1 1 KZ];axi.Color='black';axi.Projection='perspective';
if isempty(icolor), icolor=1-colormap('gray');end;colormap(icolor);
if isempty(icaxis), minData=min(min(Data));maxData=max(max(Data));icaxis=[minData maxData];end;caxis(icaxis);
L1=round(1:StepZ:size(Data,1));L2=round(1:StepXY:size(Data,2));
X=repmat(Head.SourceX(L2),length(L1),1);Y=repmat(Head.SourceY(L2),length(L1),1);
Z=repmat(L1',1,length(L2)).*repmat(Head.dt(L2).*1e-3,length(L1),1)+repmat(Head.DelayRecordingTime(L2),length(L1),1);
Data1=Data(:,L2);
surface(X,Y,Z,Data1(L1,:),'FaceColor','texturemap','EdgeColor','none','CDataMapping','scaled');hold on;
%dcm_obj=datacursormode(fig);set(dcm_obj,'UpdateFcn',{@gSgyDrawSectionCallback,varargin});
plot3(Head.SourceX(L2),Head.SourceY(L2),Head.UnassignedInt1(L2).*Head.dt(L2).*1e-3,'-b');
plot3(Head.SourceX(L2),Head.SourceY(L2),Head.UnassignedInt2(L2).*Head.dt(L2).*1e-3,'-c');hold off;

%mail@ge0mlib.com 24/10/2017