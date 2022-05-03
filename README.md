[![brew formula tests](https://github.com/DLR-TS/homebrew-sumo/actions/workflows/tests.yml/badge.svg)](https://github.com/DLR-TS/homebrew-sumo/actions/workflows/tests.yml)
[![brew publish](https://github.com/DLR-TS/homebrew-sumo/actions/workflows/publish.yml/badge.svg)](https://github.com/DLR-TS/homebrew-sumo/actions/workflows/publish.yml)
[![example tests](https://github.com/DLR-TS/homebrew-sumo/actions/workflows/example_tests.yml/badge.svg)](https://github.com/DLR-TS/homebrew-sumo/actions/workflows/example_tests.yml)

# Homebrew Tap for SUMO

This tap allows you to install [SUMO](https://www.eclipse.org/sumo/) with [Homebrew](https://brew.sh/) on macOS.
For more information on Brew Taps, see https://docs.brew.sh/Taps.

## Requirements

If you want to use `sumo-gui` and/or `netedit`, you need to install XQuartz as a requirement:

    brew install --cask xquartz

## Install

    brew tap dlr-ts/sumo
    brew install sumo

## Upgrade from older SUMO versions installed with Homebrew

    brew upgrade sumo

## Usage

By default, the above command lines install a bottled SUMO stable version (currently ```1.13.0```) with minimal requirements (```fox```, ```proj```, ```xerces-c```).
Alternatively, ```brew``` can compile SUMO from source with the following command line options:


    brew install [OPTIONS] sumo
    
    ==> Options
    --with-examples
        Install docs/examples and docs/tutorial folder
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
        Install HEAD version (latest developer version of sumo)

## Homebrew Cask for macOS app bundles (optional)

If you would like to have a little more integration with macOS, you can also install the following app bundles (created with macOS Automator) to the `/Applications` folder:

 * `SUMO GUI.app` (sumo-gui)
 * `Netedit.app` (netedit)
 * `OSM Web Wizard.app` (osm-web-wizard)

Install with:

    brew install --cask sumo-gui

## Troubleshooting

If you encounter any problems, please first check your ```brew``` installation (also see [Homebrew Troubleshooting](https://docs.brew.sh/Troubleshooting)):

    brew update
    brew update
    brew doctor

Any persisting problems with the SUMO Brew Formula should be reported directly to the [eclipse/sumo issue tracker](https://github.com/eclipse/sumo/issues).

Some common problems and their fixes have been documented here:

https://sumo.dlr.de/docs/Installing.html#macos_troubleshooting
