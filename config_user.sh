kubectl create sa fiap
kubectl create clusterrolebinding fiap --clusterrole cluster-admin --serviceaccount default:fiap

KUBE_DEPLOY_SECRET_NAME=$(kubectl get sa fiap -o jsonpath='{.secrets[0].name}')
KUBE_API_EP=$(kubectl get ep -o jsonpath='{.items[0].subsets[0].addresses[0].ip}')
KUBE_API_TOKEN=$(kubectl get secret $KUBE_DEPLOY_SECRET_NAME -o jsonpath='{.data.token}'|base64 --decode)
KUBE_API_CA=$(kubectl get secret $KUBE_DEPLOY_SECRET_NAME -o jsonpath='{.data.ca\.crt}'|base64 --decode)
KUBE_API_CERT=$(kubectl get secret $KUBE_DEPLOY_SECRET_NAME -o jsonpath='{.data.ca\.crt}'|base64 --decode)
echo $KUBE_API_CA > tmp.deploy.ca.crt

echo $KUBE_DEPLOY_SECRET_NAME
echo $KUBE_API_EP     # IP address of your cluster
echo $KUBE_API_TOKEN  # token of the ServiceAccount
echo $KUBE_API_CERT   # CA certificate of the ServiceAccount
echo $KUBE_API_CA     # CA certificate of the ServiceAccount
echo $KUBE_API_CERT > deployer.crt

curl --cacert deployer.crt https://$KUBE_API_EP
curl --cacert deployer.crt -H "Authorization: Bearer $KUBE_API_TOKEN" https://$KUBE_API_EP

export KUBECONFIG=./my-new-kubeconfig
kubectl config set-cluster k8s --server=https://$KUBE_API_EP --certificate-authority=tmp.fiap.ca.crt --embed-certs=true
kubectl config set-credentials k8s-fiap --token=$KUBE_API_TOKEN
kubectl config set-context k8s --cluster k8s --user k8s-fiap
kubectl config use-context k8s

rm tmp.fiap.ca.crt
unset KUBECONFIG
