#!/bin/bash

date >> /var/log/gocd-dashboard-cleanup.log
echo "Running GoCD patch to cleanup gp2gp dashboard" >> /var/log/gocd-dashboard-cleanup.log
find /var/gocd-data/data/artifacts/pipelines/prm-gp2gp-dashboard.cross-account -mtime 7 -path '*public*' -exec rm -f {} \; >> /var/log/gocd-dashboard-cleanup.log
