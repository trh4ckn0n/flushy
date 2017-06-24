#!/bin/bash


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

cd
echo

if [[ "$OSTYPE" == "linux-gnu" ]]; then
echo
echo -e $(print_status "Detected Kali Linux, I will install bettercap ...")
echo
sudo apt-get install build-essential ruby-dev libpcap-dev
apt-get update
apt-get install bettercap
echo
echo -e $(print_good 'Successfully installed bettercap ! You can now run : "sudo bash flushy.sh"')
echo
elif [[ "$OSTYPE" == "darwin"* ]]; then
if which nmap >/dev/null; then
echo -e $(print_good "Nmap is already installed")
else
echo -e $(print_error 'Nmap is required to use Flushy unless you dont use the Scan option. If you want to install it, please refer to this installation page : https://nmap.org/book/inst-macosx.html')
fi
if [ -d "bettercap" ]; then
echo -e $(print_good "Bettercap is already installed")
echo
echo -e $(print_good 'You can now run : "sudo bash flushy.sh"')
echo
elif [ ! -d "bettercap" ]; then
echo -e $(print_error 'Bettercap is not installed')
echo -e $(print_status "Installing it ...")
	if which git >/dev/null; then
echo -e $(print_good "Git is installed")
gem install packetfu -v 1.1.11
git clone https://github.com/evilsocket/bettercap
cd bettercap
gem build bettercap.gemspec
sudo gem install bettercap*.gem
echo
echo -e $(print_good 'Successfully installed bettercap ! You can now run : "sudo bash flushy.sh"')
echo
else 
echo -e $(print_error '"Git" is not installed')
	echo 'Please refer to this page to install "Git" : http://sourceforge.net/projects/git-osx-installer/'
	echo 'Aborting ...'
	exit 1
fi
else
if which bettercap >/dev/null; then
echo -e $(print_good "Bettercap is already installed")
echo
echo -e $(print_good 'You can now run : "sudo bash flushy.sh"')
echo
else 
echo -e $(print_error 'Bettercap is not installed')
echo -e $(print_status 'Installing it ...')
	if which git >/dev/null; then
echo -e $(print_good '"Git" is installed')
gem install packetfu -v 1.1.11
git clone https://github.com/evilsocket/bettercap
cd bettercap
gem build bettercap.gemspec
sudo gem install bettercap*.gem
echo
echo -e $(print_good 'Successfully installed bettercap ! You can now run : "sudo bash flushy.sh"')
echo
else 
echo -e $(print_error '"Git" is not installed')
	echo 'Please refer to this page to install "Git" : http://sourceforge.net/projects/git-osx-installer/'
	echo 'Aborting ...'
	exit 1
fi
fi
fi
fi