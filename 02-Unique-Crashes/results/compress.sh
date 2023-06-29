#!/bin/bash

find -name "queue" -exec tar -czvf {}.tar.gz {} \;
