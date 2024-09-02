#!/bin/bash

/usr/bin/time -f "%e" -o benchmarks/$1.bench sudo docker pull $1 &&
    sudo docker image ls $1 --format "{{.Size}}" >> benchmarks/$1.bench &&
    sudo docker image rm $1
/usr/bin/time -f "%e" -o benchmarks/$1.bench -a sudo docker pull harbor.domain/cache/$1 && sudo docker image rm harbor.domain/cache/$1
/usr/bin/time -f "%e" -o benchmarks/$1.bench -a sudo docker pull harbor.domain/cache/$1 && sudo docker image rm harbor.domain/cache/$1
