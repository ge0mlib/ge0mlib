function p=gMapPickHandleNan(X,Y,f)
%Set to Nan points for polyline using manual piking tools.
%function p=gMapPickHandleNan(X,Y,f), where
%X,Y- rows with polyline coordinates;
%f- figure number or pointer to figure;
%p- pointer to polyline; a=get(p,'Ydata') - get Y-coordinate with NaN; a=get(p,'UserData') - get logical mask where true is ~NaN.
%There are two picking tools:
% 1) rectangle (first button at added panel) -- set to nan all points in selected rectangle;
% 2) curve_part (second button at added panel) -- set to nan all points in selected curve's part.
%Point at curve set using minimal distance from mouse-click, distance calculate for current axis-scale (axis not equal).
%There can create several independent "picking tools" at one figure for different curves.
%Mouse&key:
%LeftMouseButton - first selection element (first part of rectangle or first point at curve);
%RightMouseButton - second selection element (second part of rectangle or second point at curve);
%MiddleMouseButton - set to NaN points in selected area (to nan set Y-coordinate value);
%q- exit from edit mode; a- undo; s- redo.
%Example:
%s=gMapPickHandleNan(HGps.GpsLat,HGps.GpsLon,100);a=get(s,'Ydata');a=get(s,'UserData');

if isnumeric(f), fp=figure(f);else,fp=f;end;
tbh=findall(fp,'Type','uitoolbar');
Ic=ones(16,16,3);Ic(4,:,1:2)=0;Ic(:,4,1:2)=0;Sq=uitoggletool(tbh,'CData',Ic,'Separator','off','HandleVisibility','off','OnCallback',@gMapNanSqButton);
Ic=ones(16,16,3);Ic(8:9,:,1:2)=0;Ic(:,8:9,1:2)=0;Pt=uitoggletool(tbh,'CData',Ic,'Separator','off','HandleVisibility','off','OnCallback',@gMapNanPtButton);
dcm_obj=datacursormode(fp);set(dcm_obj,'UpdateFcn',@gMapNanTipsTxt);

XX=X;YY=Y; hold on;plot(X,Y,'-b');p=plot(XX,YY,'+r');hold off;
minX=min(X);maxX=max(X);minY=min(Y);maxY=max(Y);x2s=maxX;x1s=minX;y2s=minY;y1s=maxY;ns=0;nmaxs=0;Ls={};
L1s=line([minX x2s x2s],[y2s y2s maxY],'Color','k','LineStyle','--');L2s=line([maxX x1s x1s],[y1s y1s minY],'Color','k','LineStyle','--');
n1p=1;n2p=1;np=0;nmaxp=0;Lp={};
fll=0;L1p=[];L2p=[];%L1p=line(X(n1p:n2p),Y(n1p:n2p),'Color','y','Marker','o');L2p=line(X(n1p),Y(n1p),'Color','k','Marker','*');
tax=findall(fp,'Type','axes');
set(p,'UserData',~isnan(YY));

function gMapNanSqButton(~,~)
    hold on;set(Pt,'Enable','off'); k='+';
    while (k~='q'), [xi,yi,k]=ginput(1);if isempty(k),k='+';end;
        switch k
            case 1, x1s=xi;y1s=yi;set(L2s,'Xdata',[maxX x1s x1s],'Ydata',[y1s y1s minY]);
            case 2, ns=ns+1;nmaxs=ns; Ls{ns}=find((XX>=x1s)&(XX<=x2s)&(YY>=y2s)&(YY<=y1s)); YY(Ls{ns})=nan;set(p,'Ydata',YY);
            case 3, x2s=xi;y2s=yi;set(L1s,'Xdata',[minX x2s x2s],'Ydata',[y2s y2s maxY]);
            case 'a',if ns>0,YY(Ls{ns})=Y(Ls{ns});set(p,'Ydata',YY);ns=ns-1;end;
            case 's',if ns<nmaxs,ns=ns+1;YY(Ls{ns})=nan;set(p,'Ydata',YY);end;
        end;
    end;
    set(p,'UserData',~isnan(YY)); hold off;set(Sq,'State','off');set(Pt,'Enable','on');
end

function gMapNanPtButton(~,~)
    if fll==0, L1p=line(X(n1p:n2p),Y(n1p:n2p),'Color','y','Marker','o');L2p=line(X(n1p),Y(n1p),'Color','k','Marker','*');fll=1;end;
    hold on;set(Sq,'Enable','off'); k='+';
    while (k~='q'), [xi,yi,k]=ginput(1);if isempty(k),k='+';end;
        switch k
            case 1, rr=get(tax,'DataAspectRatio');r=((X-xi).*rr(2)).^2+((Y-yi).*rr(1)).^2; n1p=find(r==min(r),1,'first');set(L1p,'Xdata',X(n1p:n2p),'Ydata',Y(n1p:n2p),'Color','y');set(L2p,'Xdata',X(n1p),'Ydata',Y(n1p),'Color','k');
            case 2, if n1p<=n2p, np=np+1;nmaxp=np; Lp{np}=find(~isnan(YY(n1p:n2p)))+n1p-1; YY(Lp{np})=nan;set(p,'Ydata',YY);end;
            case 3, rr=get(tax,'DataAspectRatio');r=((X-xi).*rr(2)).^2+((Y-yi).*rr(1)).^2; n2p=find(r==min(r),1,'last');set(L1p,'Xdata',X(n1p:n2p),'Ydata',Y(n1p:n2p),'Color','y');
            case 'a',if np>0, YY(Lp{np})=Y(Lp{np});set(p,'Ydata',YY);np=np-1;end;
            case 's',if np<nmaxp, np=np+1;YY(Lp{np})=nan;set(p,'Ydata',YY);end;
        end;
    end;
    set(p,'UserData',~isnan(YY)); hold off;set(Pt,'State','off');set(Sq,'Enable','on');
end

function output_txt=gMapNanTipsTxt(~,event_obj)
    %Display the position of the tips cursor // obj - Currently not used (empty) // event_obj - Handle to event object // output_txt - Data cursor text string (string or cell array of strings).
    pos=get(event_obj,'Position');di=get(event_obj,'DataIndex');%tr=get(event_obj,'Target');['TargetID: ',num2str(round(tr),'%d')],
    output_txt={['X: ',num2str(pos(1),'%d')],['Y: ',num2str(pos(2),'%d')],['N: ',num2str(di,'%d')]};
    if length(pos)>2,output_txt{end+1}=['Z: ',num2str(pos(3),'%d')];end;
end

end

%mail@ge0mlib.com 21/03/2023