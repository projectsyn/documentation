#!/bin/bash

# Record with
# asciinema rec -t "Project Syn - Steward Demo" -c "bash steward.sh" ../assets/casts/steward.cast

########################
# include the magic
########################
. demo-magic.sh -d
#PROMPT_TIMEOUT=1

# hide the evidence
clear

p '++ Welcome to Project Syn - Steward Demo'
sleep 2

p '++ This demo assumes a running Lieutenant and a compiled Cluster Catalog'

p '++ Check bootstrap token validity'
pe 'kubectl -n lieutenant get cluster ${CLUSTER_ID} -o jsonpath="{.status.bootstrapToken.tokenValid}"'

p '++ Lets retrieve the one-time install URL which is only valid once'

pe 'export STEWARD_INSTALL=$(curl -H "$LIEUTENANT_AUTH" -s "http://${LIEUTENANT_URL}/clusters/${CLUSTER_ID}" | jq -r ".installURL")'
pe 'echo $STEWARD_INSTALL'

sleep 5

p '++ Briefly check the clusters status'
pe 'kubectl -n syn get pod'

sleep 2

p '++ Now install Steward (on the same cluster as Lieutenant is running)'

pe 'kubectl apply -f $STEWARD_INSTALL'

sleep 2

p '++ The install URL is now invalid'
pe 'kubectl -n lieutenant get cluster ${CLUSTER_ID} -o jsonpath="{.status.bootstrapToken.tokenValid}"'

sleep 5
# Next page
clear

p '++ Steward now bootstraps Argo CD which pulls configuration from the Cluster Catalog Git Repo'
pe 'kubectl -n syn get pod'

p '++ Lets wait some time to see Pods appear'

sleep 10

pe 'kubectl -n syn get pod'

p '++ Lets wait some time to see the Argo CD app to be synced'

sleep 60

pe 'kubectl -n syn get app root -o jsonpath="{.status.sync.status}"'

sleep 5

p '++ Thats it, the cluster is now Project Syn enabled'
