#!/bin/bash

/usr/bin/time -f "%e" -o $1.bench docker pull $1 && docker image rm $1
/usr/bin/time -f "%e" -o $1.bench -a docker pull harbor.domain/cache/$1 && docker image rm harbor.domain/cache/$1
/usr/bin/time -f "%e" -o $1.bench -a docker pull harbor.domain/cache/$1 && docker image rm harbor.domain/cache/$1
