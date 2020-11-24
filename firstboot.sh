#!/bin/bash
   # read the config
   . /boot/firstboot.conf

   [[ "$(lscpu | grep 'Architecture' | awk '{print $NF}')" = arm* ]] || { echo "Firstboot error: Unsupported CPU architecture!"; exit 1; }
   [[ "$(cat /proc/cpuinfo | grep Revision | awk '{print $NF}')" = [abc]* ]] && { arch="armv7"; } || { arch="armv5"; }

   # wait for network connectivity
   until ( ping -w 1 optim-test.com &> /dev/null ); do
      { sleep 10; }
   done

   # checking dpkg lock
   while ( fuser /var/lib/dpkg/lock ); do
      { sleep 10; }
   done

   apt update -y &> /dev/null ; apt install -y wget unzip &> /dev/null

   # download cios-agent
   wget https://cios-agent.pre.cios.dev/scripts/scripts_arm.zip -O /tmp/cios-agent-scripts_arm.zip &> /dev/null # Raspbian OS stretch/busterの場合
   unzip /tmp/cios-agent-scripts_arm.zip -d /tmp

   useradd cios_rshell &> /dev/null
   mkdir /home/cios_rshell &> /dev/null
   echo "cios_rshell:$DEFAULT_PASSWORD" | chpasswd

   # install cios-agent
   cd /tmp/scripts_arm/activation &> /dev/null
   ./activation.sh -a $ACTIVATION_KEY -i $ID_NUMBER -n $DEVICE_NAME &> /dev/null

   # remove files
   [ -f /etc/rc.local ] && [ -f /boot/activate_firstboot_and_resize ] && { rm -f /boot/activate_firstboot_and_resize; sed -i "19d" /etc/rc.local; }
   [ -f /boot/firstboot.conf ] && { rm -f /boot/firstboot.conf; }
   [ -f /boot/Readme ] && { rm -f /boot/Readme; }
   rm -f $0
