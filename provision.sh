#!/usr/bin/env bash

echo "=============================="
echo "System update and packages cleanup"
echo "=============================="
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
sudo echo grub-pc hold | sudo dpkg --set-selections
sudo DEBIAN_FRONTEND=noninteractive apt-get -y update
sudo DEBIAN_FRONTEND=noninteractive apt-get -y upgrade

echo "=============================="
echo "Install useful packages"
echo "=============================="
sudo apt install haveged curl git unzip zip htop nload nmon ntp bash-completion -y

echo "=============================="
echo "Your username EasyEngine, your email is test@test.test"
echo "=============================="
sudo chown vagrant:vagrant /home/vagrant/.[^.]*
sudo echo -e "[user]\n\tname = EasyEngine\n\temail = test@test.test" > ~/.gitconfig

echo "=============================="
echo "Install EasyEngine"
echo "=============================="
sudo wget -qO ee cdk.app/ee
sudo bash ee || exit 1

echo "=============================="
echo "Install Nginx, php7.0 and configure EE backend"
echo "=============================="
sudo ee stack install --php7 --mysql || exit 1
sudo yes | sudo ee site create 0.test --php7 --mysql
sudo echo -e "[user]\n\tname = EasyEngine\n\temail = test@test.test" > ~/.gitconfig
sudo yes | sudo ee site delete 0.test

echo "=============================="
echo "Install Composer - Fix phpmyadmin install issue"
echo "=============================="
cd ~/
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/bin/composer

echo "=============================="
echo "Install php7.1 and php7.2 with EasyEngine"
echo "=============================="
 # php7.1-fpm
sudo apt update && sudo apt install php7.1-fpm php7.1-cli php7.1-zip php7.1-opcache php7.1-mysql php7.1-mcrypt php7.1-mbstring php7.1-json php7.1-intl \
php7.1-gd php7.1-curl php7.1-bz2 php7.1-xml php7.1-tidy php7.1-soap php7.1-bcmath -y
# php7.2 fpm
sudo apt update && sudo apt install php7.2-fpm php7.2-xml php7.2-bz2  php7.2-zip php7.2-mysql  php7.2-intl php7.2-gd php7.2-curl php7.2-soap php7.2-mbstring -y
 # php7.1-fpm pool configuration
sudo wget -O /etc/php/7.1/fpm/pool.d/www.conf https://raw.githubusercontent.com/VirtuBox/ubuntu-nginx-web-server/master/etc/php/7.1/fpm/pool.d/www.conf
sudo service php7.1-fpm restart
# php7.2-fpm pool configuration
sudo wget -O /etc/php/7.2/fpm/pool.d/www.conf https://raw.githubusercontent.com/VirtuBox/ubuntu-nginx-web-server/master/etc/php/7.2/fpm/pool.d/www.conf
sudo service php7.2-fpm restart
# nginx upstream configuration
sudo wget -O /etc/nginx/conf.d/upstream.conf https://raw.githubusercontent.com/VirtuBox/ubuntu-nginx-web-server/master/etc/nginx/conf.d/upstream.conf
# EasyEngine common nginx configurations
cd /etc/nginx/common
sudo wget https://raw.githubusercontent.com/VirtuBox/ubuntu-nginx-web-server/master/common.zip
sudo unzip -o common.zip
sudo wget -O /etc/nginx/conf.d/webp.conf  https://virtubox.github.io/ubuntu-nginx-web-server/files/etc/nginx/conf.d/webp.conf
sudo service nginx reload

echo "=============================="
echo "Allow shell for www-data for SFTP usage"
echo "=============================="
sudo usermod -s /bin/bash www-data

echo "=============================="
echo "Wordmove installation"
echo "=============================="
if [ $(gem -v|grep '^2.') ]; then
	echo "gem installed"
else
	sudo apt-get install ruby2.5 -y
fi
wordmove_install="$(gem list wordmove -i)"
if [ "$wordmove_install" = true ]; then
  echo "wordmove installed"
else
  echo "wordmove not installed"
  sudo gem install wordmove
  wordmove_path="$(gem which wordmove | sed -s 's/.rb/\/deployer\/base.rb/')"
  if [  "$(grep yaml $wordmove_path)" ]; then
    echo "can require yaml"
  else
    echo "can't require yaml"
    echo "set require yaml"
    sudo sed -i "7i require\ \'yaml\'" $wordmove_path
    echo "can require yaml"
  fi
fi

echo "=============================="
echo "bash-snippets - https://github.com/alexanderepstein/Bash-Snippets"
echo "=============================="
cd ~/
git clone https://github.com/alexanderepstein/Bash-Snippets
cd Bash-Snippets
git checkout v1.22.0
sudo ./install.sh cheat

echo "=============================="
echo "nanorc - Improved Nano Syntax Highlighting Files"
echo "=============================="
wget https://raw.githubusercontent.com/scopatz/nanorc/master/install.sh -O- | sh

echo "=============================="
echo "wp cli - ianstall and add bash-completion for user www-data"
echo "=============================="
# wp-cli install
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
php wp-cli.phar --info
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp
wp --info
# automatically generate the security keys
wp package install aaemnnosttv/wp-cli-dotenv-command --allow-root
# download wp-cli bash_completion
sudo wget -O /etc/bash_completion.d/wp-completion.bash https://raw.githubusercontent.com/wp-cli/wp-cli/master/utils/wp-completion.bash
# change /var/www owner
sudo chown www-data:www-data /var/www
# download .profile & .bashrc for www-data
sudo wget -O /var/www/.profile https://raw.githubusercontent.com/VirtuBox/ubuntu-nginx-web-server/master/docs/files/var/www/.profile
sudo wget -O /var/www/.bashrc https://raw.githubusercontent.com/VirtuBox/ubuntu-nginx-web-server/master/docs/files/var/www/.bashrc

# set owner
sudo chown www-data:www-data /var/www/.profile


echo "=============================="
echo "Downloading: adminer installer - adminer.sh"
echo "=============================="
cd /usr/local/bin && sudo wget https://gist.githubusercontent.com/DimaMinka/9bc8cc1f45a32dfdafd0c270e28af1c8/raw/fc6328f2d8a6a37f6e77916331f0bda8f7649b08/adminer.sh
sudo chmod +x adminer.sh

echo "=============================="
echo "Downloading: search-replace-database installer - srdb.sh"
echo "=============================="
cd /usr/local/bin && sudo wget https://gist.githubusercontent.com/DimaMinka/24c3df57a78dd841a534666a233492a9/raw/d5ca7209164c7a22879fc7863f1bac1f0145ba84/srdb.sh
sudo chmod +x srdb.sh

echo "=============================="
echo "Downloading: zImageOptimizer - zio.sh"
echo "=============================="
cd /usr/local/bin && sudo wget https://raw.githubusercontent.com/zevilz/zImageOptimizer/master/zImageOptimizer.sh
sudo mv zImageOptimizer.sh zio.sh
sudo chmod +x zio.sh

echo "=============================="
echo "Clean before package"
echo "=============================="
sudo DEBIAN_FRONTEND=noninteractive apt-get -y update
sudo DEBIAN_FRONTEND=noninteractive apt-get -y upgrade
sudo apt-get -y autoremove && sudo apt-get clean
export DEBIAN_FRONTEND=newt
cd /home/vagrant && sudo rm -rf ee && rm -- "$0"
#sudo dd if=/dev/zero of=/EMPTY bs=1M
#sudo rm -f /EMPTY
#sudo cat /dev/null > ~/.bash_history && history -c && exit
#sudo shutdown -h now

