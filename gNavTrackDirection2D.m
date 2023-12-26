function END=gNavTrackDirection2D(EN,rk,figDraw)
%The 2D-track "direction" calculate (track approximated by line).
%function END=gNavTrackDirection2D(EN,rk,figDraw), where
%EN- rows includes point position;
%rk- robust coeff row (multipurpose is rk=[3 2.5]);
%figDraw- figure number for drawing (not drawing if empty);
%END- rows includes direction information for two points [E1 N1 Direction;E2 N2 Direction]'.
%-----------------------
%The coordinate system:
%^ N or y
%|
%|---> E or x
%Direction - from E left is +
%-----------------------
%Example: E=[1 2 3 4 5];N=[1 3 3 5 6];END=gNavTrackDirection2D([E;N],[3 2.5],1);
%The algorithm used in gNavTrackMadeGood2D

xy=(EN-repmat(EN(:,1),1,size(EN,2)))';%ставим 1ю координату окна на 0
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
END=zeros(3,2);
END(1:2,1)=[EN(1,1)-ab(2)*cos(pi/2-a);EN(2,1)+ab(2)*cos(a)];%вычитаем из первой координаты коэффициент b (из y=ax+b), рассчитанный по окну.
%оцениваем направление движения (первый или третий, второй или четвертый квадратнт для а)
%вычитаем каждый Х из других, получаем квадратную матрицу, считаем кол-во положительных и отрицательных элементов в треугольных частях
len1=size(xy1,1); mm=zeros(len1);
for nnn=1:len1, mm(nnn,:)=xy1(:,1)-xy1(nnn,1);end;
direct_right=length(find(tril(mm)<0))+length(find(triu(mm)>0));
direct_left=length(find(tril(mm)>0))+length(find(triu(mm)<0));
if direct_right<direct_left, a=a+pi;end;
END(3,:)=a./pi.*180;
r=max(abs((EN(1,:)-EN(1,1))+(EN(2,:)-EN(2,1))*1i));dr=r(1)*exp(END(3)./180.*pi*1i);
END(1:2,2)=END(1:2,1)+[real(dr);imag(dr)];

if ~isempty(figDraw),
    figure(figDraw);hold on;
    plot(EN(1,:),EN(2,:),'.r');quiver(END(1,1),END(2,1),real(dr),imag(dr),1);
    hold off;
end;

%mail@ge0mlib.com 31/07/2016