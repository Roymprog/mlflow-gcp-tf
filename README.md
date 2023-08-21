This project shows how to deploy MLFlow on GCP using Cloud Run and Cloud SQl.

The MLFlow docker image from this [repo](https://github.com/getindata/mlflow-docker) is used.
MLFlow version 2.5.0 is used. 

Load environment variables
```bash
export $(xargs < .env)
```

```bash
gcloud auth login
```

Create TF service account
```bash
gcloud iam service-accounts create $TERRAFORM_SA \
    --description="Service account used by Terraform to provision infrastructure" \
    --display-name="tf-gcp-vertex"
```

```bash
gcloud services enable serviceusage.googleapis.com
```

```bash
gcloud projects add-iam-policy-binding $GCP_PROJECT_ID \ 
    --member="serviceAccount:${TERRAFORM_SA}@${GCP_PROJECT_ID}.iam.gserviceaccount.com" \
    --role="roles/owner"
```

```bash
gcloud iam service-accounts keys create service-account.json --iam-account="${TERRAFORM_SA}@${GCP_PROJECT_ID}.iam.gserviceaccount.com"
```
