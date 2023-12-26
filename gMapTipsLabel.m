function output_txt=gMapTipsLabel(~,event_obj,varargin)
%Create tips with current position and additional data.
%function output_txt=gMapTipsLabel(~,event_obj,varargin), where
%obj - currently not used (empty);
%event_obj - handle to event object;
%varargin - additional data for tips' text creation (row numbers with length equal to points number);
%output_txt - data cursor text string (string or cell array of strings).
%Example: figure(100);dcm_obj=datacursormode(100);set(dcm_obj,'UpdateFcn',{@gMapTipsLabel});

pos=get(event_obj,'Position');di=get(event_obj,'DataIndex');tr=get(event_obj,'Target');
output_txt={['DI: ',num2str(di,'%d')],['X: ',num2str(pos(1),'%f')],['Y: ',num2str(pos(2),'%f')]};
if length(pos)>2,output_txt{4}=['Z: ',num2str(pos(3),'%d')];end;
if ~isempty(varargin),
    nn=size(output_txt,2);
    for n=1:size(varargin{1},1),
        output_txt{n+nn}=['P',num2str(n),': ',num2str(varargin{1}(n,di),'%f')];
    end;
end;

%output_txt={['DI: ',num2str(di+959,'%d')],['Num: ',num2str(di,'%d')],['X: ',num2str(pos(1),'%f')],['Y: ',num2str(pos(2),'%f')]};%+1118
%if length(pos)>2,output_txt{end+1}=['Z: ',num2str(pos(3),'%d')];end;
%output_txt = {['TargetID: ',num2str(round(tr),'%d')],['DI: ',num2str(di,'%d')],['X: ',num2str(pos(1),'%d')],['Y: ',num2str(pos(2),'%f')],num2str(gTraceXY(pos(1),1)),num2str(gTraceXY(pos(1),2))};
%output_txt = {['TargetID: ',num2str(round(tr),'%d')],['DI: ',num2str(di,'%d')],['X: ',num2str(pos(1),'%f')],['Y: ',num2str(pos(2),'%f')]};

%mail@ge0mlib.com 02/10/2017