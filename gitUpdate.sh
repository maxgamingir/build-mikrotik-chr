#!/bin/bash

EN_DATE=$(date "+%Y-%m-%d %H:%M:%S")


COMMIT_MSG="Auto commit on $EN_DATE (EN)"

git add .
git commit -m "$COMMIT_MSG"
git push