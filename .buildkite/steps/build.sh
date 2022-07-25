#!/bin/bash


echo 'y' sudo apt install curl
echo 'y' sudo apt install git

curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
echo 'y' sudo apt update
echo 'y' sudo apt install gh

git remote update

git fetch --all
git rev-parse HEAD

GitHub_Sha=${BUILDKITE_COMMIT:-$(git rev-parse HEAD)}
echo "$BUILDKITE_BUILD_NUMBER"
echo "$BUILDKITE_BRANCH"


branchName=auto-"$BUILDKITE_BUILD_NUMBER"-"$BUILDKITE_BRANCH"

git checkout -b "$branchName "origin/main

git cherry-pick $GitHub_Sha
git push -u origin "$branchName"


gh auth login --with-token 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

gh pr create -b main  -H auto-created-branch -l autocreated --fill