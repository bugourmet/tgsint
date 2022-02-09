#!/bin/bash

hrexit () {
    read -rn1 -p "Press any key to continue..." && exit $1
}

# checking prerequisites
which bash > /dev/null 2>&1 || { echo -e "${RED}ERR: bash not found!!${NC}"; hrexit 3; }
which git > /dev/null 2>&1 || { echo -e "${RED}ERR: git not found!!${NC}"; hrexit 3; }
which docker > /dev/null 2>&1 || { echo -e "${RED}ERR: docker not found!!${NC}"; hrexit 3; }
which docker-compose > /dev/null 2>&1 || { echo -e "${RED}ERR: docker-compose not found!!${NC}"; hrexit 3; }

DOCKER='docker'
[[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]] && DOCKER="winpty docker"

docker-compose down

echo "Updating TGSINT API..."
cd tgsint-api 
BRANCH=$(git name-rev --name-only HEAD)
git pull origin $BRANCH && cd .. || { echo "ERR: Pulling TGSINT API failed!!"; hrexit 11; }

echo "Updating TGSINT BOT..."
cd tgsint-bot
BRANCH=$(git name-rev --name-only HEAD)
 git pull origin $BRANCH && cd .. || { echo "ERR: Pulling TGSINT BOT failed!!"; hrexit 11; }

docker-compose up --build -d
docker-compose down
