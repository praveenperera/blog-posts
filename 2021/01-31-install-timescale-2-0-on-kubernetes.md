==title==
Deploy TimescaleDB 2.0 (multi node) to Kubernetes using Helm

==author==
Praveen Perera

==tags==
kubernetes, cheatsheet, dev-ops, timescale, helm, walk-through, tutorial

==twitter==
{
"image": "https://praveenperera.com/images/posts/install_timescale.jpg",
"card": "summary_large_image"
}

==description==
In this tutorial I will show you how to deploy TimescaleDB 2.0 to a kubernetes cluster using helm 3

==body==

<iframe title="embedded youtube video walkthrough" width="560" height="315" src="https://www.youtube.com/embed/48BzEkPngWo" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

- [Prerequisites](#prerequisites)
- [Deploying TimescaleDB 2.0 (Multi Node)](#deploying-timescaledb-20-multi-node)
- [Accessing database locally](#accessing-database-locally)

<a name="prerequisites"></a>

## Prerequisites

Before proceeding you will need the follow:

1. A running kubernetes clusters.
2. [Helm CLI](https://github.com/helm/helm) installed
3. [KubeCTL](https://kubernetes.io/docs/tasks/tools/install-kubectl/) installed

If you don't have a kubernetes cluster, see my [getting started with kubernetes with rancher and DigitalOcean managed kubernetes series](https://www.youtube.com/watch?v=tiSUpKDgWfQ&list=PLcdHMZkfm5ujt60AwNh1EfmI-30PzeAy0)

<a name="installing-timescale-db-20-multi-node"></a>

## Deploying TimescaleDB 2.0 (Multi Node)

1. Clone the [timescale/timescaledb-kubernetes](https://github.com/timescale/timescaledb-kubernetes) repo

```bash
git clone git@github.com:timescale/timescaledb-kubernetes.git
```

2. Delete everything except `charts/timescaledb-multinode`
3. Rename this folder `charts`

4. In this folder open the `values.yaml` file.
5. Under image change value for `repository` to: `timescale/timescaledb-ha`

6. Change the value for `tag` to: `pg12.5-ts2.0.0-p0` or find the current latest one at: https://hub.docker.com/r/timescale/timescaledb

7. In the project root folder create a file called `.pgpass`

8. Open `.pgpass` and enter the following (use randomly generated passwords and create as many accounts as you need)

```
*:*:*:postgres:DATAPASS-XXXXXXXXXXXXX
*:*:*:admin:ACCESSPASS-YYYYYYYYYYYYYY
```

8. Open `charts/templates/svc-timescaledb-access.yaml`

9. Change `type: LoadBalancer` to `type: ClusterIP`

10. Go into terminal open project root folder and run

```bash
 helm install timescale-db charts --namespace=default --set credentials.accessNode.superuser="<ACCESSPASS-YYYYYYYYYYYYYY>" --set credentials.dataNode.superuser="<DATAPASS-XXXXXXXXXXXXX>"
```

<a name="accessing-database-locally"></a>

## Accessing database locally

1. Get the password for access node

```bash
PGPASSWORD_POSTGRES=$(kubectl get secret --namespace default timescale-db-timescaledb-access -o jsonpath="{.data.password-superuser}" | base64 --decode)
```

2. Get the name of the access node pod

```bash
ACCESS_POD=$(kubectl get pod -o name --namespace default -l release=timescale-db,timescaleNodeType=access)
```

3. Start a port forward from the access node

```bash
kubectl port-forward $ACCESS_POD 7000:5432 -n=default
```

4. Now you can access the database that's in your cluster as if it were running locally. Use whatever port you're forwarding to (`7000` in this case). The host is localhost, the user is `postgres` and the password is `$PGPASSWORD_POSTGRES` from step one
