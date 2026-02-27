#!/bin/bash

# TODO: Docstring for activity_session.
# :return:: Docstring for . 
function activity_session() {
    tmux ls | awk -F ':' '{print $1}'
}


