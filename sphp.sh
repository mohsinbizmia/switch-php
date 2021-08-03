#!/bin/bash
# Came from https://github.com/alirza143/virtualhost-generator
# @author: Ali Raza
# @Email: ali.rza143@gmail.com

GREEN=$(echo -en '\033[00;32m');
RESTORE=$(echo -en '\033[0m');
YELLOW=$(echo -en '\033[01;33m');
RED=$(echo -en '\033[01;31m');

if ! [ $(id -u) = 0 ]; then
   echo "${RED}The script need to be run as root${RESTORE}${GREEN} (Hint: Run with sudo).${RESTORE}" >&2;
   exit 1;
fi;

if [ $SUDO_USER ]; then
    real_user=$SUDO_USER;
else
    real_user=$(whoami);
fi;

CHECK_TERMINAL_PHP_VERSION=`php -v|grep ^PHP|cut -d' ' -f2 2>&1`;
PHP_CURRENT_VERSION=$(echo "$CHECK_TERMINAL_PHP_VERSION" | cut -c1-3);

PHP_VERSIONS=('7.1' '7.2' '7.3' '7.4' '8.0');
declare -a a=();
for i in "${PHP_VERSIONS[@]}";
do :;
	PHP_V="php$i-cli";
	PHP_SEARCH=$(dpkg -l|awk -v pattern="$PHP_V" '$2 ~ pattern { print $3 }');
	
	if [ -n $PHP_SEARCH ];
		
	ALL_VERSIONS=$(echo "$PHP_SEARCH" | cut -c1-3);
		then
			a+=($ALL_VERSIONS)
	fi;
done;

for key in ${!a[@]}; do
    
    	if [[ " ${a[${key}]} " == *" ${PHP_CURRENT_VERSION} "* ]]; 
    	then
    		echo "${key} : ${GREEN}${a[${key}]} (active)${RESTORE}";
    	else 
    		echo "${key} : ${GREEN}${a[${key}]}${RESTORE}";
    	fi;
done




echo "PHP Current Version in ${GREEN}$PHP_CURRENT_VERSION${RESTORE}";


switch_version(){
	EN_MOD=`a2dismod php$PHP_CURRENT_VERSION`;
	EN_MOD=`a2enmod php$1`;
	SERVICE_CHECK=`service apache2 restart`;
	read -r -p "Switched to PHP ${GREEN}$1${RESTORE}, do you want to switch PHP version in the terminal also [y/N]:" answer;
	if [ "$answer" != "${answer#[Yy]}" ] ;then
		UPDATE_VERSION=`update-alternatives --set php /usr/bin/php$1`;
		SERVICE_CHECK=`service apache2 restart`;
		RECHECK_TERMINAL_PHP_VERSION=`php -v|grep ^PHP|cut -d' ' -f2 2>&1`;
		echo "Ok, switched to ${GREEN}$RECHECK_TERMINAL_PHP_VERSION${RESTORE}";
	else
		echo "Switched!"
	fi
}

get_input() {
    read -r -p "Enter the corresponding number to switch PHP version: " SWITCH_PHP_VERSION;
    if [ -n "$SWITCH_PHP_VERSION" ];
	then 
    	if [[ -v a[$SWITCH_PHP_VERSION] ]];
    		then switch_version  ${a[SWITCH_PHP_VERSION]} ;
    	else echo "${RED}Try Again!${RESTORE}" ;
    	get_input ; 
    	fi;
    else echo "${YELLOW}Ok, skipped!${RESTORE}";
	fi;
}
get_input ;  
