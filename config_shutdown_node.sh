#!/bin/sh

MASTER=$(~/environment/ip | awk -Fv '{ if ( !($1 ~  "None") && (/vm_0/) ) { print $1} }')
NODE1=$(~/environment/ip | awk -Fv '{ if ( !($1 ~  "None") && (/vm_1/) ) { print $1} }')
NODE2=$(~/environment/ip | awk -Fv '{ if ( !($1 ~  "None") && (/vm_2/) ) { print $1} }')
NODE3=$(~/environment/ip | awk -Fv '{ if ( !($1 ~  "None") && (/vm_3/) ) { print $1} }')
echo "IPs configurados :"
echo "MASTER = $MASTER"
echo "WORKER1 = $NODE1"
echo "WORKER2 = $NODE2"
echo "WORKER3 = $NODE3"

printf "\n\n"
echo "Digite o IP do node que deseja desligar: "
read NODE

ssh -oStrictHostKeyChecking=no -i ~/environment/chave-fiap.pem ubuntu@$NODE "sudo shutdown -h now"
