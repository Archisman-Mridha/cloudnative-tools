# LinkerD

Run this to install the LinkerD command line tool -

```bash
curl --proto '=https' --tlsv1.2 -sSfL https://run.linkerd.io/install | sh
export PATH=$PATH:/home/archi/.linkerd2/bin

linkerd --version
```

Next, we will install LinkerD in our K3D cluster using Helm. Run these commands -

```bash
# test if your local Kubernetes cluster is prepared for LinkerD installation
linkerd check --pre

helm repo add linkerd https://helm.linkerd.io/stable

# installing LinkerD CRDs
helm install linkerd-crds linkerd/linkerd-crds -n linkerd --create-namespace --wait

# installing step cli
wget https://dl.step.sm/gh-release/cli/docs-cli-install/v0.21.0/step-cli_0.21.0_amd64.deb
sudo dpkg -i step-cli_0.21.0_amd64.deb
rm step-cli_0.21.0_amd64.deb

# generating mTLS certificates
step certificate create root.linkerd.cluster.local ca.crt ca.key \
    --profile root-ca --no-password --insecure
step certificate create identity.linkerd.cluster.local issuer.crt issuer.key \
    --profile intermediate-ca --not-after 8760h --no-password --insecure \
    --ca ca.crt --ca-key ca.key

# installing the data plane
helm install linkerd-control-plane \
    -n linkerd \
    --set-file identityTrustAnchorsPEM=ca.crt \
    --set-file identity.issuer.tls.crtPEM=issuer.crt \
    --set-file identity.issuer.tls.keyPEM=issuer.key \
    linkerd/linkerd-control-plane --wait

# installing LinkerD viz extension for dashboard
helm install linkerd-viz linkerd/linkerd-viz --wait

linkerd check

# opens the dashboard
linkerd viz dashboard
```