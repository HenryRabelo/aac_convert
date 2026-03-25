<div align="center">

# Auto AAC Converter
### Batch and single file conversion of local audio files purchased from stores like Bandcamp
[![Linux Badge](https://img.shields.io/badge/Made_for_Linux-black?logo=linux&logoColor=black&labelColor=white)](https://distrowatch.com/dwres.php?resource=popularity)
[![Digital Library Badge](https://custom-icon-badges.demolab.com/badge/Digital_Library-E4342B?logo=disc&logoSource=feather&logoColor=E4342B&labelColor=white)](https://feathericons.com/)
[![MusicBrainz Badge](https://img.shields.io/badge/MusicBrainz-BA478F?logo=musicbrainz&logoColor=white)](https://developer.android.com/studio)
#

[![Intro Badge](https://img.shields.io/badge/Intro-151515)](#introduction) <sup> **•** </sup>
[![Run it Badge](https://img.shields.io/badge/Run_it-151515)](#how-to-run-it) <sup> **•** </sup>
[![Use it Badge](https://img.shields.io/badge/Use_it-151515)](#how-to-use-it) <sup> **•** </sup>
[![Disclaimer Badge](https://img.shields.io/badge/Disclaimer-151515)](#disclaimer)

</div>

### Introduction
This script was made to simplify converting local audio files purchased from stores such as Bandcamp to the MPEG-4 standard and open format of the AAC codec, as designed under the Fraunhofer model.

It can convert single files or batch convert multiple files, and in the case of batch conversion, it will mirror the directory structure of the input directory to the output directory. It also tries to decrease the size of the existing cover image embedded on the metadata of each file and embed the downsized cover art to the converted file. Not only that, it will try to check whether there are any image or text files to ignore, though it would be best to point the input directory to one that contains audio files only. The script will deliver the converted file on a MPEG-4 Audio container, with the extension `.m4a`.

To function properly this script requires a version of FFMPEG that was compiled with the flag to enable the libfdk_aac codec, which is usually disabled due to licensing. The Jellyfin project uses one such version.

<div align="center">
  <img src=".assets/images/picture.png" alt="Demonstration of the '--help' command" width="400" align="center"/>
</div>

> ###### Dependencies:
> For this script to run, it depends on a version of `ffmpeg` compiled with the flag to enable the libfdk_aac codec.

### How to Run it
To run the script, first build or download the compiled version of ffmpeg from a repository and into a directory in your run path, then give it `executable` permission:
```sh
# First download the specific version of ffmpeg from a repository
curl -o ~/.local/bin/ffmpeg https://example.com/ffmpeg
chmod +x ~/.local/bin/ffmpeg
```

Now give `executable` permission to this script file and once again put it in a directory in your run path. After this, it can be run as a command:
```sh
chmod +x $(pwd)/aac-convert
cp $(pwd)/aac-convert ~/.local/bin/aac-convert

aac-convert --help
```

###### Examples of the command syntax:
```sh
# Go to whichever directory you intend:
cd Music

# For a single file conversion:
aac-convert --file song.flac

# For a batch conversion of a directory named Albums to a new one named Converted:
aac-convert --batch Albums Converted
```

### How to Use it
You can use this script to mirror your original lossless music library into a lighter format, mainly to be used on devices with limited storage space. The script will not touch the original files other than to read and copy their contents and metadata.

##
> ###### Disclaimer:
> This software is meant to be used only on music files obtained as a result of a purchase, in a licensed online store. Please, do not use it on files that infringe copyright law. Thanks :)
> 
> This software is offered as is, and I do not take responsibility for it's misuse.
##

<div align="center">

[![Back to the Top Badge](https://custom-icon-badges.demolab.com/badge/Back_to_the_Top-151515?logo=chevron-up)](#auto-aac-converter)

</div>
