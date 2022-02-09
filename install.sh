#!/bin/bash

ENV=./.env

hrexit () {
    read -rn1 -p "Press any key to continue..." && exit "$1"
}

# loading env
if [[ ! -f "$ENV" ]]; then
    read -p ".env not found do you want to use default .env [Y/n] " yn
    yn=$(echo "$yn" | awk '{print tolower($0)}')
    if [[ $yn =~ ^(yes|y| ) ]] || [[ -z $yn ]]; then
        cp .env.example $ENV
    else
        echo "create .env file and try agian"
        hrexit 2
    fi
fi

ed -s $ENV <<< w > /dev/null 2>&1
while read -r line; do eval "$line";  done < $ENV

# checking prerequisites
which bash > /dev/null 2>&1 || { echo -e "${RED}ERR: bash not found!!${NC}"; hrexit 3; }
which git > /dev/null 2>&1 || { echo -e "${RED}ERR: git not found!!${NC}"; hrexit 3; }
which docker > /dev/null 2>&1 || { echo -e "${RED}ERR: docker not found!!${NC}"; hrexit 3; }
which docker-compose > /dev/null 2>&1 || { echo -e "${RED}ERR: docker-compose not found!!${NC}"; hrexit 3; }

if [[ "$OSTYPE" == "linux-gnu" ]]
then
    HOSTS_PATH=$NIX_HOSTS_PATH
elif [[ "$OSTYPE" == "darwin"* ]]
then
    HOSTS_PATH=$OSX_HOSTS_PATH
elif [[ "$OSTYPE" == "cygwin" ]]
then
    HOSTS_PATH=$WIN_HOSTS_PATH
    # running wimpty bash so it can create tty
    DOCKER="winpty docker"
elif [[ "$OSTYPE" == "msys" ]]
then
    HOSTS_PATH=$WIN_HOSTS_PATH
    # running wimpty bash so it can create tty
    DOCKER="winpty docker"
elif [[ "$OSTYPE" == "win32" ]]
then
    HOSTS_PATH=$WIN_HOSTS_PATH
elif [[ "$OSTYPE" == "freebsd"* ]]
then
    HOSTS_PATH=$NIX_HOSTS_PATH
else
    { echo -e "${RED}ERR: unknown OS!!${NC}"; hrexit 1; }
fi

echo "Cloning TGSINT API..."
git clone -b $TGSINT_API_BRANCH $TGSINT_API_GIT \
    || { echo -e "${YELLOW}Failed to clone from git vie SSH key, trying with HTTPS...${NC}"; git clone -b $TGSINT_API_BRANCH $TGSINT_API_GIT_HTTPS; } \
    || { echo -e "${RED}ERR: Failed to clone TGSINT API!!${NC}"; hrexit 11; }
echo -e "${GREEN}TGSINT API cloned${NC}"

echo "Cloning TGSINT BOT..."
git clone -b $TGSINT_BOT_BRANCH $TGSINT_BOT_GIT \
    || { echo -e "${YELLOW}Failed to clone from git vie SSH key, trying with HTTPS...${NC}"; git clone -b $TGSINT_BOT_BRANCH $TGSINT_BOT_GIT_HTTPS; } \
    || { echo -e "${RED}ERR: Failed to clone TGSINT BOT!!${NC}"; hrexit 11; }
echo -e "${GREEN}TGSINT BOT cloned${NC}"

echo "Cloning TGSINT Scripts..."
git clone -b $TGSINT_SCRIPTS_BRANCH $TGSINT_SCRIPTS_GIT \
    || { echo -e "${YELLOW}Failed to clone from git vie SSH key, trying with HTTPS...${NC}"; git clone -b $TGSINT_SCRIPTS_BRANCH $TGSINT_SCRIPTS_GIT_HTTS; } \
    || { echo -e "${RED}ERR: Failed to clone TGSINT Scripts!!${NC}"; hrexit 11; }
echo -e "${GREEN}TGSINT Scripts cloned${NC}"

echo "Configuring TGSINT BOT..."
cd tgsint-bot
if [[ ! -f "$ENV" ]]; then
    read -p ".env not found do you want to use example .env [Y/n] " yn
    yn=$(echo "$yn" | awk '{print tolower($0)}')
    if [[ $yn =~ ^(yes|y| ) ]] || [[ -z $yn ]]; then
        cp .env.example $ENV
        read -rn1 -p "Edit .env file in tgsint-env and press any key to continue..."
    else
        touch $ENV

        read -p "Enter shodan API key (Default:\"${DEFAULT_SHODAN_API_KEY}\") [Optional] " shodan
        if [[ -z $yn ]]; then
            shodan_env="SHODAN_API_KEY=\"${DEFAULT_SHODAN_API_KEY}\""
        else 
            shodan_env="SHODAN_API_KEY=\"${shodan}\""
        fi
        echo "$shodan_env" >> $ENV

        read -p "Enter securitytrails API key (Default:\"${DEFAULT_SCTRAILS_API_KEY}\") [Optional] " securitytrails
        if [[ -z $yn ]]; then
            securitytrails_env="SCTRAILS_API_KEY=\"${DEFAULT_SCTRAILS_API_KEY}\""
        else 
            securitytrails_env="SCTRAILS_API_KEY=\"${securitytrails}\""
        fi
        echo "$securitytrails_env" >> $ENV

        read -p "Enter bot token (Default:\"${DEFAULT_BOT_TOKEN}\") [Required] " bot_token
        if [[ -z $yn ]]; then
            bot_token_env="BOT_TOKEN=\"${DEFAULT_BOT_TOKEN}\""
        else 
            bot_token_env="BOT_TOKEN=\"${bot_token}\""
        fi
        echo "$bot_token_env" >> $ENV

        read -p "Enter API url (Default:\"${DEFAULT_API_URL}\") [Required] " api_url
        if [[ -z $yn ]]; then
            api_url_env="API_URL=\"${DEFAULT_API_URL}\""
        else 
            api_url_env="API_URL=\"${api_url}\""
        fi
        echo "$api_url_env" >> $ENV

        read -p "Enter Telegram users separated by \"|\" (Default:\"${DEFAULT_USERS}\") [Required] " users
        if [[ -z $yn ]]; then
            users_env="USERS=\"${DEFAULT_USERS}\""
        else 
            users_env="USERS=\"${users}\""
        fi
        echo "$users_env" >> $ENV
    fi
    echo -e "${GREEN}TGSINT BOT configured${NC}"
fi
cd ..

echo "Configuring TGSINT API..."
cd tgsint-api
if [[ ! -f "$ENV" ]]; then
    read -p ".env not found do you want to use example .env [Y/n] " yn
    yn=$(echo "$yn" | awk '{print tolower($0)}')
    if [[ $yn =~ ^(yes|y| ) ]] || [[ -z $yn ]]; then
        cp .env.example $ENV
        read -rn1 -p "Edit .env file in tgsint-env and press any key to continue..."
    else
        read -p "Enter mongodb url (Default:\"${DEFAULT_DBCONNECTIONURL}\") [Required] " mongo
        if [[ -z $yn ]]; then
            mongo_env="DBCONNECTIONURL=\"${DEFAULT_DBCONNECTIONURL}\""
        else 
            mongo_env="DBCONNECTIONURL=\"${mongo}\""
        fi
        echo "$mongo_env" >> $ENV
    fi
    echo -e "${GREEN}TGSINT BOT configured${NC}"
fi
cd ..

docker-compose up -d
docker-compose down
