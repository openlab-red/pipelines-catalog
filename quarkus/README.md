# Quarkus Tekton Tasks

The repository holds the Tekton tasks for [Quarkus](https://quarkus.io) apps.

Use

- `quarkus-native` to build native images
- `quarkus-jvm` to build jvm images
- `s2i-quarkus` to build Quarkus native images using s2i

## Pipeline

Connect to prod cluster and run `gen-secret-pipelineresource-prod-cluster.sh` script. This will generate a manifest for a secret containing the Kubernetes token and cafile.

```
bash gen-prod-secret.sh <API_URL_PROD_CLUSTER> <NAMESPACE_PROD_CLUSTER>
```

Connect to dev cluster and create the previously generated secret and the `cluster` PipelineResource

```
oc create -f pipelineresource-prod-cluster-secret.yaml
oc create -f pipelineresource-prod-cluster.yaml
```

Still on Dev cluster, create the necessary tasks and the pipeline

```
oc create -f openshift-client.yaml
oc create -f openshift-client-kubecfg.yaml
oc create -f s2i-quarkus-task.yaml
oc create -f mvn.yaml

oc create -f pipeline.yaml
```

Run the pipeline

```
tkn pipeline start quarkus-deploy -p "MAVEN_MIRROR_URL=http://nexus3.labs:8081/nexus/content/groups/public" -p ""  -s pipeline
```
