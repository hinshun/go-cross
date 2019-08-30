FROM dockercore/golang-cross:1.12.5
ENV DISABLE_WARN_OUTSIDE_CONTAINER=1
ENV GOPATH=/root/go
ENV GOCACHE=/root/.cache/go-build
COPY scripts/ /cross/
