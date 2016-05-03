#!/bin/sh

cd codebase-repo
mvn clean package
cp target/*.jar ../deploy-artifact
