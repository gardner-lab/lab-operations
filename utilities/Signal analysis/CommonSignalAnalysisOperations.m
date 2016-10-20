% Common signal analysis functions


% Variables:    ephysdata   - time x dim2 x .. array of the signal
%               fs          - signal sampling frequency

% Filtering:

% Band-pass FIR 
% (Example. For more settings options type 'help fdesign.bandpass')
fs = 20e3;
Fst1 = 200;  % The max frequency (Hz) of the low stop band  
Fp1 = 350;   % The min frequency (Hz) of the pass band
Fp2 = 8800;  % The max frequency (Hz) of the pass band
Fst2 = 9300; % The min frequency (Hz) of the high stop band
Ast1 = 60;   % ratio of suppression in low stop band (dB)
Ap = 1;      % Pass band ripple ratio (dB)
Ast2 = 60;   % ratio of suppression in high stop band (dB)
d = fdesign.bandpass('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2',200,350,8800,9300,60,1,60,fs);
Hd = design(d,'equiripple');

% Check the filter design:
%fvtool(Hd); 

% Usage:
t = [0:1/fs:1]';
tone1 = 1234; tone2 = 2345; tone3 = 3456;
x = sin(2*pi*tone1*t) + sin(2*pi*tone2*t) + sin(2*pi*tone3*t);
x = awgn(x,1);
figure; pwelch(x,[],[],[],fs);
filtered = filtfilt(Hd.Numerator,1,x);




