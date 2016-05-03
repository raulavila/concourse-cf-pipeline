#!/bin/sh

cd codebase-repo

mvn clean package

if [ $? -ne 0 ]; then
  exit 1
fi

cp target/*.jar ../deploy-artifact
