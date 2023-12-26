function U=gDataGetInterp(bt,X,Y,keyW,varargin)
%Matrix filtration with 2D-slice-window (includes filter’s coefficients).
%function Data=gData2DFilt(Data,wk,normFl), where
%Data- input matrix;
%wk- 2D filter coefficients;
%normFl- normalization flag; if normFl~=0, than wk=wk./sum(wk);
%Data- output filtered matrix.
%Example: X=zeros(10);X(2,2)=1;h=zeros(7);h(4,4)=1;Data1=gData2DFilt(X,h,0);

if all(ischar(bt)),bt=dlmread(bt);end;
switch keyW
    case 'gWfr' %Grid used for calc
        if (numel(varargin)<1),tmp1='linear';else,tmp1=varargin{1};end; if (numel(varargin)<2),tmp2=NaN;else,tmp2=varargin{2};end;
        s1=abs(bt(2,1)-bt(1,1));if s1==0,s1=abs(bt(2,2)-bt(1,2));end; [M.Head,M.Data]=gWfrXyz2Mat(bt',[0 0 s1 0],[0 0 0 s1]);
        M.x=M.Head.Wf(5)+(0:size(M.Data,2)-1).*M.Head.Wf(1);M.y=M.Head.Wf(6)+(0:size(M.Data,1)-1).*M.Head.Wf(4); [xx,yy]=meshgrid(M.x,M.y);
        U=interp2(xx,yy,M.Data,X,Y,tmp1,tmp2); %imagesc(M.x,M.y,M.Data);colorbar;
    case 'Scatter' %Triangulation used for calc
        if (numel(varargin)<1),tmp1='linear';else,tmp1=varargin{1};end; if (numel(varargin)<2),tmp2='nearest';else,tmp2=varargin{2};end;
        bbt=scatteredInterpolant(bt(:,1),bt(:,2),bt(:,3),tmp1,tmp2);U=bbt(X,Y);
    case 'MinDist' %Minimal distance used for calc
        if (numel(varargin)<1),tmp1=1;else,tmp1=varargin{1};end;
        U=zeros(size(X));
        for n=1:numel(U),[L,I]=min(sqrt((bt(:,1)-X(n)).^2+(bt(:,2)-Y(n)).^2));if L(1)<=tmp1,U(n)=bt(I(1),3);else,U(n)=nan;end;end;
    otherwise,error('Bad key for calculation method');
end;

%mail@ge0mlib.com 06/04/2023