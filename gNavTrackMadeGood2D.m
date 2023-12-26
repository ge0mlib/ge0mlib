function END=gNavTrackMadeGood2D(EN,zwin,rk,figDraw)
%The point's 2D-track smoothing and direction calculation.
%function END=gNavTrackMadeGood2D(EN,zwin,rk,figDraw), where
%EN- rows includes point position;
%zwin- the smoothing window half without one point zwin=(window-1)/2; if zwin=5, than window=11;
%rk- robust coefficient row (usually is rk=[3 2.5]);
%figDraw- figure number for drawing (not drawing if empty);
%END- rows includes [E_new N_new Direction]; smoothing position and direction.
%-----------------------
%The coordinate system:
%^ N or y
%|
%|---> E or x
%Direction - from E left is +
%-----------------------
%Example: END=gNavTrackMadeGood2D([E;N],10,[3 2.5],1);

len=size(EN,2);END=zeros(3,len);
for nn=1:len, %for EN
    fw=nn+zwin;if fw>len, fw=len;end; ew=nn-zwin;if ew<1, ew=1;end;%строим окно под координаты
    xy=(EN(:,ew:fw)-repmat(EN(:,nn),1,fw-ew+1))';%ставим XYю координату окна на 0
    a=atan((xy(end,2)-xy(1,2))./(xy(end,1)-xy(1,1)));if isnan(a), a=0;end;%в а- угол наклона "линии движения", оцениваем по первой и последней точкам координат окна
    for n=1:3,%first approximation
        xy1=xy*[cos(a) -cos(pi/2-a);cos(pi/2-a) cos(a)];
        ab=lscov([xy1(:,1) ones(size(xy1(:,1)))],xy1(:,2));
        a2=atan(ab(1));a=a+a2;
    end;
    a2=1;
    for nnrk=rk,%цикл по коэффициентам робастности
        while abs(a2)>pi/1800000,%в цикле оптимизируем угол наклона до момента, пока рассчитанное приращение угла не станет меньше 0,0001 градуса
            xy1=xy*[cos(a) -cos(pi/2-a);cos(pi/2-a) cos(a)];%поворачиваем окно с координатами на угол а
            %считаем среднеквадратическое отклонение X=LSCOV(A,B) --> B=A*X --> xy1(:,2)=[xy1(:,1) ones(size(xy1(:,1)))]*ab;
            %y=ax+b --> xy1(:,2)=xy1(:,1)*ab(1)+ab(2)
            ab=lscov([xy1(:,1) ones(size(xy1(:,1)))],xy1(:,2));%в ab(1) - угловой коэффициент, в ab(2) - смещение прямой
            a2=atan(ab(1));a=a+a2;%считаем приращение угла, чтобы скомпенсировать угловой коэффициент
            dN=xy1(:,2)-ab(1).*xy1(:,1)+ab(2);L=abs(dN-mean(dN))>std(dN).*nnrk;xy(L,:)=[];%delete deviation more than std*rk
        end;
    end;
    END(1:2,nn)=[EN(1,nn)-ab(2)*cos(pi/2-a);EN(2,nn)+ab(2)*cos(a)];%вычитаем из текущего XY коэффициент b (из y=ax+b), рассчитанный по окну.
    %оцениваем направление движения (первый или третий, второй или четвертый квадратнт для а)
    %вычитаем каждый Х из других, получаем квадратную матрицу, считаем кол-во положительных и отрицательных элементов в треугольных частях
    len1=size(xy1,1); mm=zeros(len1);
    for nnn=1:len1, mm(nnn,:)=xy1(:,1)-xy1(nnn,1);end;
    direct_right=length(find(tril(mm)<0))+length(find(triu(mm)>0));
    direct_left=length(find(tril(mm)>0))+length(find(triu(mm)<0));
    if direct_right<direct_left, a=a+pi;end;
    END(3,nn)=a./pi.*180;
end;

if ~isempty(figDraw),
    figure(figDraw);hold on;
    plot(EN(1,:),EN(2,:),'.r');quiver(END(1,:),END(2,:),cos(END(3,:)./180.*pi),sin(END(3,:)./180.*pi),0.01);
    hold off;
end;

%mail@ge0mlib.com 31/07/2016