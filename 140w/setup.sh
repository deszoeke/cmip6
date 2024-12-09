# install the Google Cloud CLI tool (gcloud) with micromamba
micromamba create -n cmip6
micromamba activate cmip6
#micromamba install google-cloud-storage # no gcloud
micromamba install google-cloud-sdk

# set up authentication with Google Cloud
gcloud auth application-default login
# creates:
# ~/.config/gcloud/application_default_credentials.json
