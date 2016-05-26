
[filename, pathname, filterindex] = uigetfile('*.DTA', 'Pick a DTA file');
DTA=DTAread(fullfile(pathname,filename),'\t',0);
titl=DTA{1};
DTA=DTA(2:end);
figure; subplot(2,1,1); loglog(DTA{2}.data(:,3),DTA{2}.data(:,7));
%title(titl);
set(gca,'FontSize',14); ylabel('Amp (\Omega)');
ylim([1e2 10e7]);
xlim([0 1e6])
hold on;
x0=abs(DTA{2}.data(:,3)-1e3);
x0=find(x0==min(x0)); y0=DTA{2}.data(x0,7); x0=DTA{2}.data(x0,3);
line([x0 x0],[1e2 y0],'Color',[0.6 0.6 0.6],'LineStyle','--');
line([1e0 x0],[y0 y0],'Color',[0.6 0.6 0.6],'LineStyle','--');
text(1e0,y0+1e5,num2str(y0));
subplot(2,1,2); semilogx(DTA{2}.data(:,3),DTA{2}.data(:,8));
set(gca,'FontSize',14); ylabel('Phase (deg)'); xlabel('Frequency(Hz)');
ylim([-120 0]);
xlim([0 1e6])