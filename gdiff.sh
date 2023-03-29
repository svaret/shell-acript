#!/bin/bash

branch1=""
branch2=""

main() {
  checkArguments
  if [ $# -eq 0 ]; then
    compareCurrentBranchWithMaster
  elif [ $# -eq 1 ]; then
    compareBranchWithCurrent $1
  elif [ $# -eq 2 ]; then
    compareTwoBranches $1 $2
  else
    echo "Usage: `basename $0` [a-branch] [another-branch]"
    exit
  fi

  # get the branches logs
  git log --pretty=format:"%h %ad [%an] %s" --date=short $branch1 > /tmp/b1.log
  git log --pretty=format:"%h %ad [%an] %s" --date=short $branch2 > /tmp/b2.log
  echo ""

  # output
  width=$(( $(tput cols) / 2 ))
  printf "%-${width}s%s\n" "$branch1" "$branch2"
  echo ""
  diff -W $(( $(tput cols) - 2 )) -y --suppress-common-lines /tmp/b1.log /tmp/b2.log
}

function pullBranch() {
  git fetch -a
  git checkout $1
  git pull
  git switch -
}

function doesBranchExist() {
  git rev-parse --verify $1 > /dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo "Error: branch $1 does not exist"
    exit
  fi
}

function compareTwoBranches() {
  branch1=$1
  branch2=$2
  doesBranchExist $branch1
  doesBranchExist $branch2
  pullBranch $branch1
 
  pullBranch $branch2
}

function compareBranchWithCurrent() {
  branchToCompareWith=$1
  doesBranchExist $branchToCompareWith
  git pull
  pullBranch $branchToCompareWith
  branch1=$(git rev-parse --abbrev-ref HEAD)
  branch2=$branchToCompareWith
}

function compareCurrentBranchWithMaster() {
  pullBranch master
  branch1=master
  branch2=$(git rev-parse --abbrev-ref HEAD)
}

function checkArguments() {
  if [ $# -gt 2 ]; then
    echo "Usage: `basename $0` a-branch [another-branch]"
    exit
  fi
}

main "$@"
