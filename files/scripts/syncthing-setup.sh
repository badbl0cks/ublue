#!/usr/bin/env bash
set -euo pipefail

# add syncthing to firewall
firewall-offline-cmd --add-service=syncthing

# allow TCP forwarding in sshd_config
sed -i 's/#\?\(AllowTcpForwarding\s*\).*$/\1 yes/' /etc/ssh/sshd_config || echo "AllowTcpForwarding yes" >> /etc/ssh/sshd_config

# setup sync directory
mkdir -p /var/srv/sync /var/srv/.stconfig
chown sync /var/srv/sync /var/srv/.stconfig

# generate a syncthing deviceID
sudo -u sync syncthing generate --no-default-folder --skip-port-probing --config=/var/srv/.stconfig

# generate a custom syncthing deviceID
#openssl ecparam -genkey -name secp384r1 -out key.pem
#openssl req -new -key key.pem -out cert.csr -nodes -subj "/C=/ST=/L=/O=/OU=/CN=syncthing"
#syncthing-generate-deviceid.py "NAME[0-9]{2}|[0-9]NAME[0-9]|[0-9]{2}NAME"
#openssl x509 -inform DER -in *.der -out cert.pem
#rm -f cert.der cert.csr
#<*.der openssl dgst -binary -sha256 | base32 | sed 's/=//g'

# start the syncthing service so we can configure it
trap 'sudo -u sync syncthing cli operations shutdown --data=/var/srv/sync --config=/var/srv/.stconfig' EXIT
sudo -u sync syncthing serve --no-browser --no-restart --no-default-folder --skip-port-probing --logflags=0 --data=/var/srv/sync --config=/var/srv/.stconfig &

for option in "natenabled" "relays-enabled" "global-ann-enabled" "start-browser"
    do sudo -u sync syncthing cli config options $option set false
done

#sudo -u sync syncthing cli config defaults device allowed-networks add "192.168.253.0/24"

for option in "sync-xattrs" "sync-ownership"
    do sudo -u sync syncthing cli config defaults folder $option set true
done

#i=0
#for protocol in "tcp" "quic"
#    do sudo -u sync syncthing cli config options raw-listen-addresses $i set "$protocol://192.168.253.2:22000"; let i++
#done
#sudo -u sync syncthing cli config options raw-listen-addresses 2 delete

sudo -u sync syncthing cli config devices add \
  --device-id 2YTRKD4-RUY5F5H-BHJLWE5-RM3KXVD-BVDVGVD-5ETSBIQ-UYYRVDO-Z5SWJQK \
  --auto-accept-folders true \
  --introducer true

# stop syncthing after configuration
sudo -u sync syncthing cli operations shutdown --data=/var/srv/sync --config=/var/srv/.stconfig
