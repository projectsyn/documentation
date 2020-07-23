#!/bin/bash

# Record with
# asciinema rec -t "Project Syn - Lieutenant Demo" -c "bash lieutenant.sh" ../assets/casts/lieutenant.cast

########################
# include the magic
########################
. demo-magic.sh -d
#PROMPT_TIMEOUT=1

# hide the evidence
clear

p '++ Welcome to Project Syn - Lieutenant Demo'
sleep 2

p '++ Lets check if the Lieutenant API is healthy and reachable'

pe 'echo http://lieutenant.${INGRESS_IP}.nip.io/healthz'

p 'curl http://lieutenant.${INGRESS_IP}.nip.io/healthz'
curl -w "\n" http://lieutenant.${INGRESS_IP}.nip.io/healthz

sleep 1

p '++ The API responds with "ok", all is fine for the next steps'

sleep 5
## Next Page
clear

p '++ Now we register a new tenant in the API'
sleep 2

pe 'TENANT_ID=$(curl -s -H "$LIEUTENANT_AUTH" -H "Content-Type: application/json" -X POST --data "{\"displayName\":\"My first Tenant\",\"gitRepo\":{\"url\":\"ssh://git@${GITLAB_ENDPOINT}/${GITLAB_USERNAME}/mytenant.git\"}}" "http://${LIEUTENANT_URL}/tenants" | jq -r ".id")'
pe 'echo $TENANT_ID'
pe 'echo https://${GITLAB_ENDPOINT}/${GITLAB_USERNAME}/mytenant'

p '++ This created a Git repository on the above URL for the tenant configuration'

sleep 3

p '++ Lets retrieve the tenants, via API and directly on the cluster'
sleep 2

pe 'curl -H "$LIEUTENANT_AUTH" "http://${LIEUTENANT_URL}/tenants"'
pe 'kubectl -n lieutenant get tenant'
sleep 2

p '++ And the Git repo object'

pe 'kubectl -n lieutenant get gitrepo'

sleep 5
## Next Page
clear

p '++ Now we register a cluster in Lieutenant and assign it to the new tenant created before'

sleep 2

pe 'CLUSTER_ID=$(curl -s -H "$LIEUTENANT_AUTH" -H "Content-Type: application/json" -X POST --data "{ \"tenant\": \"${TENANT_ID}\", \"displayName\": \"My first Project Syn cluster\", \"facts\": { \"cloud\": \"local\", \"distribution\": \"k3s\", \"region\": \"local\" }, \"gitRepo\": { \"url\": \"ssh://git@${GITLAB_ENDPOINT}/${GITLAB_USERNAME}/cluster-gitops1.git\" } }" "http://${LIEUTENANT_URL}/clusters" | jq -r ".id")'
pe 'echo $CLUSTER_ID'
pe 'echo https://${GITLAB_ENDPOINT}/${GITLAB_USERNAME}/cluster-gitops1'

p '++ Another Git repo got created on the above URL for the cluster catalog'

sleep 5
## Next Page
clear

p '++ Lets check the object on the API and on the cluster'

sleep 2

pe 'curl -H "$LIEUTENANT_AUTH" "http://${LIEUTENANT_URL}/clusters"'
pe 'kubectl -n lieutenant get cluster'
pe 'kubectl -n lieutenant get gitrepo'

sleep 3

p '++ Thats it, Lieutenant now has a tenant and a cluster registered. Thanks for watching.'

sleep 1
