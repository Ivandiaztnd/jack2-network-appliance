 echo "1" > /proc/sys/net/ipv4/ip_forward


for a in `ls /proc/sys/net/ipv4/conf/*/accept_redirects`
 do
    echo "0" > $a

done


for f in `ls /proc/sys/net/ipv4/conf/*/send_redirects`
 do
    echo "0" > $f

done

