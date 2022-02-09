#!/bin/bash

# checking prerequisites
which bash > /dev/null 2>&1 || { echo -e "${RED}ERR: bash not found!!${NC}"; hrexit 3; }
which git > /dev/null 2>&1 || { echo -e "${RED}ERR: git not found!!${NC}"; hrexit 3; }
which docker > /dev/null 2>&1 || { echo -e "${RED}ERR: docker not found!!${NC}"; hrexit 3; }
which docker-compose > /dev/null 2>&1 || { echo -e "${RED}ERR: docker-compose not found!!${NC}"; hrexit 3; }

DOCKER='docker'
[[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]] && DOCKER="winpty docker"

docker-compose up
