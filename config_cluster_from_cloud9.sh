# conectar no master e configurar

~/environment/ip # | awk -Fv '/vm_0/{print $1}' 

MASTER=$(~/environment/ip # | awk -Fv '/vm_0/{print $1}')
NODE1=$(~/environment/ip # | awk -Fv '/vm_1/{print $1}')
NODE2=$(~/environment/ip # | awk -Fv '/vm_2/{print $1}')
NODE3=$(~/environment/ip # | awk -Fv '/vm_3/{print $1}')

ssh -i ~/environment/chave-fiap.pem ubuntu@MASTER 'bash -s' < config_master.sh
