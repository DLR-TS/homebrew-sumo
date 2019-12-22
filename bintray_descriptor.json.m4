{
    "package": {
        "name": "sumo",
        "repo": "bottles-sumo",
        "subject": "dlr-ts",
        "website_url": "https://projects.eclipse.org/projects/technology.sumo",
        "issue_tracker_url": "https://github.com/eclipse/sumo/issues",
        "vcs_url": "https://github.com/eclipse/sumo",
        "licenses": ["EPL-2.0"]
    },

    "version": {
        "name": "VERSION_NAME",
        "released": "VERSION_RELEASED",
        "vcs_tag": "VERSION_TAG"
    },

    "files": [
        {"includePattern": "\./(sumo.*\.bottle\.tar\.gz)", "uploadPattern": "$1"}
    ],

    "publish": true
}
