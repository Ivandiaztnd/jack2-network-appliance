clear;
echo
cat /opt/jack2/jack2-dhcp-server.conf|sed s/"dnsmasq"/"DHCP"/g|sed s/"--dhcp-range"/"RANGE"/g|sed s/"-l \/var\/spool\/DHCP.leases -x 9999"//g|sed s/"--dhcp-option=6,"/"DHCP_DNS="/g|sed s/"--dhcp-option=3,"/"DHCP_GATEWAY="/g|sed s/"DHCP_DNS"/"\nDHCP_DNS"/g|sed s/"DHCP_GATEWAY"/"\nDHCP_GATEWAY"/g|sed s/"RANGE"/"\nRANGE"/g|sed s/"up"/"\n"/g
echo
echo
