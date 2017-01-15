#!/bin/bash
export SCRIPTSDIR="$(dirname $(realpath $0))"
export BASEDIR="$(realpath $SCRIPTSDIR/..)"
export PLAYGROUNDSDIR="$(realpath $BASEDIR/playgrounds)"
export TEMPLATESDIR="$(realpath $BASEDIR/templates)"
export BUILDPATH="./build"
