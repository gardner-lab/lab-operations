function resstruct = AudioSegmentsInDir(DIR,ext,calcfilters)
if isempty(intersect({'wav' 'mov'},ext))
    ext = 'wav';
end
min_song_length = 2; % sec
smooth_window = 0.02; % sec
pad_time = 0.1; %sec
threshold = 0.8;
FS = 44100;
if calcfilters == 1
    d = fdesign.bandpass('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2',1200,1350,5000,5150,60,1,60,FS);
    dl = fdesign.bandpass('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2',100,250,500,650,60,1,60,FS);
    Hd = design(d,'equiripple');
    Hdl = design(dl,'equiripple');
else
    load filters44k;
end

file_list = dir(fullfile(DIR,['*.' ext]));
resstruct = [];
for i=1:numel(file_list)
    [y,fs] = audioread(fullfile(DIR,file_list(i).name));
    len = length(y);
%     if (fs ~= FS)
%         FS = fs;
%         d = fdesign.bandpass('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2',1200,1350,5000,5150,60,1,60,FS);
%         Hd = design(d,'equiripple');
%     end
    mask = smooth_window*fs;
    pad = pad_time*fs;
    y = y/max(abs(y)); 
    filtered = filtfilt(Hdl.Numerator,1,y);
    y = filtfilt(Hd.Numerator,1,y);
    yamp = smooth(y.^2,mask);
    famp = smooth(filtered.^2,mask);
    segments = [0; (yamp > quantile(yamp,threshold)) & (yamp./(famp+1e-6) > 2); 0];
    ups = find(diff(segments) == 1); downs = find(diff(segments) == -1) - 1;
    ups = min(ups + pad,len); downs = max(downs - pad,1);
    for i = 1:numel(ups)
        segments(downs(i):ups(i)) = 1;
    end
    if (sum(segments)/fs > min_song_length)
        resstruct = [resstruct; sum(segments)/fs];
    end
end
    
    
    
    