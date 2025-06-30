#!/bin/bash
apt-get update && apt-get install -y qemu-utils qemu-kvm qemu-system-x86 pv fdisk parted wget nano zip unzip psmisc
wget https://download.mikrotik.com/routeros/{mikVersion}/chr-{mikVersion}.img.zip -O chr.img.zip  && \
gunzip -c chr.img.zip > chr.img  && \
apt-get update && \
apt install -y qemu-utils pv && \
qemu-img convert chr.img -O qcow2 chr.qcow2 && \
qemu-img resize chr.qcow2 1073741824 && \
apt-get update && apt-get install -y qemu-utils qemu-kvm qemu-system-x86 pv fdisk parted wget nano zip unzip psmisc && \
modprobe nbd && \
qemu-nbd -c /dev/nbd0 chr.qcow2 && \
echo "Give some time for qemu-nbd to be ready" && \
sleep 2 && \
partprobe /dev/nbd0 && \
sleep 5 && \
mount /dev/nbd0p2 /mnt && \
IFACE=$(ip -o -4 route show to default | awk '{print $5}')
ADDRESS=$(ip -o -4 addr show dev "$IFACE" | awk '{print $4}' | head -n1)
GATEWAY=$(ip route | grep default | awk '{print $3}')
echo "/ip address add address=$ADDRESS/32 broadcast=$ADDRESS interface=[/interface ethernet find where name=ether1]
/ip address add address=$ADDRESS broadcast=$ADDRESS interface=[/interface ethernet find where name=ether1] network=$GATEWAY
/ip route add dst-address=0.0.0.0/0 gateway=$GATEWAY
/user set 0 name=admin password={password}
/ip dns set servers={dns}
/ip firewall nat add action=masquerade chain=srcnat
/system/license/renew  level=p-unlimited account={licence-account} password={licence-password}
{extraConfigs}
" > /mnt/rw/autorun.scr && \
umount /mnt && \
echo "Magic constant is 65537 (second partition address). You can check it with fdisk before appliyng this" && \
echo "This scary sequence removes seconds partition on nbd0 and creates new, but bigger one" && \
echo -e 'd\n2\nn\np\n2\n65537\n\nw\n' | fdisk /dev/nbd0 && \
e2fsck -f -y /dev/nbd0p2 || true && \
resize2fs /dev/nbd0p2 && \
sleep 1 && \
echo "Compressing to gzip, this can take several minutes" && \
mount -t tmpfs tmpfs /mnt && \
pv /dev/nbd0 | gzip > /mnt/chr-extended.gz && \
sleep 1 && \
killall qemu-nbd && \
sleep 1 && \
echo u > /proc/sysrq-trigger && \
echo "Warming up sleep" && \
sleep 1 && \
echo "Writing raw image, this will take time" && \
zcat /mnt/chr-extended.gz | pv > /dev/vda && \
echo "Don't forget your password: {password}" && \
echo "Sleep 5 seconds (if lucky)" && \
sleep 5 || true && \
echo "sync disk" && \
echo s > /proc/sysrq-trigger && \
echo "Ok, reboot" && \
echo b > /proc/sysrq-trigger
