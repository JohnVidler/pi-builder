#!/bin/bash

# Generate the wireguard keys and configs
wg genkey | tee $HOME/peer.key | wg pubkey > $HOME/peer.pub
wg genpsk > $HOME/network.key
chmod 0600 $HOME/peer.key

WG_PRIVATE_KEY=$(cat $HOME/peer.key)
WG_LOCAL_PUB=$(cat $HOME/peer.pub)
WG_NETWORK_KEY=$(cat $HOME/network.key)

exec 3>&1;
WG_ENDPOINT=$(dialog --backtitle "Wireguard Network Configuration" --inputbox "Enter the VPN endpoint for this device (someserver.com:port)" 8 50 "" 2>&1 1>&3)
WG_PUBLIC_KEY=$(dialog --backtitle "Wireguard Network Configuration" --inputbox "Enter the VPN endpoint public key" 8 50 "" 2>&1 1>&3)
WG_NETWORK_IP=$(dialog --backtitle "Wireguard Network Configuration" --inputbox "Enter this device's designated IPv4 or IPv6 address" 8 50 "" 2>&1 1>&3)
WG_NETWORK_IP_RANGE=$(dialog --backtitle "Wireguard Network Configuration" --inputbox "Enter this device's VPN IP address range" 8 50 "" 2>&1 1>&3)
exitcode=$?;
exec 3>&-;

echo "For the next two steps, the root password will be required to create the system configuration files"

su root -c "cat > /etc/systemd/network/99-wg0.netdev <<EOF \
[NetDev] \
Name=wg0 \
Kind=wireguard \
Description=WireGuard tunnel wg0 \
\
[WireGuard] \
PrivateKey=$WG_PRIVATE_KEY \
\
[WireGuardPeer] \
PublicKey=$WG_PUBLIC_KEY \
PresharedKey=$WG_NETWORK_KEY \
AllowedIPs=$WG_NETWORK_IP_RANGE \
Endpoint=$WG_ENDPOINT \
EOF; \
\
cat > /etc/systemd/network/99-wg0.network <<EOF \
[Match] \
Name=wg0 \
\
[Network] \
Address=$WG_NETWORK_IP \
EOF"

dialog --msgbox "Your network keys are saved in $HOME \n\
\n\
Your public key:  $WG_LOCAL_PUB \n\
Your network key: $WG_NETWORK_KEY \n\
\n\
Please save these to communicate to the network operator" 10 80