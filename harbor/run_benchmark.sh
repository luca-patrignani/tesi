#!/bin/bash

images=(hello-world alpine ubuntu fedora postgres mysql)

for image in ${images[@]} ; do
    ./benchmark.sh $image
done

