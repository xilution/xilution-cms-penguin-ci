#!/bin/bash

# shellcheck disable=SC2046
kill $(cat tiller.pid)
rm -rf tiller.pid
