#!/bin/bash

clear

banners=( "banner1" "banner2" "banner3" "banner4" )



function banner1 {
echo '    ▄████  █       ▄      ▄▄▄▄▄    ▄  █ ▀▄    ▄ '
echo '    █▀   ▀ █        █    █     ▀▄ █   █   █  █  '
echo '    █▀▀    █     █   █ ▄  ▀▀▀▀▄   ██▀▀█    ▀█   '
echo '    █      ███▄  █   █  ▀▄▄▄▄▀    █   █    █    '
echo '     █         ▀ █▄ ▄█               █   ▄▀     '
echo '      ▀           ▀▀▀               ▀           '
echo ''
}


function banner2 {
echo '  ███████╗██╗     ██╗   ██╗███████╗██╗  ██╗██╗   ██╗'
echo '  ██╔════╝██║     ██║   ██║██╔════╝██║  ██║╚██╗ ██╔╝'
echo '  █████╗  ██║     ██║   ██║███████╗███████║ ╚████╔╝ '
echo '  ██╔══╝  ██║     ██║   ██║╚════██║██╔══██║  ╚██╔╝  '
echo '  ██║     ███████╗╚██████╔╝███████║██║  ██║   ██║   '
echo '  ╚═╝     ╚══════╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝   ╚═╝   '
echo''
}


function banner3 {
	echo '              ______           __         '
	echo '             / __/ /_  _______/ /_  __  __'
	echo '            / /_/ / / / / ___/ __ \/ / / /'
	echo '           / __/ / /_/ (__  ) / / / /_/ / '
	echo '          /_/ /_/\__,_/____/_/ /_/\__, /  '
	echo '                                 /____/   '
	echo ''
}


function banner4 {
echo ''
echo '01100110 01101100 01110101 01110011 01101000 01111001 '
echo '   ┌─       ┬       ┬ ┬      ┌─┐      ┬ ┬      ┬ ┬'
echo '   ├┤       │       │ │      └─┐      ├─┤      └┬┘'
echo '   └        ┴─┘     └─┘      └─┘      ┴ ┴       ┴ '
echo ' 艾 弗     艾 勒     玉     艾 丝    阿 什  伊格黑克 '
echo ''


}


echo 
${banners[RANDOM % ${#banners[@]}]}
echo $'Author : \033[0;34mShellBear\e[0m ║ Github : \033[0;34mgithub.com/shellbear\e[0m'
echo
