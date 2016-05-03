#!/bin/sh

cd codebase-repo
ls
mvn clean package
cp target/*.jar ../deploy-artifact
ls
