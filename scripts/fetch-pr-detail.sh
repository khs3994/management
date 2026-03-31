#!/bin/bash
# Fetch detailed information of a specific PR
# Usage: ./fetch-pr-detail.sh <owner/repo> <pr-number>

if [ $# -ne 2 ]; then
  echo "Usage: $0 <owner/repo> <pr-number>"
  exit 1
fi

REPO=$1
PR_NUMBER=$2

gh pr view "$PR_NUMBER" --repo "$REPO" \
  --json title,body,labels,author,createdAt,updatedAt,state,additions,deletions,changedFiles,reviewRequests,assignees,milestone,url,isDraft,number
