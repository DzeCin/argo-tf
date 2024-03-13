The relevant repos are :

- argocd repo: I chose to use the gitops repository layout defined in this documentation https://codefresh.io/blog/how-to-model-your-gitops-environments-and-promote-releases-between-them/

- terraform: I chose to use this repository layout https://github.com/antonbabenko/terraform-best-practices/tree/master/examples/medium-terraform


Difficulty levels:
 - Easy
 - Medium
 - Hard

### Create a kubernetes cluster / deploy argocd (6h -> first time using argocd, difficulty medium)

The chosen infra is as follow:
- 3 nodes for the "infra" component such as the operators and argocd
- 3 nodes for the "apps" component such as postgresql and keycloak

The terraform state is local because no terraform backend available for this poc. The state is commited on purpose.

In terraform/poc/infra

Export the digital ocean token.

- terraform apply -var-file=./dev.infra.tfvars

After creating the cluster with terraform, get the kubeconfig from DigitalOcean webstie, then, there are some manual steps (which could be automated):

- kubectl create ns argo

- generate a age key which will be used for secret decryption in argocd:
  - age-keygen -o key.txt

- kubectl -n argo create secret generic helm-secrets-private-keys --from-file=key.txt=key.txt


In terraform/poc/apps

- terraform apply -var "cluster_name=$(terraform -chdir=../infra output -raw cluster_name)" -var-file=./dev.apps.tfvars

The argo values have been customized so argocd is deployed in HA mode and spread across the cluster infra nodes. A lot of tunning has been made in order to be able to use sops and be able to set sync-waves on Applications.
Some components have been disabled has they are not needed for this pos (dex, applicationset controller).
TLS server has been disabled for the argo-cd server as traefik does not support reencryption.
Here are the references:

- https://github.com/jkroepke/helm-secrets/wiki/ArgoCD-Integration
- https://kubito.dev/posts/enable-argocd-sync-wave-between-apps/
- https://argo-cd.readthedocs.io/en/stable/

The app of apps approach has been chosen. Therefore, the terraform script also deploys an intial app with helm. Ref:
- https://argo-cd.readthedocs.io/en/stable/operator-manual/cluster-bootstrapping/

However argocd is not automanaged and has to be managed by terraform.


### Deploy the monitoring stack (3h -> helm values optimizing, difficulty easy)

sync-wave=-10

Prometheus has been installed via the official operator. A lot of tunning has been made in the values so it is optimized. Prometheus can hardly be setup in HA mode. One alternative is Victoria-Metrics.

Grafana has been deployed with the official helm chart. Values have been optimized to use keycloak authentication and be able to import dashboards and sources from configmaps.

Helm is usefull for easy managing of applications despite the not-so-easy integration with argocd.

### Deploy cert manager (30m, difficulty easy)

sync-wave=-5

Cert-Manager has been deployed with the official helm chart. Values have been tunned to configure HA.
A staging lets encrypt server is being used just for the poc purpose.

### Deploy traefik (30m, difficulty easy)

sync-wave=-2

Traefik has been deployed with the official helm chart release and configured for HA and to be the default IngressClass. It also deploys a Cert-Manager ClusterIssuer.

### Deploy postgres operator (2h, difficulty easy)

sync-wave=-1

To deploy Postgres cluster, I chose to use the Postgres Operator. The reason behind it is that databases are often complicated to deploy and manage on kubernetes with simple manifests. Operators provide the ability to provision HA clusters easily and configure them. It makes the backup tasks also easier.

### Deploy keycloak sso (2h, difficulty easy)

Keycloak has been deployed with the bitnami helm chart. It provides a HA keycloak cluster.
The charts also deploys a postgres cluster, configured for HA.
The configuration of the grafana realm is made automatically at startup via the keycloak cli.
Values have been optimized for ha and reliability.
Only local keycloak users have been created. Not linked with external sources.

+ doc (2h)

Helm chart and Operators are a good way to manage a kubernetes cluster.

### Security considerations:
 - Pods have been deployed as much as possible with low privileges and custom securitycontexts.
 - Passwords are sops encrypted in the app git repo.
 - Images have been fixed with digest as much as possible.
 - More privileged pods (especially controllers) have been isolated on a specific node pool.

### Secutity todo for production readiness:
 - Deploy NetworkPolicies (+ block metadata server access).
 - Setup proper RBAC/Auth(OAuth) to access the kubernetes cluster and the different services.
 - Setup a key management system for secret and encryption keys.
 - Deploy a service mesh such as Linkerd (analyze if can work with traefik needed)
 - Deploy the kube-bench operator for CIS compliance.
 - Deploy the OPA Gatekeeper for configuration standardization and security
 - Only private access to the cluster api
 - Proper CI/CD deployment for the infrastructure and applications build (test + build + security tests + push)
 - Encrypted tfstate
 - Trivy operator to scan images used at all times
 - One age key per env
 - Secure repo connection from argocd

### Reliability/Monitoring considerations:
 - Most of the services are set in HA mode + poddisruption budgets are enables
 - Limits/Requests have been set -> for keycloak limit=requests for Garanteed QoS
 - Default dashboards on grafana created
 - No overcommitment
 - HPA defined as much as possible

### Reliability/Monitoring for production readiness:
 - Implement a proper Observability stack + Monitoring -> Grafana/Prometheus/Loki/Tempo/(Opentelemetry ?)/Alertmanager
 - Node autoscalling for high load 
 - Proper resource management- > https://learnk8s.io/setting-cpu-memory-limits-requests
 - Multiple environment
 - Reduce costs
 - Create a cluster dedicated to "infra" services such as monitoring and share it between environments
 - Load tests to define resources needed/Pen Tests
 - Use minimal docker images
 - Multiple AZ deployments + HA kubeapi