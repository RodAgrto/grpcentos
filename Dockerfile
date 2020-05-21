FROM centos:8

ARG       MAKE_J=6
ARG   GO_VERSION=1.14.3
ARG GRPC_VERSION=1.28.1

RUN yum update -y
RUN yum install -y autoconf automake binutils gdb cmake gcc gcc-c++ gettext libtool make patch pkgconfig  redhat-rpm-config elfutils
RUN yum install -y bzip2 wget git cpan nano vim vi python3
RUN yum group -y install "Development Tools"
RUN yum clean all

# GO language
RUN \
  cd /tmp && \
  wget -nv https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz && \
  tar -xvf go${GO_VERSION}.linux-amd64.tar.gz && \
  mv go /usr/local

ENV GOROOT=/usr/local/go
ENV GOPATH=${HOME}/go
ENV GOBIN=${GOPATH}/bin
ENV PATH=${GOPATH}/bin:${GOROOT}/bin:{$PATH}
RUN go version
RUN go get -u -v \
      google.golang.org/grpc \
      github.com/golang/protobuf/protoc-gen-go \
      github.com/go-delve/delve/cmd/dlv \
      github.com/stretchr/testify \
      go.mongodb.org/mongo-driver/mongo \
      github.com/gorilla/mux

# GRPC C++

ENV GRPC_DIR=/usr/local/grpc
ENV PATH=${GRPC_DIR}:${GRPC_DIR}/bin:${PATH}
RUN mkdir -p ${GRPC_DIR};
RUN git clone --recurse-submodules -b v${GRPC_VERSION} https://github.com/grpc/grpc
RUN cd grpc \
    && mkdir -p cmake/build \
    && pushd cmake/build \
    && cmake -DgRPC_INSTALL=ON -DgRPC_BUILD_TESTS=OFF -DCMAKE_INSTALL_PREFIX=${GRPC_DIR} ../.. \
    && make -j ${MAKE_J} \
    && make install  \
    && popd
# Clean
RUN rm -rf grpc

# GRPC Java
RUN cd #; git clone -b v${GRPC_VERSION} https://github.com/grpc/grpc-java.git

# GRPC python
RUN python3 -m pip install --upgrade pip
RUN python3 -m pip install grpcio
RUN python3 -m pip install grpcio-tools
