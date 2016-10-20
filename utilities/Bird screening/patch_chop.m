targetbase = '/Users/SongScreening/Documents/songdata/';
cd(targetbase);
a = dir;
dirs = [a.isdir];
a = a(dirs == 1);
a = a(cellfun(@(x) strcmp(x,'.'),{a.name})+cellfun(@(x) strcmp(x,'..'),{a.name}) == 0);

for dirnum=1:numel(a)
    cd(a(dirnum).name);
    b = dir;
    dirs = [b.isdir];
    b = b(dirs == 1);
    b = b(cellfun(@(x) strcmp(x,'.'),{b.name})+cellfun(@(x) strcmp(x,'..'),{b.name}) == 0);
    for dirnum2=1:numel(b)
        cd(b(dirnum2).name);
        if (~isempty(dir('*.wav')))
            zftftb_song_chop(pwd, 'song_duration', 0.65, 'audio_pad', 0.2, 'song_ratio', 2.8, 'song_len', .05); %'song_thresh', 0.2
            delete('*.wav'); 
        end
        cd ..
    end
    cd ..
end