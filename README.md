# Guardener Demo

This is a demo of the Guardener. Please follow the script in DEMO.md.

[Recording]()

## Getting Started
1. Create a fork of this repository
1. Generate a GitHub IAM identity locally using chainctl by running: `chainctl iam identities create github gh --github-repo={YOUR_REPO} --github-ref=refs/heads/main --role=owner --github-audience=https://github.com/{GITHUB_USER}`
1. Create a secret in Settings > Actions called `GUARDENER_DEMO_CHAINCTL_IDENTITY` and assign it the value above.
1. Open a PR in mono adding your org UIDP to allowed_groups [example](https://github.com/chainguard-dev/mono/pull/36116)

## Running CI
1. Access the pipeline in the Actions section
1. Select `Run the Guardener` and input your group ID, desired image tag name, and your repo namespace