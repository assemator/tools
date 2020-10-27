#!/bin/bash

# Wireguard VPN server installation on CentOS 7 VPS
if [ ! -e '/etc/redhat-release' ]; then
echo -e "\e[91m Only support centos7 \e[0m"
exit
fi
if  [ -n "$(grep ' 6\.' /etc/redhat-release)" ] ;then
echo -e "\e[91m Only support centos7 \e[0m"
exit
fi


function isRoot () {
	if [ "$EUID" -ne 0 ]; then
		return 1
	fi
}

function tunAvailable () {
	if [ ! -e /dev/net/tun ]; then
		return 1
	fi
}

function initialCheck () {
	if ! isRoot; then
		echo "Sorry, you need to run this as root"
		exit 1
	fi
	if ! tunAvailable; then
		echo "TUN is not available"
		exit 1
	fi
}


# Update kernel
update_kernel(){

	initialCheck
	yum update -y
    yum -y install epel-release curl nano screen
    sed -i "0,/enabled=0/s//enabled=1/" /etc/yum.repos.d/epel.repo
    yum remove -y kernel-devel
    rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
    rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-4.el7.elrepo.noarch.rpm
    yum --disablerepo="*" --enablerepo="elrepo-kernel" list available
    yum -y --enablerepo=elrepo-kernel install kernel-ml
    sed -i "s/GRUB_DEFAULT=saved/GRUB_DEFAULT=0/" /etc/default/grub
    grub2-mkconfig -o /boot/grub2/grub.cfg
    wget https://elrepo.org/linux/kernel/el7/x86_64/RPMS/kernel-ml-devel-5.9.1-1.el7.elrepo.x86_64.rpm
    rpm -ivh kernel-ml-devel-5.9.1-1.el7.elrepo.x86_64.rpm
    yum -y --enablerepo=elrepo-kernel install kernel-ml-devel
    read -p "VPS need to be restarted, Execute the script again to install wireguard, do you want to restart now? [Y/n] :" yn
	[ -z "${yn}" ] && yn="y"
	if [[ $yn == [Yy] ]]; then
		echo -e "Restarting VPS..."
		reboot
	fi
}

wireguard_update(){
	initialCheck
    yum update -y wireguard-dkms wireguard-tools
    echo -e "\e[92m Update Completed. \e[0m"
}

wireguard_remove(){
	initialCheck
    wg-quick down wg0
	systemctl stop wg-quick@wg0
    systemctl disable wg-quick@wg0
	systemctl stop fail2ban
	systemctl disable fail2ban
    yum remove -y wireguard-dkms wireguard-tools fail2ban
    rm -rf /etc/wireguard/
	rm -rf /etc/fail2ban/jail.local
    echo -e "\e[92m Uninstallation completed. \e[0m"
}

config_client(){
cat > /etc/wireguard/raz_1.conf <<-EOF
[Interface]
# raz_1
PrivateKey = 2NB09y9UXOXu9IqZdGOiTNy5dFUuqXIoNT5VCT+ksFA=
Address = 10.0.0.2/24 
DNS = 1.1.1.1
MTU = 1420

[Peer]
PublicKey = LFpJB+JOgjfq+sdsbh1jnY4eq/FBMk6GzyRcvFhZX2U=
Endpoint = $serverip:$PORT
AllowedIPs = 0.0.0.0/0, ::0/0
PersistentKeepalive = 25
EOF

cat > /etc/wireguard/raz_2.conf <<-EOF
[Interface]
# raz_2
PrivateKey = KEW91ANpQ56tnO2P1eatNuoJtdv6rFH2eMd7EpZXd2o=
Address = 10.0.0.3/24 
DNS = 1.1.1.1
MTU = 1420

[Peer]
PublicKey = LFpJB+JOgjfq+sdsbh1jnY4eq/FBMk6GzyRcvFhZX2U=
Endpoint = $serverip:$PORT
AllowedIPs = 0.0.0.0/0, ::0/0
PersistentKeepalive = 25
EOF

cat > /etc/wireguard/raz_3.conf <<-EOF
[Interface]
# raz_3
PrivateKey = uHfv0oc3xdzT8V2WwNqpk1PrphR7KrWRvle4G0Rr/30=
Address = 10.0.0.4/24 
DNS = 1.1.1.1
MTU = 1420

[Peer]
PublicKey = LFpJB+JOgjfq+sdsbh1jnY4eq/FBMk6GzyRcvFhZX2U=
Endpoint = $serverip:$PORT
AllowedIPs = 0.0.0.0/0, ::0/0
PersistentKeepalive = 25
EOF

cat > /etc/wireguard/tur_1.conf <<-EOF
[Interface]
# tur_1
PrivateKey = 4C5QuuhgrOWTzRcD8q7fskdDFdP1Fm+BlywaGALAz28=
Address = 10.0.0.5/24 
DNS = 1.1.1.1
MTU = 1420

[Peer]
PublicKey = LFpJB+JOgjfq+sdsbh1jnY4eq/FBMk6GzyRcvFhZX2U=
Endpoint = $serverip:$PORT
AllowedIPs = 0.0.0.0/0, ::0/0
PersistentKeepalive = 25
EOF

cat > /etc/wireguard/tur_2.conf <<-EOF
[Interface]
# tur_2
PrivateKey = oJctvTERISYWZkazlyuhMRkA6flQb/UKSpCycJmAE0A=
Address = 10.0.0.6/24 
DNS = 1.1.1.1
MTU = 1420

[Peer]
PublicKey = LFpJB+JOgjfq+sdsbh1jnY4eq/FBMk6GzyRcvFhZX2U=
Endpoint = $serverip:$PORT
AllowedIPs = 0.0.0.0/0, ::0/0
PersistentKeepalive = 25
EOF

cat > /etc/wireguard/nav_1.conf <<-EOF
[Interface]
# nav_1
PrivateKey = gPeOrPiTPSz/yY9Npm2mEgXNEXxCefM/wBMeszmPvWs=
Address = 10.0.0.7/24 
DNS = 1.1.1.1
MTU = 1420

[Peer]
PublicKey = LFpJB+JOgjfq+sdsbh1jnY4eq/FBMk6GzyRcvFhZX2U=
Endpoint = $serverip:$PORT
AllowedIPs = 0.0.0.0/0, ::0/0
PersistentKeepalive = 25
EOF

cat > /etc/wireguard/nav_2.conf <<-EOF
[Interface]
# nav_2
PrivateKey = 6NHmAZ8YTGm63AEInQN2hTp6SzXpesCtRL2HIdAYOVI=
Address = 10.0.0.8/24 
DNS = 1.1.1.1
MTU = 1420

[Peer]
PublicKey = LFpJB+JOgjfq+sdsbh1jnY4eq/FBMk6GzyRcvFhZX2U=
Endpoint = $serverip:$PORT
AllowedIPs = 0.0.0.0/0, ::0/0
PersistentKeepalive = 25
EOF

cat > /etc/wireguard/dede_1.conf <<-EOF
[Interface]
# dede_1
PrivateKey = CDpPESM5t3XgeA+mW66XQukHwWExvh6iO3mCscG0Zng=
Address = 10.0.0.9/24 
DNS = 1.1.1.1
MTU = 1420

[Peer]
PublicKey = LFpJB+JOgjfq+sdsbh1jnY4eq/FBMk6GzyRcvFhZX2U=
Endpoint = $serverip:$PORT
AllowedIPs = 0.0.0.0/0, ::0/0
PersistentKeepalive = 25
EOF

cat > /etc/wireguard/dede_2.conf <<-EOF
[Interface]
# dede_2
PrivateKey = cHY5ANWoW2m2oFKtCRNQ0VP6vcw58bz7203xjVPbO2I=
Address = 10.0.0.10/24 
DNS = 1.1.1.1
MTU = 1420

[Peer]
PublicKey = LFpJB+JOgjfq+sdsbh1jnY4eq/FBMk6GzyRcvFhZX2U=
Endpoint = $serverip:$PORT
AllowedIPs = 0.0.0.0/0, ::0/0
PersistentKeepalive = 25
EOF

cat > /etc/wireguard/client_10.conf <<-EOF
[Interface]
# client_10
PrivateKey = sD0oqKmPTlIYpksMJuM05GBF6SBhI2XvfECNPDoa/1E=
Address = 10.0.0.11/24 
DNS = 1.1.1.1
MTU = 1420

[Peer]
PublicKey = LFpJB+JOgjfq+sdsbh1jnY4eq/FBMk6GzyRcvFhZX2U=
Endpoint = $serverip:$PORT
AllowedIPs = 0.0.0.0/0, ::0/0
PersistentKeepalive = 25
EOF

cat >> /root/.bashrc <<-EOF

alias qr='qrencode -t ansiutf8 < '
EOF

}

#centos7 wireguard installation
wireguard_install(){
	initialCheck
	echo "What port do you want Wireguard to listen to?"
	echo "   1) Default: 40215"
	echo "   2) Custom"
	echo "   3) Random [49152-65535]"
	until [[ "$PORT_CHOICE" =~ ^[1-3]$ ]]; do
		read -rp "Port choice [1-3]: " -e -i 1 PORT_CHOICE
	done
	case $PORT_CHOICE in
		1)
			PORT="40215"
		;;
		2)
			until [[ "$PORT" =~ ^[0-9]+$ ]] && [ "$PORT" -ge 1 ] && [ "$PORT" -le 65535 ]; do
				read -rp "Custom port [1-65535]: " -e PORT
			done
		;;
		3)
			# Generate random number within private ports range
			PORT=$(shuf -i49152-65535 -n1)
			echo "Random Port: $PORT"
		;;
	esac

    curl -Lo /etc/yum.repos.d/wireguard.repo https://copr.fedorainfracloud.org/coprs/jdoss/wireguard/repo/epel-7/jdoss-wireguard-epel-7.repo
    yum install -y dkms gcc-c++ gcc-gfortran glibc-headers glibc-devel libquadmath-devel libtool systemtap systemtap-devel fail2ban policycoreutils-python
    yum -y install wireguard-dkms wireguard-tools
    yum -y install qrencode
    mkdir /etc/wireguard
    cd /etc/wireguard
    serverip=$(curl ipv4.icanhazip.com)
    #port=40215
    eth=$(ls /sys/class/net | awk '/^e/{print}')
    chmod 777 -R /etc/wireguard
    systemctl stop firewalld
    systemctl disable firewalld
    yum install -y iptables-services 
    systemctl enable iptables 
    systemctl start iptables 
    iptables -P INPUT ACCEPT
    iptables -P OUTPUT ACCEPT
    iptables -P FORWARD ACCEPT
    iptables -F
    service iptables save
    service iptables restart
    echo 1 > /proc/sys/net/ipv4/ip_forward
    echo "net.ipv4.ip_forward = 1" > /etc/sysctl.conf	
	systemctl enable fail2ban
	sed -i 's/#Port 22/Port 5555/g' /etc/ssh/sshd_config
	semanage port -a -t ssh_port_t -p tcp 5555
	service sshd restart
	
cat > /etc/fail2ban/jail.local <<-EOF
[DEFAULT]
# Ban hosts for one hour:
bantime = 3600

# Override /etc/fail2ban/jail.d/00-firewalld.conf:
banaction = iptables-multiport

[sshd]
enabled = true
EOF

	systemctl restart fail2ban
	fail2ban-client status
	wget https://raw.githubusercontent.com/assemator/tools/master/clean-log.txt -O /etc/cron.hourly/clean
	chmod +x /etc/cron.hourly/clean
	/etc/cron.hourly/clean
	
cat > /etc/wireguard/wg0.conf <<-EOF
[Interface]
PrivateKey = +OCZXXph9OMxkbRUWLHoVCos83d+eftGb1eF7nf2tWY=
Address = 10.0.0.1/24
PostUp   = echo 1 > /proc/sys/net/ipv4/ip_forward; iptables -A FORWARD -i wg0 -j ACCEPT; iptables -A FORWARD -o wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o $eth -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -D FORWARD -o wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o $eth -j MASQUERADE
ListenPort = $PORT
DNS = 1.1.1.1
MTU = 1420

[Peer]
PublicKey = b6Wy/smQSGlW+TRPoKTcya3Oz59Cvy58LZ3DNhTeFSQ=
AllowedIPs = 10.0.0.2/32

[Peer]
PublicKey = qikIMcwFx3ckQaFdTxK1U/RMYOQQ5TVgFpmGs9sWL3U=
AllowedIPs = 10.0.0.3/32

[Peer]
PublicKey = 0TNpBUA5nYSO5QxH73mKSj5FL6qitisBxuPrIqL2z0Q=
AllowedIPs = 10.0.0.4/32

[Peer]
PublicKey = OhKA9dcs0CIooRNCb6YiKmwitU/VCjJG6on2LOLJOVM=
AllowedIPs = 10.0.0.5/32

[Peer]
PublicKey = UeBmIBgqVMH/j7gHYf3UjF6X7gBnHLOia1WINeaLgCs=
AllowedIPs = 10.0.0.6/32

[Peer]
PublicKey = FdgqrVckbuz4qZ5Wle3VyQq4y1SSq+jIAJvCgT5ChFg=
AllowedIPs = 10.0.0.7/32

[Peer]
PublicKey = 0UCXB1bgqn3O9SDHPWUjT6G05iA+9dGYLDc+mUHPZl0=
AllowedIPs = 10.0.0.8/32

[Peer]
PublicKey = cQOJUEgbSPkKl31H2mtk4mautqgaOc0PpTN1hEsEvwQ=
AllowedIPs = 10.0.0.9/32

[Peer]
PublicKey = RotO1cL/Vj6+kEeyloCXg6h/YZAN2PmNuVjc2W8k70w=
AllowedIPs = 10.0.0.10/32

[Peer]
PublicKey = oqwdXCW40NFLbf4B5nqUz1RQUD+5u5p1VSv3wII63GM=
AllowedIPs = 10.0.0.11/32
EOF

    config_client
    wg-quick up wg0
    systemctl enable wg-quick@wg0
    content=$(cat /etc/wireguard/raz_1.conf)
    echo "${content}" | qrencode -o - -t UTF8
    echo -e "\e[92m Download /etc/wireguard/raz_1.conf and place it in TunSafe config folder, or scan the above QRCode directly from your phone wireguard client. \e[0m"
    echo -e "\e[92m You can also convert any client config into QRCode using the following link http://www.mfzy.cf/ewm/index.html \e[0m"
    echo -e "\e[92m for iOS install TunSafe VPN, For Android install WireGuard (Unreleased) with red dragon logo \e[0m"
    echo -e "\e[92m for For Windows OS install TunSafe client from https://tunsafe.com/, for Linux OS install wireguard \e[0m"
    echo -e "\e[92m To view or/and scan other clients, go to /etc/wireguard and use 'cat client_name.conf | qrencode -o - -t UTF8' \e[0m"
    echo -e "\e[92m Don't forget to forward port $PORT from your VPS control panel and within the CentOS system if using a firewall, this script disables firewalld by default \e[0m"
}
add_user(){
	initialCheck
    echo -e "\e[92m Choose a new client name, note: can't use an existing client name \e[0m"
    read -p "Please enter client name:" newname
    cd /etc/wireguard/
    cp client_10.conf $newname.conf
    wg genkey | tee temprikey | wg pubkey > tempubkey
    ipnum=$(grep Allowed /etc/wireguard/wg0.conf | tail -1 | awk -F '[ ./]' '{print $6}')
    newnum=$((10#${ipnum}+1))
    sed -i 's%^PrivateKey.*$%'"PrivateKey = $(cat temprikey)"'%' $newname.conf
    sed -i 's%^Address.*$%'"Address = 10.0.0.$newnum\/24"'%' $newname.conf

cat >> /etc/wireguard/wg0.conf <<-EOF
[Peer]
PublicKey = $(cat tempubkey)
AllowedIPs = 10.0.0.$newnum/32
EOF
    wg set wg0 peer $(cat tempubkey) allowed-ips 10.0.0.$newnum/32
    echo -e "\e[92m New client created /etc/wireguard/$newname.conf\e[0m"
    rm -f temprikey tempubkey
}
#Start Menu
start_menu(){
    clear
    echo "========================================================="
    echo " Installing WireGuard VPN on CentOS 7 linux"
	echo " Default port is: 40215 with 10 pre-installed clients"
    echo " Original creation by atrandys www.atrandys.com"
	echo " Original Script: https://bit.ly/2DT545N"
    echo " Translation and modification for personal use by Assem"
    echo "========================================================="
    echo "1) Upgrade Kernel"
    echo "2) Install Wireguard"
    echo "3) Update Wireguard"
    echo "4) Uninstall Wireguard"
    echo "5) Display raz_1 QR code"
    echo "6) Create a new client"
    echo "0) Exit script"
    echo
    read -p "Please choose a number:" num
    case "$num" in
    	1)
	update_kernel
	;;
	2)
	wireguard_install
	;;
	3)
	wireguard_update
	;;
	4)
	wireguard_remove
	;;
	5)
	content=$(cat /etc/wireguard/raz_1.conf)
    	echo "${content}" | qrencode -o - -t UTF8
	;;
	6)
	add_user
	;;
	0)
	exit 1
	;;
	*)
	clear
	echo "Please enter the correct number"
	sleep 5s
	start_menu
	;;
    esac
}

start_menu


