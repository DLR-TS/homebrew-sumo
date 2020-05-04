[![Build Test Status](https://travis-ci.org/dlr-ts/homebrew-sumo.svg?branch=master)](https://travis-ci.org/dlr-ts/homebrew-sumo)

# Homebrew Tap for SUMO

This tap allows you to install [SUMO](https://projects.eclipse.org/projects/technology.sumo) with [Homebrew](https://brew.sh/) on macOS.
For more information on Brew Taps, see https://docs.brew.sh/Taps.

## Install

    brew tap dlr-ts/sumo
    brew install sumo

## Upgrade from older SUMO versions installed with Homebrew

    brew upgrade sumo

## Usage

By default, the above command lines install a bottled SUMO stable version (currently ```1.6.0```) with minimal requirements (```fox```, ```proj```, ```xerces-c```).
Alternatively, ```brew``` can compile SUMO from source with the following command line options:


    brew install [OPTIONS] sumo
    
    ==> Options
    --with-ffmpeg
        Build with ffmpeg support
    --with-gdal
        Build with gdal support
    --with-gl2ps
        Build with gl2ps support
    --with-open-scene-graph
        Build with open-scene-graph support
    --with-swig
        Build with swig support
    --HEAD
        Install HEAD version


## Troubleshooting

If you encounter any problems, please first check your ```brew``` installation (alse see [Homebrew Troubleshooting](https://docs.brew.sh/Troubleshooting)):

    brew update
    brew update
    brew doctor

Any persisting problems with the SUMO Brew Formula should be reported directly to the [eclipse/sumo issue tracker](https://github.com/eclipse/sumo/issues).
