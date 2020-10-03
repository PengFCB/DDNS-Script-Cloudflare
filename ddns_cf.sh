#!/bin/sh
#INPUT YOUR CLOUDFLARE ACCOUNT INFO
CF_API_KEY=your_cloudflare_API_key
CF_ZONE_ID=your_cloudflare_zone_id
CF_DNS_ID=your_dns_id_for_ddns
EMAIL=your_cloudflare_login_email

#CHANGE THIS TO YOUR NETWORK DEVICE
ROUTER_NETWORK_DEVICE=eth0

#CHANGE THIS TO YOUR DOMAIN FOR DDNS
DNS_RECORD=your.ddnsdomain.com

TEMP_FILE_PATH=/tmp/cloudflare-ddns
mkdir -p ${TEMP_FILE_PATH}
curl -k -X GET "https://api.cloudflare.com/client/v4/zones/${CF_ZONE_ID}/dns_records/${CF_DNS_ID}" \
-H "X-Auth-Email:${EMAIL}" \
-H "X-Auth-Key:${CF_API_KEY}" \
-H "Content-Type: application/json" |awk -F '"' '{print $18}'>${TEMP_FILE_PATH}/current_resolving.txt
ifconfig $ROUTER_NETWORK_DEVICE | awk -F'[ ]+|:' '/inet /{print $4}'>${TEMP_FILE_PATH}/current_ip.txt
if [ "$(cat ${TEMP_FILE_PATH}/current_ip.txt)" == "$(cat ${TEMP_FILE_PATH}/current_resolving.txt)" ]; 
then
exit 1
else
CURRENT_IP="$(curl ipv4.icanhazip.com)"
curl -k -X PUT "https://api.cloudflare.com/client/v4/zones/${CF_ZONE_ID}/dns_records/${CF_DNS_ID}" \
-H "X-Auth-Email:${EMAIL}" \
-H "X-Auth-Key:${CF_API_KEY}" \
-H "Content-Type: application/json" \
--data '{"type":"A","name":"'$DNS_RECORD'","content":"'$CURRENT_IP'","ttl":1,"proxied":false}'
fi
