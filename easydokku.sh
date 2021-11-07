#! /bin/bash

# Using tput will eliminate the usage of "-e" in echo, and can be used anywhere
RED="$(tput setaf 1)" # ${RED}
GREEN="$(tput setaf 2)" # ${GREEN}
YELLOW="$(tput setaf 3)" # ${YELLOW}
BLUE="$(tput setaf 6)" # ${BLUE}
END="$(tput setaf 7)" # ${END}

function select_option {

    # little helpers for terminal print control and key input
    ESC=$( printf "\033")
    cursor_blink_on()  { printf "$ESC[?25h"; }
    cursor_blink_off() { printf "$ESC[?25l"; }
    cursor_to()        { printf "$ESC[$1;${2:-1}H"; }
    print_option()     { printf "   $1 "; }
    print_selected()   { printf "  $ESC[7m $1 $ESC[27m"; }
    get_cursor_row()   { IFS=';' read -sdR -p $'\E[6n' ROW COL; echo ${ROW#*[}; }
    key_input()        { read -s -n3 key 2>/dev/null >&2
                         if [[ $key = $ESC[A ]]; then echo up;    fi
                         if [[ $key = $ESC[B ]]; then echo down;  fi
                         if [[ $key = ""     ]]; then echo enter; fi; }

    # initially print empty new lines (scroll down if at bottom of screen)
    for opt; do printf "\n"; done

    # determine current screen position for overwriting the options
    local lastrow=`get_cursor_row`
    local startrow=$(($lastrow - $#))

    # ensure cursor and input echoing back on upon a ctrl+c during read -s
    trap "cursor_blink_on; stty echo; printf '\n'; exit" 2
    cursor_blink_off

    local selected=0
    while true; do
        # print options by overwriting the last lines
        local idx=0
        for opt; do
            cursor_to $(($startrow + $idx))
            if [ $idx -eq $selected ]; then
                print_selected "$opt"
            else
                print_option "$opt"
            fi
            ((idx++))
        done

        # user key control
        case `key_input` in
            enter) break;;
            up)    ((selected--));
                   if [ $selected -lt 0 ]; then selected=$(($# - 1)); fi;;
            down)  ((selected++));
                   if [ $selected -ge $# ]; then selected=0; fi;;
        esac
    done

    # cursor position back to normal
    cursor_to $lastrow
    printf "\n"
    cursor_blink_on

    return $selected
}

function select_opt {
    select_option "$@" 1>&2
    local result=$?
    echo $result
    return $result
}

function funIstallDokku() # Don't forget to retrace back properly, not configured yet
{
    while true; 
        do
        # array=("Manual" "Something Else")
        echo "${BLUE}Do you want to Install Dokku?${END}"
        echo ""
        options=("Yes" "No" "${array[@]}") # join arrays to add some variable array
        case `select_opt "${options[@]}"` in
            0)
                echo "${YELLOW}Downloading Dokku from its Official Repository${END}"
                wget https://raw.githubusercontent.com/dokku/dokku/v0.24.10/bootstrap.sh
                wait
                sudo DOKKU_TAG=v0.24.10 bash bootstrap.sh &
                process_id=$!
                wait $process_id
                echo "Exit status: $?";;
            1) 
                echo "Skipping manual dokku update checks";;
            *) 
                echo "selected ${options[$?]}";;
        esac
    done
}

function funSetup() # Added Color # New Update v2
{
    cf=$1
    carry=$2
    iam=funSetup
    clear
    echo "${YELLOW}What type of setup do you prefer?${END}"
    echo ""
    options=("Step by Step Setup" "Advanced Setup" "Back" "${array[@]}") # join arrays to add some variable array
    case `select_opt "${options[@]}"` in
        0) funSBS $iam $carry ;;
        1) funAdv $iam $carry ;;
        2) $cf $iam $carry ;;            
        *) echo "selected ${options[$?]}";;
    esac
}

function funBack() #added color #New Update v2
{
    cf=$1
    carry=$2
    clear
    iam=funBack
    echo "${YELLOW}Where do you want to Jump${END}"
    echo ""
    options=("Intro" "Choose the type of Setup" "${array[@]}") # join arrays to add some variable array
    case `select_opt "${options[@]}"` in
        0) funIntro $iam $carry ;;
        1) funSetup $iam $carry ;;            
        *) echo "selected ${options[$?]}";;
    esac
}

function funSBS() # Added Color #New Update v2
{
    cf=$1
    carry=$2
    clear
    echo "${YELLOW}You are in Step by Step App Creation,${END}${RED} Follow along!${END}"
    echo ""
    iam=funSBS
    options=("Automatic" "Skip To" "Back" "${array[@]}") 
    case `select_opt "${options[@]}"` in
        0) funOneway $iam $carry ;;
        1) 
            clear
            echo "${YELLOW}Skip to a Particular Section${END}"
            echo ""
            echo "${RED}Redirecting to Advanced setup!!!${END}"
            echo ""
            options=("Apps" "Plugins" "Database" "BuildPacks" "Others" "Back" "${array[@]}")
            case `select_opt "${options[@]}"` in
                0) funApps $iam $carry ;;
                1) funPlugins $iam $carry ;;
                2) funDatabase $iam $carry ;;
                3) funBuildpacks $iam $carry ;;
                4) funOthers $iam $carry ;;
                5) funBack $iam $carry ;;         
                *) echo "selected ${options[$?]}";;
            esac ;;
        2) funBack $iam $carry ;;            
        *) echo "selected ${options[$?]}";;
    esac
}

function funAdv()
{
    cf=$1
    carry=0
    clear
    iam=funAdv
    echo "Skip to a Particular Section"
    echo ""
    echo "Redirecting to Advanced setup!!!"
    echo ""
    select skip in "Apps" "Plugins" "Database" "BuildPacks" "Others" "Back"
    do 
        case $skip in
        "Apps")
            funApps $iam $carry;;
        "Plugins")
            funPlugins $iam $carry ;;
        "Database")
            funDatabase $iam $carry ;;
        "BuildPacks")
            funBuildpacks $iam $carry ;;
        "Others")
            funOthers $iam $carry ;;
        "Back")
            funBack $iam $carry ;;
        *)
            echo "Press Enter For available Options" ;;
        esac
    done
}

function funIntro() #Added Color
{
    cf=$1
    carry=$2
    clear
    iam="funIntro"
    echo "${BLUE}..........Please read this carefull before Moving Forward...........${END}"
    echo ""
    cat << foremIntro
    Presently this script offers "Two Important Fucntions".
    1. Automatic (Step by Step Insatllation)
    2. Manual (Advanced)
    
    => Advanced/Manual version is nothing but a cli-GUI version for Dokku

    => The Automatic script is written keeping beginners in mind, 
       So every Automatic Script works like an Q & A session. 
       At the start of Automatic script you can see a prompt of prerequisites.
       Assuring that you know all prerequsites will make it easy to install.

foremIntro
    echo "${BLUE}..........................End of Intro................................${END}"
    echo ""
    echo "${YELLOW}Press any key to continue...${END}"
    while [ true ]
    do
        read -r -t 10 -n 1 # reminds once in every 10 seconds
    if [ $? = 0 ] # pressing any key will trigger this then statement
    then 
        funSetup $iam $carry # Changing function
    else
        echo "${RED}waiting for the response!!!${END}"  # As there is no response, the else part of the if loop is activate in while 
    fi
    done
}

function funApps()
{
    cf=$1
    carry=$2
    iam=funApps
    clear
    echo "App Configuration Menu"
    echo ""
    if [ $carry -eq 1 ] # Forem Automatic Setup
    then
        echo "Automatic Setup"
        dokku apps:create forem # 01: creating app
    else   
        echo "Manual Setup! Will be updates soon"
    fi
}

function funPlugins()
{
    cf=$1
    carry=$2
    iam=funPlugins
    clear
    echo "Plugins Configuration Menu"
    echo ""
    if [ $carry -eq 1 ] 
    then
        echo "Automatic Setup"
    else   
        echo "Manual Setup! Will be updates soon"
    fi 
}

function funDatabase()
{
    cf=$1
    carry=$2
    iam=funDatabase
    clear
    echo "Database Configuration Menu"
    echo ""
    if [ $carry -eq 1 ] 
    then
        echo "Automatic Setup"
    else   
        echo "Manual Setup! Will be updates soon"
    fi 
}

function funBuildpacks()
{
    cf=$1
    carry=$2
    iam=funBuildpacks
    clear
    echo "Buildpacks Configuration Menu"
    echo ""
    if [ $carry -eq 1 ] 
    then
        echo "Automatic Setup"
    else   
        echo "Manual Setup! Will be updates soon"
    fi
}

function funOthers()
{
    clear
    echo "Miscellaneous"
    echo ""    
}

function funError()
{
    clear
    echo "Checking for previous Error cache!"
    echo "If found I might Need Root Access to purge it!"
    sleep 3
    clear
    danger=error.txt
    if [[ -f $danger ]]
    then
        echo "Found an Error File, What do you want to DO?"
        select back in "View and Delete" "Delete and Proceed"
        do 
            case $back in
            "View and Delete")
                echo ""
                cat error.txt
                echo ""
                echo "Press any key to delete the Error file and continue..."
                while [ true ]
                do
                    read -t 3 -n 1 # reminds once eevry 3 seconds
                if [ $? = 0 ] # pressing any key will trigger this if loop within while loop
                then
                    echo "Deleting the Error file"
                    sudo rm -r $danger
                    echo "Deleted"
                    sleep 3
                    funIntro dokku
                else
                    echo "waiting for the response!!!"  # As there is no response, the else part of the if loop is activate in while 
                fi
                done;;
            
            "Delete and Proceed")
                echo "Deleting the Error file"
                sudo rm -r $danger 
                echo "Deleted"
                sleep 3
                funIntro dokku;;
            
            *)
                clear
                echo "Press Enter For available Options";;
            esac
        done
    else   
        echo "No Error file :)"
        sleep 3
        funSetup dokku
    fi
}

function funUpdate()
{
    echo "Updating Dokku"
    echo "Entering into dokku user and predefined "
    echo ""
}

function funChecks()
{
    echo "Confirm that the user is Dokku"
    echo "Confirm that the Dokku is in latest Version"
    echo "Confirm that executable file is in the right place"
    echo "Display the ongoing services and ask to close them"
    echo "At the end give a option for fresh start"
}

function funEnv()
{
    echo -n "Name of the App: "
    read app_name
    clear
    
    echo -n "APP_DOMAIN: (reuired)"
    read $APP_DOMAIN

    echo -n "APP_DOMAIN: "
    read $APP_DOMAIN
    dokku config:set $app_name --no-restart APP_DOMAIN=$APP_DOMAIN
}

function funForem() # Added Color # Manual ENV varibales
{
    cf=$1
    carry=$2
    iam=funForem
    echo "${YELLOW}This is Forem Automatic Setup${END}"
    echo ""
    while true; do
        read -r -p "${BLUE}Do you wish to Update the System?${END} (Y/N): " answer
        case $answer in
            [Yy]* )
                echo "${YELLOW}Updating System${END}"
                sudo dpkg --configure -a
                sudo apt -y --purge autoremove
                sudo apt install -f
                sudo apt -y update
                wait
                echo "${YELLOW}Upgrading System${END}"
                sudo apt -y upgrade
                sudo apt -y autoclean
                sudo apt -y --purge autoremove &
                process_id=$!
                wait $process_id
                echo "Exit status: $?"; 
                break;;
            [Nn]* ) 
                break;;
            * ) 
                echo "${RED}Please answer Y or N.${END}";;
        esac
    done
    
    while true; do
        read -r -p "${BLUE}Do you wish to Update the Dokku?${END} (Y/N): " answer
        case $answer in
            [Yy]* )
                echo "${YELLOW}Upgrading Dokku${END}"
                sudo apt-get -y update -qq
                wait
                sudo apt-get -qq -y --no-install-recommends install dokku herokuish sshcommand plugn gliderlabs-sigil dokku-update dokku-event-listener
                wait
                sudo apt -y upgrade &
                process_id=$!
                wait $process_id
                echo "Exit status: $?"; 
                break;;
            [Nn]* )
                break;;
            * )
                echo "${RED}Please answer Y or N.${END}";;
        esac
    done

    echo "${BLUE}Please Make Sure you have these Pre Requisites${END}"
    echo ""
    cat << foremIntro
    In order for you to have a successful Forem Installaton;
    
    1. Point you DNS to the IP address of this server. (A Record)
    2. You need to Fetch the below mentioned ENV Variables:
        APP_DOMAIN (app.example.com)
        APP_PROTOCOL (https://)
        COMMUNITY_NAME
        FOREM_OWNER_SECRET (don't forget this)
        HONEYBADGER_API_KEY (to create one: https://www.honeybadger.io/)
        HONEYBADGER_JS_API_KEY (same as HONEYBADGER_API_KEY)
        AWS_ID 
        AWS_SECRET
        AWS_BUCKET_NAME (s3 bucket name)
        AWS_UPLOAD_REGION (Preferable to create a bucket in your server region)
    3. Other ENV variables will be configured by the t2d(Talk to Dokku) script.

foremIntro

    echo "Once you have all the ENV Variables;${YELLOW} Press any key to continue...${END}"
    while [ true ]
    do
        read -r -t 10 -n 1 # reminds once in every 10 seconds
    if [ $? = 0 ] # pressing any key will trigger this then statement
    then 
        break # Changing function
    else
        echo "${GREEN}It's good that you are fetching your ENV Variables${END}"  # As there is no response, the else part of the if loop is activate in while 
    fi
    done
    
    while true; do
        read -r -p "${BLUE}Do you wish create a New App?${END} (Y/N): " answer
        case $answer in
            [Yy]* )
                echo "${YELLOW}Creating an app named nforem${END}"
                echo "stopping all previously automatically created Forems"
                echo "${GREEN}No need to worry if you find something like Error!${END}"
                dokku ps:stop nforem
                wait
                echo "Destroying all previously created Forems except 1"
                echo "${GREEN}No need to worry if you find something like Error!${END}"
                dokku apps:destroy oforem
                wait
                echo "Creating a new nforemENV.txt"
                echo "List of Automatically created ENV variables" >> nforemENV.txt
                echo "Saving one old forem with name oforem"
                echo "${GREEN}No need to worry if you find something like Error!${END}"
                dokku apps:rename nforem oforem
                wait
                echo "Creating our new Forem with name nforem"
                dokku apps:create nforem
                echo ""; 
                break;;
            [Nn]* )
                break;;
            * )
                echo "${RED}Please answer Y or N.${END}";;
        esac
    done
    
    while true; do
        read -r -p "${BLUE}Do you wish to Add Necessary Plugins?${END} (Y/N): " answer
        case $answer in
            [Yy]* )
                echo "${YELLOW}Installing Postgress Plugin${END}"
                sudo dokku plugin:install https://github.com/dokku/dokku-postgres.git
                wait
                echo "${YELLOW}Installing Redis Plugin${END}"
                sudo dokku plugin:install https://github.com/dokku/dokku-redis.git
                wait
                echo "${YELLOW}Installing LetsEncrypt Plugin${END}"
                sudo dokku plugin:install https://github.com/dokku/dokku-letsencrypt.git &
                process_id=$!
                wait $process_id
                echo "Exit status: $?"; 
                break;;
            [Nn]* )
                break;;
            * )
                echo "${RED}Please answer Y or N.${END}";;
        esac
    done
    
    while true; do
        read -r -p "${BLUE}Do you wish to create New Databases?${END} (Y/N): " answer
        case $answer in
            [Yy]* )
                echo "${YELLOW}Creating Postgresdb${END}"
                dokku postgres:create foremdb
                wait
                echo "${YELLOW}Creating Redisdb${END}"
                dokku redis:create redisdb
                wait
                echo "${YELLOW}Linking Postgresdb${END}"
                dokku postgres:link foremdb nforem
                wait
                echo "${YELLOW}Linking Redisdb${END}"
                dokku redis:link redisdb nforem &
                process_id=$!
                wait $process_id
                echo "Exit status: $?"; 
                break;;
            [Nn]* )
                break;;
            * )
                echo "${RED}Please answer Y or N.${END}";;
        esac
    done
    
    while true; do
        read -r -p "${BLUE}Do you wish to Add necessary Buildpacks?${END} (Y/N): " answer
        case $answer in
            [Yy]* )
                echo "${YELLOW}Adding NodeJS BuildPack${END}"
                dokku buildpacks:add nforem https://github.com/heroku/heroku-buildpack-nodejs.git
                wait
                echo "${YELLOW}Adding JEMalloc Buildpack${END}"
                dokku buildpacks:add nforem https://github.com/gaffneyc/heroku-buildpack-jemalloc
                wait
                echo "${YELLOW}Adding PGBouncer Buildpack${END}"
                dokku buildpacks:add nforem https://github.com/heroku/heroku-buildpack-pgbouncer.git
                wait
                echo "${YELLOW}Adding Ruby Buildpack${END}"
                dokku buildpacks:add nforem https://github.com/heroku/heroku-buildpack-ruby.git
                echo ""; 
                break;;
            [Nn]* )
                break;;
            * )
                echo "${RED}Please answer Y or N.${END}";;
        esac
    done
    
    while true; do
        read -r -p "${BLUE}Do you wish to Optimise your Forem?${END} (Y/N): " answer
        case $answer in
            [Yy]* )
                echo "${YELLOW}Scaling${END}"
                dokku ps:scale nforem web=1 sidekiq_worker=1
                wait
                echo "${YELLOW}Limiting Webworker Memory to 512M${END}"
                dokku resource:limit --memory 512m --process-type web nforem
                wait
                echo "${YELLOW}Limiting Sidekiq Memory to 512M${END}"
                dokku resource:limit --memory 512m --process-type sidekiq_worker nforem
                wait
                echo "${YELLOW}Setting up Optimisation ENV Variables${END}"
                dokku config:set nforem --no-restart MALLOC_ARENA_MAX=2 JEMALLOC_ENABLED=true WEB_CONCURRENCY=2 RUBY_GC_HEAP_GROWTH_FACTOR=1.03 PGBOUNCER_PREPARED_STATEMENTS=false DATABASE_POOL_SIZE=5 RAILS_MAX_THREADS=5 
                wait
                echo "${YELLOW}Making Forem Production Ready...${END}"
                dokku config:set nforem --no-restart NODE_ENV=production RACK_ENV=production RACK_ENV=production SECRET_KEY_BASE=63e667bd35d7f7045e00de11cf9e115e67a560fac03a6be056c3e4e07bd6b7c974bee249c29abd794ab18c9bf661bce861945dafa31275f409ca0a82a3cae0ab
                wait
                echo "${YELLOW}Initializing git${END}"
                dokku git:initialize nforem
                echo ""; 
                break;;
            [Nn]* )
                break;;
            * )
                echo "${RED}Please answer Y or N.${END}";;
        esac
    done
    
    while IFS= true; do # "IFS="" helps me capture spaces in ENV variables, will be helpful in some COMMUNITY_NAME
        echo "${RED}Y => Yes, N => NO, M => Manual${END}"
        read -r -p "${BLUE}Do you wish Add/Update ENV Variables?${END} (Y/N/M): " answer
        case $answer in
            [Yy]* )
                echo "${YELLOW}Make sure every thing is correct${END}"
                for ENV in APP_DOMAIN APP_PROTOCOL COMMUNITY_NAME FOREM_OWNER_SECRET HONEYBADGER_API_KEY HONEYBADGER_JS_API_KEY AWS_ID AWS_SECRET AWS_BUCKET_NAME AWS_UPLOAD_REGION
                do
                    read -r -p "$ENV = " ENV_VALUE
                    dokku config:set nforem --no-restart $ENV="$ENV_VALUE"
                    wait
                    echo "$ENV=$ENV_VALUE" >> nforemENV.txt
                done
                echo "${GREEN}You can check the list of ENV variables in nfoemENV.txt${END}"
                sleep 3;
                break;;
            [Nn]* )
                break;;
            [Mm]* )
                while true; do
                    read -r -p "${YELLOW}    Do you wish to manually add a new ENV varibale?${END} (Y/N): " answer
                    case $answer in
                        [Yy]* )
                                read -r -p "${GREEN}    Name of ENV Varibale:${END} " ENV 
                                read -r -p "${GREEN}    Value of $ENV =${END} " ENV_VALUE
                                dokku config:set nforem --no-restart $ENV="$ENV_VALUE"
                                # echo "    $ENV=$ENV_VALUE"
                                wait
                                echo "$ENV=$ENV_VALUE" >> nforemENV.txt ;;
                        [Nn]* )
                            echo "${YELLOW}    I hope you finished adding all your ENV varibales${END}"
                            echo "${RED}    Exited... Manual ENV Varibale Setup${END}"
                            break;;
                        * )
                            echo "${RED}Please answer Y or N.${END}";;
                    esac
                done
                break;;
            * )
                echo "${RED}Please answer Y or N or M.${END}";;
        esac
    done
    
    while true; do
        read -r -p "${BLUE}Do you wish to add SSL?${END} (Y/N): " answer
        case $answer in
            [Yy]* )
                echo "${YELLOW}Let's Encrypt Need to access your ${RED}Domain${END} and ${RED}Email${END}, so provide them for free SSL"
                sleep 4
                read -r -p "${BLUE}Domain Name:${END} " DOMAIN
                read -r -p "${BLUE}Email-ID: ${END}" EMAIL
                echo ""
                echo "${YELLOW}Assigning a Free SSL Certificate${END}"
                dokku domains:set nforem $DOMAIN
                wait
                dokku config:set nforem DOKKU_LETSENCRYPT_EMAIL=$EMAIL
                wait
                dokku letsencrypt:enable nforem &
                process_id=$!
                wait $process_id
                echo "Exit status: $?"; 
                break;;
            [Nn]* )
                break;;
            * )
                echo "${RED}Please answer Y or N.${END}";;
        esac
    done

    while true; do
        read -r -p "${BLUE}Clone Repository and Build Forem:${END}(Y/N) " answer
        case $answer in
            [Yy]* )
                dokku git:allow-host github.com
                wait
                dokku git:set nforem deploy-branch main
                wait
                dokku git:sync --build nforem https://github.com/ddos-devs/forem.git &
                process_id=$!
                wait $process_id
                echo "Exit status: $?";
                echo "${GREEN}There you go :), Leave a like if you successfully configured your Forem${END}" 
                exit;;
            [Nn]* )
                exit;;
            * )
                echo "${RED}Please answer Y or N.${END}";;
        esac
    done
}

function funWordpress()
{
    cf=$1
    carry=$2
    iam=funWordpress
    echo "This is Wordpress"
}

function funGhost()
{
    cf=$1
    carry=$2
    iam=funGhost
    echo "This is Ghost"
}

function funOpenVPN()
{
    cf=$1
    carry=$2
    iam=funOpenVPN
    echo "This is OpenVPN"
}

function funCommento()
{
    cf=$1
    carry=$2
    iam=funCommento
    echo "This is Commento"
}

function funOneway()
{
    cf=$1
    carry=1
    iam=funOneway
    clear
    echo "${YELLOW}For now we have only one pre-configured app: ${GREEN}Forem${END}"
    echo ""
    options=("Forem" "Wordpress" "Ghost" "OpenVPN" "Commento" "Back" "${array[@]}") # join arrays to add some variable array
    case `select_opt "${options[@]}"` in
        0) funForem $iam $carry ;;
        1) funWordpress $iam $carry ;;
        2) funGhost $iam $carry ;;
        3) funOpenVPN $iam $carry ;;
        4) funCommento $iam $carry ;;
        5) funBack $iam $carry ;;    
        *) echo "selected ${options[$?]}";;
    esac
}

function funAddENV() # A small script to manually add a ENV variables
{
    read -r -p "Name of ENV Varibale: " ENV 
    read -r -p "Value of $ENV = " ENV_VALUE
    echo "$ENV=$ENV_VALUE" 
}

funIntro dokku
