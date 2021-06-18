#!/bin/bash

docker run -it --rm $(docker build -q .)
