FROM gcr.io/kaniko-project/executor:debug AS kaniko
FROM ubuntu:20.04

# To make it easier for build and release pipelines to run apt-get,
# configure apt to not require confirmation (assume the -y argument by default)
ENV DEBIAN_FRONTEND=noninteractive
RUN echo "APT::Get::Assume-Yes \"true\";" > /etc/apt/apt.conf.d/90assumeyes

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    wget \
    curl \
    sshpass \
    openssh-client \
    jq \
    git \
    iputils-ping \
    libcurl4 \
#    libicu60 \
    libunwind8 \
    netcat \
    libssl1.0 \
    apt-transport-https \
    unzip \
    tzdata \
    python3-pip \
  && wget http://ftp.us.debian.org/debian/pool/main/i/icu/libicu67_67.1-7_amd64.deb \
  && dpkg -i libicu67_67.1-7_amd64.deb \
  && rm -rf /var/lib/apt/lists/*

RUN curl -LsS https://aka.ms/InstallAzureCLIDeb | bash \
  && rm -rf /var/lib/apt/lists/*

RUN pip3 install ansible-tower-cli
RUN pip3 install awxkit
# Can be 'linux-x64', 'linux-arm64', 'linux-arm', 'rhel.6-x64'.
ENV TARGETARCH=linux-x64

#
# Add kaniko to this image by re-using binaries and steps from official image
#
COPY --from=kaniko /kaniko/ /kaniko/
COPY --from=kaniko /kaniko/warmer /kaniko/warmer
COPY --from=kaniko /kaniko/docker-credential-gcr /kaniko/docker-credential-gcr
COPY --from=kaniko /kaniko/docker-credential-ecr-login /kaniko/docker-credential-ecr-login
# COPY --from=kaniko /kaniko/docker-credential-acr /kaniko/docker-credential-acr
COPY --from=kaniko /kaniko/.docker /kaniko/.docker
COPY --from=busybox:1.32.0 /bin /busybox

ENV PATH $PATH:/usr/local/bin:/kaniko:/busybox

