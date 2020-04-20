# base image for verifiying binaries
FROM ubuntu:16.04 as verifier

# update and add utils
RUN apt-get update && apt-get install -y \
    bzip2 \
    wget \
    gnupg2 \
    libdigest-sha-perl

# prepare workdir and get monero files
COPY monero /monero
WORKDIR /monero

# set monero binary version
ARG MONERO_BIN_VER='monero-linux-armv7-v0.15.0.5.tar.bz2'

# verify
ENV FINGERPRINT='Key fingerprint = 81AC 591F E9C4 B65C 5806  AFC3 F0AF 4D46 2A0B DF92'
RUN set -ex && \
    if gpg --keyid-format long --with-fingerprint binaryfate.asc | grep "${FINGERPRINT}" && \
       gpg --import binaryfate.asc && \
       gpg --verify hashes.txt && \
       cat hashes.txt | grep "$(shasum -a 256 ${MONERO_BIN_VER} | awk '{print $1}')" ; then \
         echo "Verification Success" ; \
         tar -xvjf ${MONERO_BIN_VER} -C /home --strip-components=1; \
         ls -lha /home ; \
    else \
      echo "Verification Failed"; exit 1; \
    fi
    
# runtime stage
FROM ubuntu:16.04

RUN set -ex && \
    apt-get update && \
    apt-get --no-install-recommends --yes install ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt
COPY --from=verifier /home /usr/local/bin/

# Create monero user
RUN adduser --system --group --disabled-password monero && \
        mkdir -p /wallet /home/monero/.bitmonero && \
        chown -R monero:monero /home/monero/.bitmonero && \
        chown -R monero:monero /wallet

# Contains the blockchain
VOLUME /home/monero/.bitmonero

# Generate your wallet via accessing the container and run:
# cd /wallet
# monero-wallet-cli
VOLUME /wallet

EXPOSE 18080
EXPOSE 18081

# switch to user monero
USER monero

CMD ["monerod", "--p2p-bind-ip=0.0.0.0", "--p2p-bind-port=18080", "--rpc-bind-ip=0.0.0.0", "--rpc-bind-port=18081", "--non-interactive", "--confirm-external-bind"]

