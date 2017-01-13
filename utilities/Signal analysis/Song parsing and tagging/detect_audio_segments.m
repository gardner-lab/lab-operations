function res = detect_audio_segments(data,fs,smoothing_time,thr)
% inputs:
% data - a vector containing the audio
% fs - the sampling frequency in Hz
% smoothing_time the time windoe, in ms, used to smooth the data
% thr - the detection threshold in quantile units;

smooth_bins = ceil(fs*smoothing_time/1000);
x = reshape(smooth(detrend(data).^2,smooth_bins),numel(data),1);
x = (x > quantile(x,thr));
x = diff([0; x; 0]);
res = [find(x == 1) find(x==-1)]/fs;
