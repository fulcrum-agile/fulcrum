#!/usr/bin/env bash

#CF Zero Downtime Deployment Script
echo "Starting"
echo "Download Cli"
cd ../
wget -qO cf-linux-amd64.tgz 'https://cli.run.pivotal.io/stable?release=linux64-binary&source=github' && \
  tar -zxvf cf-linux-amd64.tgz && \
  rm cf-linux-amd64.tgz
echo "Download Plugin"
wget -qO cf-autopilot-plugin 'https://github.com/contraband/autopilot/releases/download/0.0.2/autopilot-linux'
chmod +x cf-autopilot-plugin
export PATH=$PATH:$(pwd)

echo "CF Login"
cf api "${CF_API_URL}"
cf login -u "${CF_USER}" -p "${CF_PASS}" -o "${CF_ORG}" -s "${CF_SPACE}"
echo "Install Plugin"
echo "Y" | cf install-plugin -f cf-autopilot-plugin
echo "Start Deploy"
cd solarte-health/
rm -rf vendor/bundle
cf zero-downtime-push "solarte-health-web" -f ./web-manifest.yml
cf zero-downtime-push "solarte-health-sidekiq" -f ./worker-manifest.yml
cf logout
echo "Deploy Complete"

exit 0
