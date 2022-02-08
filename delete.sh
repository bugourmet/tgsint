
hrexit () {
    read -rn1 -p "Press any key to continue..." && exit $1
}

# checking prerequisites
which bash > /dev/null 2>&1 || { echo -e "${RED}ERR: bash not found!!${NC}"; hrexit 3; }
which docker-compose > /dev/null 2>&1 || { echo -e "${RED}ERR: docker-compose not found!!${NC}"; hrexit 3; }

DOCKER='docker'
[[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]] && DOCKER="winpty docker"

docker-compose down

read -r -p "Are you sure you want to delete all projects? [Y/n] " response
response=$(echo "$response" | awk '{print tolower($0)}') # tolower
if [[ $response =~ ^(yes|y| ) ]] || [[ -z $response ]]; then
    rm -fr tgsint-api tgsint-bot tgsint-scripts
fi

read -r -p "Are you sure you want to .env? [Y/n] " response
response=$(echo "$response" | awk '{print tolower($0)}') # tolower
if [[ $response =~ ^(yes|y| ) ]] || [[ -z $response ]]; then
    rm -f .env
fi