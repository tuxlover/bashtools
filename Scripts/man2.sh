#!/bin/bash

#man2 ist an wrapper script that shows manpages and its outputs in an html browser 

BROWSER=firefox #try other browsers like opera and stuff too
MAN_PAGE=$1

man -H$BROWSER $1 || exit 1

exit 0

#if browser is closed, programm runs anyway