#! /usr/bin/env bash

count_number_networks () {
  docker network ls -q | wc -l
}

count_number_networks
