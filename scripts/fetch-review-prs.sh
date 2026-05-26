#!/bin/bash
# Fetch PRs where I'm registered as a reviewer

gh search prs \
  --review-requested=@me \
  --state=open \
  --json repository,title,number,url,createdAt,labels,author,isDraft \
  --limit 100
