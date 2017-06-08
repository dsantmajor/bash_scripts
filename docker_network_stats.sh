#! /usr/bin/env bash

count_number_networks () {
  docker network ls -q | wc -l
}

echo "Number of Docker Networks : $(count_number_networks)"
