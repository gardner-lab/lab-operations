# Bird Screening Manual
These small script harness the song chopping capabilities in [zftftb](https://github.com/gardner-lab/zftftb) and perform the required file transfer and cleanup of the recording computer. Note that this script is specific to the recording system described in [our wiki](https://github.com/gardner-lab/lab-operations/wiki/recording-computer-system).
## Adding and removing birds
The .mat file 'birds_to_screen.mat' contains a cell array with the same name with the following 3 columns:
* Box number - This is matching the numbering in the recording room
* Bird name - This name will be used to create folders in the screening computer.
* Start date - All data after this date will be removed from the recording computer. Data that was created prior to this date will not be touched.

To change the birds we're screening, simply change this 'birds_to_screen' variable and save it to the file with the same name in the script's folder.

## Running the script
Simply type ScreenScript in the script's folder.

## Outputs
Files and folders will be created in '/Users/SongScreening/Documents/songdata/'. To change this (in case you're using this code elsewhere) go into the file 'Screening.m' and 'patch_chop.m' and change the targetbase variable.
This is true also if the recording computer folder structure changes and require a deeper dig into Screening.m


