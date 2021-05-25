#!/bin/bash
kubectl delete -f fulcimen-node-port-service.yaml
kubectl delete -f fulcimen-deployment.yaml
kubectl delete -f mysql-client-alpine-pod.yaml
kubectl delete -f mysql-external-name-service.yaml
#kubectl delete -f fulcimen-demo-resource-quota.yaml
kubectl delete -f fulcimen-demo-namespace.yaml
