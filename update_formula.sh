#!/bin/bash

################################################
### UPDATES brew sumo formula to new version ###
################################################

FORMULA_NAME=dlr-ts/sumo/sumo
README_FILE=README.md

# check for cmd line parameters
if [ $# -ne 2 ]; then
    echo ""
    echo "Usage: $0 <NEW_VERSION> <SUMO_SRC_URL>"
    echo "Examples:"
    echo "    NEW_VERSION: 1.3.1"
    echo "    SUMO_SRC_URL: https://github.com/eclipse/sumo/archive/v1_3_1.tar.gz"
    echo ""
    exit 1
fi

NEW_VERSION=$1
SUMO_SRC_URL=$2
DATE_STRING=$(date +"%Y-%m-%d")
NEW_MAJOR=$(echo "${NEW_VERSION}" | awk -F . '{ print $1 }')
NEW_MINOR=$(echo "${NEW_VERSION}" | awk -F . '{ print $2 }')
NEW_PATCH=$(echo "${NEW_VERSION}" | awk -F . '{ print $3 }')

### ARCHIVE formula for old version
# make sure most current version of formula is installed
brew uninstall sumo
brew install sumo

# figure out version number
OLD_VERSION_WITH_REVISION=$(brew ls sumo --versions | awk '{print $2}')
OLD_VERSION=$(echo "${OLD_VERSION_WITH_REVISION}" | awk -F _ '{print $1}')
OLD_MAJOR=$(echo "${OLD_VERSION}" | awk -F . '{ print $1 }')
OLD_MINOR=$(echo "${OLD_VERSION}" | awk -F . '{ print $2 }')
OLD_PATCH=$(echo "${OLD_VERSION}" | awk -F . '{ print $3 }')
echo "old sumo version: '$OLD_VERSION'"

# generate full string (including version number) for formula class name
FORMULA_CLASS_NAME="SumoAT$(echo $OLD_VERSION | sed 's/\.//g')"
echo "formula class name: '$FORMULA_CLASS_NAME'"

ARCHIVED_FORMULA_FILENAME="sumo@${OLD_VERSION}.rb"
 
# archive old formula
echo "copying formula to Formula/${ARCHIVED_FORMULA_FILENAME} and updating class name of archived formula..."
sed "s/class Sumo/class ${FORMULA_CLASS_NAME}/" Formula/sumo.rb >> Formula/${ARCHIVED_FORMULA_FILENAME}
echo "done archiving old formula!"

echo "creating git branch"
git checkout -b sumo

echo "adding archived formula to git"
git add Formula/${ARCHIVED_FORMULA_FILENAME}
git commit -m "sumo: archive formula for version ${OLD_VERSION}"

### BUMP formula version (https://docs.brew.sh/Manpage#bump-formula-pr-options-formula)
echo "bumping formula version..."
brew bump-formula-pr -v --write-only --no-audit --url=${SUMO_SRC_URL} ${FORMULA_NAME}
# remove bottle block
# NOTE: dirty hack assumes lines 12-17 (including extra blank line)
sed '12,17d' /usr/local/Homebrew/Library/Taps/dlr-ts/homebrew-sumo/Formula/sumo.rb > Formula/sumo.rb
git add Formula/sumo.rb
git commit -m "sumo: update formula to v${NEW_VERSION}"

### UPDATE alias link
echo "updating Alias symlink..."
git mv Aliases/sumo\@${OLD_MAJOR}.${OLD_MINOR}.${OLD_PATCH} Aliases/sumo\@${NEW_MAJOR}.${NEW_MINOR}.${NEW_PATCH}
git commit -m "sumo: update alias"

### UPDATE version number in README.md
echo "updating version number in README.md"
sed "s/${OLD_VERSION}/${NEW_VERSION}/" ${README_FILE} >> ${README_FILE}.NEW
mv ${README_FILE}.NEW ${README_FILE}
git add ${README_FILE}
git commit -m "update version number in README"

echo "You now need to create a pull request from the new branch to trigger the workflows ..."
# git push --set-upstream origin sumo
