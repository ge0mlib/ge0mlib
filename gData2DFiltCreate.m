function wk2=gData2DFiltCreate(wk,a,normFl)
%Create 2D-filter (central symmetric) for using with function gData2DFilt.
%function wk2=gData2DFiltCreate(wk,normFl), where
%wk- uneven 1D vector with filter coefficients (basis for central symmetric 2D-filter, center is the first index);
%normFl- normalization flag; if normFl~=0, than wk2=wk2./sum(wk2);
%wk2- output 2D-filter;
%Example: wk=gausswin(201,3);wk2=gData2DFiltCreate(wk(101:end),1.2,1);imagesc(wk2);wk=gausswin(1001,3);wk2=gData2DFiltCreate(wk(501:end),1.2,1);imagesc(wk2);

Len=numel(wk);
if mod(Len,2)==0,error('Point nmber must be uneven');end
[X,Y]=meshgrid(-Len:Len);r=sqrt((a.*X).^2+Y.^2);wkr=0:Len-1;
wk2=interp1(wkr,wk,r,'linear',0);
if normFl~=0, wk2=wk2./sum(sum(wk2));end

%mail@ge0mlib.com 03/12/2021