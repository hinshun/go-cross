# go-cross

`hinshun/go-cross` is a Docker image to cross compile golang binaries and plugins to linux/darwin. It is based off work from `docker/cli`:
- https://hub.docker.com/r/dockercore/golang-cross
- https://github.com/docker/cli/tree/ee461303f9e74937a0a598650249f4331b1dd498/scripts/build

# Cross-compiling using docker build

Using `hinshun/go-cross:mod` to cache go modules and `hinshun/go-cross:build` that has [ONBUILD](https://docs.docker.com/engine/reference/builder/#onbuild) triggers you can define a `Dockerfile` with only the following:

```Dockerfile
FROM hinshun/go-cross:mod AS mod
FROM hinshun/go-cross:build
```

For example, if my project looks like this:
```
❯ tree
.
├── cmd
│   └── program
│       └── main.go
├── Dockerfile
├── go.mod
└── go.sum
```

Then you can cross-compile the program like so (`BUILDMODE` and `LDFLAGS` are optional):

```sh
docker build -t my-cross-compile --build-arg PKG="./cmd/program" --build-arg BUILDMODE="default" --build-arg LDFLAGS="" .
```

Extract the binaries by creating a temporary container and `docker cp` them out.
```sh
mkdir bin
docker create --name tmp my-cross-compile bash
docker cp tmp:/root/go/bin/. bin
docker rm tmp
```

## Private go modules
If you have private go modules, you can use that as long as the following are true:
- The stage is set to `AS mod`
- The go module cache is in `/root/.cache/go-build` and `/root/go/pkg/mod`

```Dockerfile
FROM golang:1.11-alpine AS mod
ENV GOPATH=/root/go
ENV GOCACHE=/root/.cache/go-build
# Copy or mount in SSH, certificates, etc...
RUN go mod download

FROM hinshun/go-cross:build
```
