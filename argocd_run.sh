# argocd
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
wget https://raw.githubusercontent.com/claudioed/observability-ops/master/argo-rollout/argo-rollout.sh
sh argo-rollout.sh
kubectl patch -n argocd svc argocd-server -p '{"spec": {"type": "NodePort"}}' && kubectl get svc argocd-server -n argocd
# name space
kubectl apply -f https://raw.githubusercontent.com/claudioed/bets-helm/master/rollout/apps/ns.yaml
# apps
kubectl apply -f https://raw.githubusercontent.com/claudioed/bets-helm/master/rollout/apps/players-app.yaml
kubectl apply -f https://raw.githubusercontent.com/claudioed/bets-helm/master/rollout/apps/matches-app.yaml
kubectl apply -f https://raw.githubusercontent.com/claudioed/bets-helm/master/rollout/apps/championships-app.yaml
kubectl apply -f https://raw.githubusercontent.com/claudioed/bets-helm/master/rollout/apps/bets-app.yaml
# 
export INGRESS_HOST=$(curl -s checkip.amazonaws.com)
export INGRESS_PORT=$(kubectl get svc argocd-server -n argocd -o jsonpath='{.spec.ports[?(@.name=="http")].nodePort}')
echo "Acessar ARGOCD: http://$INGRESS_HOST:$INGRESS_PORT"
echo ""
# get secret
echo "Solicitar SECRET : kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath=\"{.data.password}\" | base64 -d && echo """
#kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo ""
echo ""
echo ""
