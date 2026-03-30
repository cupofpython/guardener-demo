## How does it work?
Let's review the [architecture](https://github.com/chainguard-dev/mono/blob/main/containers/dfc/docs/architecture.md).

The agent loop runs on the server while Docker operations execute on the client. This keeps source code local and allows the server to use Vertex AI or other backends. We migrate one instruction at a time to catch issues early: Claude receives the original Dockerfile, migrated-so-far, and current instruction, then researches, builds and tests translation, and completes the layer.