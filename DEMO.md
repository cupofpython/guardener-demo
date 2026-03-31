# Demo for the Guardner


## What problem does this solve?

The Guardener is an AI tool that migrates customer Dockerfiles to use Chainguard Images (cgr.dev/chainguard/chainguard-base). It uses Claude as the migration engine — iteratively converting instructions, building images, comparing results, and fixing issues until the Dockerfile builds a Chainguard-based image.

This allows prospects and customers to convert their Dockerfiles with ease, and optimize them to align with best practices.

## Tell :star:

In this demo, we are going to see:
- How the guardener works in practice. We will review the migration of a Dockerfile including its iterative migration steps, build, and functional tests
- We will optimize a migrated Dockerfile for container image best practices and explore the value of the optimizations
- Finally, we will see how we can scale the Guardener's impact via CI

## Show :star:
### Getting Started

First, authenticate with `chainctl`:

`chainctl auth login`

Next, obtain your Chainguard registry's group ID, provided $DOMAIN is your org name.

```
export DOMAIN={YOUR_DOMAIN}
GROUP=$(chainctl iam organizations list -o json | \
            jq -r --arg domain "$DOMAIN" \
            '.items[] | select(.name == $domain) | .id')
echo $GROUP
```

### Conversion

Let's convert our Dockerfile to use the Chainguard base. Simply run:

```
chainctl agent dockerfile build -f Dockerfile -t myapp:cg \
  --group $GROUP  
```
This will do several steps:
- Parse the Dockerfile
- Translate the equivalents for each instruction
- Build both images and compare them with Syft
- Adjust and retry if differences are found
- Run functional tests

Example Output:
```
Test Summary                                                                                                                                                                                                  
                                                                                                                                                                                                                
  9 passed, 0 failed out of 9 total tests                                                                                                                                                                       
                                                                                                                                                                                                                
   Status                              │ Test Name                                                                                │ Type                                │ Error                                 
  ─────────────────────────────────────┼──────────────────────────────────────────────────────────────────────────────────────────┼─────────────────────────────────────┼─────────────────────────────────────  
   ✓                                   │ Image config: CMD=['python3','app.py'] and WORKDIR=/app match original                   │ final_validation                    │                                       
   ✓                                   │ python3 binary present and functional (Wolfi: 3.13.12 vs Ubuntu: 3.10.12)                │ final_validation                    │                                       
   ✓                                   │ curl binary present and functional (8.19.0-DEV with HTTPS/HTTP2/HTTP3 support)           │ final_validation                    │                                       
   ✓                                   │ git binary present and functional (2.53.0)                                               │ final_validation                    │                                       
   ✓                                   │ Python stdlib modules OK: ssl, urllib.request, json, sys, pathlib, hashlib               │ final_validation                    │                                       
   ✓                                   │ SSL certificates configured correctly (SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt) │ final_validation                    │                                       
   ✓                                   │ WORKDIR /app exists and contains expected files (DEMO.md, Dockerfile, README.md)         │ final_validation                    │                                       
   ✓                                   │ curl HTTPS failure was DNS-only (no network in sandbox), not a TLS/cert issue            │ final_validation                    │                                       
   ✓                                   │ All three required packages installed: curl, git, python3 (via apk)                      │ final_validation                    │      
   ```

### Optimization

While converted Dockerfiles may be funtionally equivalent, we want to ensure we are following all of the container best practices. Let's optimize our new Dockerfile.

```
chainctl agent dockerfile optimize -f Dockerfile.migrated \
  --group $GROUP
```

This will optimize the Dockerfile for general best practices including:

| Optimizer | What it does | Value Add |
| ----- | ----- |  ----- |
| cache | Reorder instructions for better layer caching | Order of instructons can determine where you break a cache, since an instruction change causes the build cache to bust and subsequent steps to be re-ran. This optimization re-orders instructions to leverage the build cache and lead to faster builds and reduced CI consumption | 
| cleanup | Remove duplicate and redundant instructions | For example, copying one file vs COPY . . |
| layers | Combine RUN commands, merge package installs | Merging commands together reduces the number of layers created, making for a smaller image, improving pull times and reducing CI minute consumption |
| security | Add --no-cache to apk, flag secrets, suggest non-root USER | Adding -no-cache to `apk add` command skips writing packages to cache in layer, reducing layer size. Suggesting nonroot ensures protection from root access to the host, and removes ability to install new packages |
| multi-stage| Transform to multi-stage builds with Chainguard runtime images | A key benefit of Chainguard images is the -dev variant with package manager and shell vs the distroless runtime variant. Splitting your Dockerfile into multiple stages allows for producing a reduced runtime image with limited permissions and attack surface |
| native-packages | Replace curl/bash installs with native apk packages | Ensuring you get full provenance of packages, not just the binary |

Let's review the output. Open `Dockerfile.migrated.optimized` to see it applied.

[Ouput example, walk through some of the suggestions]

### Beyond the Laptop -- Running in CI

You can leverage the Guardener in CI/CD to migrate your Dockerfiles at scale. In this example, we will show the migration as a pre-build job, then build and push the image based on the new Dockerfile to a registry.

Navigate to `.github/workflows/pipeline.yml`

We simply install `chainctl` and authenticate, then run the same Guardener commands as jobs in the GitHub Actions pipeline.

## Tell :star:

### What we saw
In this demo, we saw the Guardener migrate a Dockerfile, optimize it further, and conversion occur in a CI pipeline. By using the Guardener, you can get started with Chainguard images quickly in your builds, decreasing your time to value and increasing your impact with low-to-zero CVE images in your ecosystem.
