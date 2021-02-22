#!/usr/bin/env bash

echo "Checks if APP_VM is up"
echo "Wait 60 seconds"

sleep 60

response=$(curl -X "GET" "localhost:8080/actuator/health")
status=$(curl -o /dev/null -s -w "%{http_code}\n" "localhost:8080/actuator/health")

if [[ "$response" == '{"status":"UP"}' && "$status" == "200" ]]; then
  echo "APP_VM is up and running"
else
  echo "APP_VM is not running"
fi


