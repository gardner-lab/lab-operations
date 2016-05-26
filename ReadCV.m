[filename, pathname, filterindex] = uigetfile('*.DTA', 'Pick a DTA file');
smth = 5;
a=DTAread(fullfile(pathname,filename),'\t',0);
titl=a{1};
a=a(2:end);
figure;
legnd={};
clrs=parula(numel(a)-1);
for cycnum=2:numel(a)
    plot(a{cycnum}.data(:,3),smooth(a{cycnum}.data(:,4),smth),'Color',clrs(cycnum-1,:));
    hold on;
    legnd{cycnum-1}=['cyc #' num2str(cycnum-1)];
end
set(gca,'FontSize',14); 
ylabel('I (amp)');
xlabel('V vs Ref');
legend(legnd);
colorbar; caxis([1 numel(a)-1])
