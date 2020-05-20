FROM centos:8

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
RUN echo 'export GOROOT=${GOROOT}' >>/etc/profile 
RUN echo 'export GOPATH=${GOPATH}'>>/etc/profile
RUN echo 'export GOBIN=${GOBIN}'>>/etc/profile
RUN echo 'export PATH=${PATH}'>>/etc/profile
RUN go version
RUN go get -u google.golang.org/grpc github.com/golang/protobuf/protoc-gen-go github.com/go-delve/delve/cmd/dlv
RUN go get -u github.com/stretchr/testify go.mongodb.org/mongo-driver/mongo github.com/gorilla/mux

# GRPC C++ 
ENV GRPC_DIR=/usr/local/local
RUN echo 'export PATH="${PATH}:${GRPC_DIR}/bin'>>/etc/profile
RUN mkdir -p ${GRPC_DIR} ;
RUN git clone --recurse-submodules -b v${GRPC_VERSION} https://github.com/grpc/grpc
RUN cd grpc \
    && mkdir -p cmake/build \
    && pushd cmake/build \
    && cmake -DgRPC_INSTALL=ON -DgRPC_BUILD_TESTS=OFF -DCMAKE_INSTALL_PREFIX=${GRPC_DIR} ../.. \
    && make -j 4 \
    && make install  \
    && popd
# Clean
RUN rm -rf grpc

# GRPC Java
RUN git clone -b v1.29.0 https://github.com/grpc/grpc-java.git
RUN cd 