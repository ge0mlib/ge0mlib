function gDataDrawSection(fig_num,ax,ay,Data,icaxis,icolor)
%Draw image using Data matrix.
%function gDataDrawSection(fig_num,ax,ay,Data,icaxis,icolor), where
%fig_num - figure number;
%ax,ay - multiple for horizontal and vertical scale;
%Data - matrix for bitmap (image);
%icaxis - min and max data for colormap (will find from Data, if isempty);
%icolor - colormap.
%Example: gDataDrawSection(7,1,Head.dt(1)*1e-3,Data34,[-32767 32767],[]);
%Example for Syg: x=Head.cdpX./100;gDataDrawSection(19,x,Head.dt(1)*1e-3,Data,[-0.4e8 0.4e8],[]);ax=gca;ax.XTick=round(min(x)/100)*100:50:round(max(x)/100)*100;gMapTickLabel(19,'%.0f',10);

fig=figure(fig_num);
if isempty(icolor), icolor=1-colormap('gray');end;
if isempty(icaxis), minData=min(min(Data));maxData=max(max(Data));icaxis=[minData maxData];end;
if length(ax)==1, x=(1:size(Data,2)).*ax; else x=ax;end;
if length(ay)==1, y=(1:size(Data,1)).*ay; else y=ay;end;
imagesc(x,y,Data,icaxis);
if isempty(icolor),colormap(flipud(colormap('gray')));else colormap(icolor);end;
dcm_obj=datacursormode(fig);set(dcm_obj,'UpdateFcn',{@gDataDrawSectionCallback});

function output_txt=gDataDrawSectionCallback(~,event_obj)
%output_txt=gDataDrawSectionCallback(~,event_obj,gTraceXY)
pos=get(event_obj,'Position');di=get(event_obj,'DataIndex');%tr=get(event_obj,'Target');
output_txt={['DI: ',num2str(di,'%d')],['X: ',num2str(pos(1),'%d')],['Y: ',num2str(pos(2),'%f')]};%['TargetID: ',num2str(round(tr),'%d')],%if length(pos)>2,output_txt{end+1}=['Z: ',num2str(pos(3),'%d')];end;

%mail@ge0mlib.com 23/07/2017




