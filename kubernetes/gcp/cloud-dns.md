# Cloud DNS setup

[gcloud cli](https://cloud.google.com/sdk/docs/install#mac)

## Add to path if gcloud command is not recognized after installation

`export PATH=$PATH:/Users/jenn/google-cloud-sdk/bin`

## Create project in Google Cloud (completed with GUI)

## Create hosted zone in Google Cloud (either with GUI or below command)

`gcloud dns --project=pi-cluster-433101 managed-zones create homelab --description="" --dns-name="jenniferpweir.com." --visibility="public" --dnssec-state="off"`

## Set up Workload Identity Federation (WIF) using wif.sh script

`./wif.sh <PROJECT_ID> <PROJECT_NUMBER> <NAMESPACE>`
