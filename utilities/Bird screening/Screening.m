targetbase = '/Users/SongScreening/Documents/songdata/';
cd(targetbase);
basedir = '/Volumes/recording/';
if (~exist(basedir))
    error('Not connected to base directory');
else
    load birds_to_screen;
    for birdnum = 1:size(birds_to_screen,1)
        birdname = birds_to_screen{birdnum,2};
        boxnum = birds_to_screen{birdnum,1};
        wavdir = [basedir num2str(boxnum) '-WAV/'];
        imgdir = [basedir num2str(boxnum) '-IMG/'];
        targetdir = [targetbase birdname];
        if exist(wavdir)
            wavfiles = dir([wavdir '*.wav']);
            for fnum=1:numel(wavfiles);
                dt = wavfiles(fnum).name(12:21); %date is taken from file name to avoid relying on the file's time stamp
                dt(dt=='.')='-';
                if (datenum(dt) >= datenum(birds_to_screen{birdnum,3})) %wavfiles(fnum).datenum
                    if ~exist([targetdir '/' dt])
                        mkdir([targetdir '/' dt]);
                    end
                    movefile(fullfile(wavdir,wavfiles(fnum).name),[targetdir '/' dt]);
                    delete(fullfile(imgdir,[wavfiles(fnum).name(1:end-3) 'jpg']));
                end
            end
     
        else
            error(['Directory ' wavdir ' does not exist']);
        end
    end
end
    