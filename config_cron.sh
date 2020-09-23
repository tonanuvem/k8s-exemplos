wget 
croncmd="/home/ubuntu/config_node_drain.sh"
echo $croncmd
cronjob="*/1 * * * * $croncmd"
( crontab -l | grep -v -F "$croncmd" ; echo "$cronjob" ) | crontab -
crontab -l
