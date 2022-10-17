#!/bin/bash
# lazy_buzhibujue.sh

# 检测ip
# 以下内容是废弃案，一开始的思路是截取本机的ip地址，然后获取测试网站的的源码截取解析出来的地区，但是后来发现这样不太实际，因为很多时候机器的 ip 得到的是内网 ip ，遂更换方法。现在使用直接 ping 谷歌的方式判断是否需要配置国内镜像。
# ip=`ip a|grep -w 'inet'|grep 'global'|sed 's/^.*inet //g'|sed 's/\/[0-9][0-9].*$//g'`
# echo $ip
# curl "https://www.ip.cn/ip/$ip.html" -o out
# place=`cat ./out |grep -w '<div id="tab0_address"'|grep '</div>'| sed 's/^.*<div id="tab0_address">//g'`
# echo $place
echo "检测是否国内网络环境..."
sleep 1

echo ''
ping -c 4 -w 10 www.google.com
if [ $? != 0 ]; then
        echo "ping failed."
        echo "判定为国内环境，开始换源。"
        ipflag=1
        sleep 1

        Codename=$(lsb_release -c --short)
        echo "检测到您的Ubuntu系统版本为：$Codename"

        sourceweb='http://mirrors.aliyun.com'

        echo "备份sources.list..."
        sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
        echo "设置新的镜像源..."

        echo "\
        deb http://mirrors.aliyun.com/ubuntu/ $Codename main restricted universe multiverse
        deb-src http://mirrors.aliyun.com/ubuntu/ $Codename main restricted universe multiverse
        deb http://mirrors.aliyun.com/ubuntu/ $Codename-security main restricted universe multiverse
        deb-src http://mirrors.aliyun.com/ubuntu/ $Codename-security main restricted universe multiverse
        deb http://mirrors.aliyun.com/ubuntu/ $Codename-updates main restricted universe multiverse
        deb-src http://mirrors.aliyun.com/ubuntu/ $Codename-updates main restricted universe multiverse
        # deb http://mirrors.aliyun.com/ubuntu/ $Codename-proposed main restricted universe multiverse
        # deb-src http://mirrors.aliyun.com/ubuntu/ $Codename-proposed main restricted universe multiverse
        deb http://mirrors.aliyun.com/ubuntu/ $Codename-backports main restricted universe multiverse
        deb-src http://mirrors.aliyun.com/ubuntu/ $Codename-backports main restricted universe multiverse">/etc/apt/sources.list
        echo "更新源..."
        sudo apt-get update

        echo "更换成功。"
        echo
        echo
        echo "换源完成"            
else
        echo "ping successed."
        echo "判定为国外环境，无需换源。"
fi

# 安装 git 配置 email username

echo "正在安装 git"
sudo apt update
sudo apt install git
read -p "输入你滴名字：" name
git config --global user.name {$name}
read -p "输入你滴邮箱：" edress
git config --global user.email {$edress}
echo "配置成功！"
git config --list

# 安装 zsh && oh-my-zsh

echo "安装zsh咯~"
sudo apt-get install zsh
echo "安装 oh-my-zsh"
echo "安装好后会进入 oh-my-zsh 记得输入exit退出！"
sudo sh -c "$(curl -fsSL https://gitee.com/mirrors/oh-my-zsh/raw/master/tools/install.sh)"

# 设置 ssh 超时时间

echo "ssh链接超时十分钟断开"
sudo sed -i '$a ClientAliveInterval 600' /etc/ssh/sshd_config

# 设置系统代理

if [ "$ipflag" -eq 1]; then
        echo "网络环境为国内环境，配置系统代理"
        echo
        sleep 2

        echo "设置 http 代理，单击回车结束："
        read proxy
        while [ -n "$proxy" ]
        do
                sudo echo "export http_proxy=$proxy" >>/etc/profile
                read proxy
        done

        echo "设置 https 代理，单击回车结束："
        read proxy
        while [ -n "$proxy" ]
        do
                sudo echo "export https_proxy=$proxy" >>/etc/profile
                read proxy
        done
fi

# 切换系统 locale 为中文
localectl set-locale LANG=zh_CN.utf8
localectl set-locale LC_CTYPE=zh_CN.utf8
localectl set-locale LC_TIME=zh_CN.utf8
localectl set-locale LC_COLLATE=zh_CN.utf8
localectl set-locale LC_MONETARY=zh_CN.utf8
localectl set-locale LC_MESSAGES=zh_CN.utf8
localectl set-locale LC_PAPER=zh_CN.utf8
localectl set-locale LC_NAME=zh_CN.utf8
localectl set-locale LC_NAME=zh_CN.utf8
localectl set-locale LC_ADDRESS=zh_CN.utf8
localectl set-locale LC_TELEPHONE=zh_CN.utf8
localectl set-locale LC_MEASUREMENT=zh_CN.utf8
localectl set-locale LC_IDENTIFICATION=zh_CN.utf8
echo "locale 以设置为中文"

# 更新所有软件为最新

sudo apt update && sudo apt -y upgrade
echo "所有软件已经更新到最新！"

# 安装 docker 配置国内镜像

echo "安装 docker "
echo ''
sudo apt-get update
sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get -y update
sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo apt-get install docker-ce=5:20.10.19~3-0~ubuntu-jammy docker-ce-cli=5:20.10.19~3-0~ubuntu-jammy containerd.io docker-compose-plugin
sudo service docker start
sudo docker run hello-world

if [ "$ipflag" -eq 1]; then

        echo "更换国内镜像源"

        touch /etc/docker/daemon.json
        echo "{" >> /etc/docker/daemon.json
        echo '          "registry-mirrors": ["http://hub-mirror.c.163.com"] ' >> /etc/docker/daemon.json
        echo "}" >> /etc/docker/daemon.json
        systemctl restart docker
        docker info
fi

# 安装 nodejs 配置国内镜像

echo "安装 nodejs 配置淘宝镜像"
echo ''

curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
sudo apt-get install -y nodejs

if [ "$ipflag" -eq 1]; then

        npm config set registry https://registry.npm.taobao.org --global
        npm config set disturl https://npm.taobao.org/dist --global
        npm install webpack -g 
        npm webpack -v
fi

# 安装配置 vim

echo "安装 vim 进行简单配置"
echo ''

apt install vim
echo 'set number' >> /etc/vim/vimrc
echo 'set autoindent' >> /etc/vim/vimrc
echo 'set cursorline' >> /etc/vim/vimrc
echo 'set ruler' >> /etc/vim/vimrc
echo 'set tabstop=4' >> /etc/vim/vimrc


echo "-------------------------"
echo ''
echo "一键配置脚本执行完成。"

