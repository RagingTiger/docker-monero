## About
Dockerized Monero binaries from: https://web.getmonero.org/downloads/#cli

## Build
To build the repository, pull the git repo, switch to the branch for your
CPU architecture (i.e. `AMD64`, `ARM32v7`), and `docker build`:
```
$ git clone https://github.com/RagingTiger/docker-monero
$ cd docker-monero
$ git checkout arm                 # or amd64
$ docker build -t monero:arm .
```

## Security
Here we discuss some of the security measures taken to ensure the integrity of
the docker images built from the `Monero` binaries.

### Binary Verification
You will notice that the `Dockerfile`, shown below, goes through all the
security checks [listed here](https://getmonero.org/resources/user-guides/verification-allos-advanced.html)
to validate the binaries by checking the hashes of the `tar` file:
```
$ cat Dockerfile
.
.
.

# set monero binary version
ARG MONERO_BIN_VER='monero-linux-x64-v0.15.0.5.tar.bz2'

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
.
.
.
```
So when you `docker build` the image, it will only succeed if everything checks
out via the process outlined in the
[Monero Docs](https://getmonero.org/resources/user-guides/verification-allos-advanced.html).

### Docker Trust
The images located at `tigerj/monero` have two signed tags: `amd64` and `arm`.
You can check for the trusted images as follows:
```
$ docker trust inspect tigerj/monero

Signatures for tigerj/monero

SIGNED TAG          DIGEST                                                             SIGNERS
amd64               94e5d94fe941832e64916fded39d65422066e4990fb55ff440b2ab5ce05a3dec   tigerj
arm                 b7f826e8b789f45e74980b86ae5e19294af1291932e0a20709c530baed567ff7   tigerj

List of signers and their keys for tigerj/monero

SIGNER              KEYS
tigerj              e85d1c1cb2c9

Administrative keys for tigerj/monero

  Repository Key:       d86a0081cf3939b9194e6252add1c3c3afe1b4bc01c1566423afe3636b4a6fc3
  Root Key:     3e7162f729a5355eaec6a12c2ed5ed5c97d63bd23f7ea3c5cac38832259fa10a
```

## Monero Daemon Docs
An attempt to document some of the features of the `Monero` daemon.

### monerod --help
```
$ docker run --rm -it tigerj/monero:amd64 monerod --help

Monero 'Carbon Chamaeleon' (v0.15.0.5-release)

Usage: monerod [options|settings] [daemon_command...]

Options:
  --help                                Produce help message
  --version                             Output version information
  --os-version                          OS for which this executable was
                                        compiled
  --config-file arg (=/home/monero/.bitmonero/bitmonero.conf, /home/monero/.bitmonero/testnet/bitmonero.conf if 'testnet', /home/monero/.bitmonero/stagenet/bitmonero.conf if 'stagenet')
                                        Specify configuration file
  --detach                              Run as daemon
  --pidfile arg                         File path to write the daemon's PID to
                                        (optional, requires --detach)
  --non-interactive                     Run non-interactive

Settings:
  --log-file arg (=/home/monero/.bitmonero/bitmonero.log, /home/monero/.bitmonero/testnet/bitmonero.log if 'testnet', /home/monero/.bitmonero/stagenet/bitmonero.log if 'stagenet')
                                        Specify log file
  --log-level arg
  --max-log-file-size arg (=104850000)  Specify maximum log file size [B]
  --max-log-files arg (=50)             Specify maximum number of rotated log
                                        files to be saved (no limit by setting
                                        to 0)
  --max-concurrency arg (=0)            Max number of threads to use for a
                                        parallel job
  --public-node                         Allow other users to use the node as a
                                        remote (restricted RPC mode, view-only
                                        commands) and advertise it over P2P
  --zmq-rpc-bind-ip arg (=127.0.0.1)    IP for ZMQ RPC server to listen on
  --zmq-rpc-bind-port arg (=18082, 28082 if 'testnet', 38082 if 'stagenet')
                                        Port for ZMQ RPC server to listen on
  --no-zmq                              Disable ZMQ RPC server
  --data-dir arg (=/home/monero/.bitmonero, /home/monero/.bitmonero/testnet if 'testnet', /home/monero/.bitmonero/stagenet if 'stagenet')
                                        Specify data directory
  --test-drop-download                  For net tests: in download, discard ALL
                                        blocks instead checking/saving them
                                        (very fast)
  --test-drop-download-height arg (=0)  Like test-drop-download but discards
                                        only after around certain height
  --testnet                             Run on testnet. The wallet must be
                                        launched with --testnet flag.
  --stagenet                            Run on stagenet. The wallet must be
                                        launched with --stagenet flag.
  --regtest                             Run in a regression testing mode.
  --fixed-difficulty arg (=0)           Fixed difficulty used for testing.
  --enforce-dns-checkpointing           checkpoints from DNS server will be
                                        enforced
  --prep-blocks-threads arg (=4)        Max number of threads to use when
                                        preparing block hashes in groups.
  --fast-block-sync arg (=1)            Sync up most of the way by using
                                        embedded, known block hashes.
  --show-time-stats arg (=0)            Show time-stats when processing
                                        blocks/txs and disk synchronization.
  --block-sync-size arg (=0)            How many blocks to sync at once during
                                        chain synchronization (0 = adaptive).
  --check-updates arg (=notify)         Check for new versions of monero:
                                        [disabled|notify|download|update]
  --fluffy-blocks                       Relay blocks as fluffy blocks
                                        (obsolete, now default)
  --no-fluffy-blocks                    Relay blocks as normal blocks
  --test-dbg-lock-sleep arg (=0)        Sleep time in ms, defaults to 0 (off),
                                        used to debug before/after locking
                                        mutex. Values 100 to 1000 are good for
                                        tests.
  --offline                             Do not listen for peers, nor connect to
                                        any
  --disable-dns-checkpoints             Do not retrieve checkpoints from DNS
  --block-download-max-size arg (=0)    Set maximum size of block download
                                        queue in bytes (0 for default)
  --sync-pruned-blocks                  Allow syncing from nodes with only
                                        pruned blocks
  --max-txpool-weight arg (=648000000)  Set maximum txpool weight in bytes.
  --pad-transactions                    Pad relayed transactions to help defend
                                        against traffic volume analysis
  --block-notify arg                    Run a program for each new block, '%s'
                                        will be replaced by the block hash
  --prune-blockchain                    Prune blockchain
  --reorg-notify arg                    Run a program for each reorg, '%s' will
                                        be replaced by the split height, '%h'
                                        will be replaced by the new blockchain
                                        height, '%n' will be replaced by the
                                        number of new blocks in the new chain,
                                        and '%d' will be replaced by the number
                                        of blocks discarded from the old chain
  --block-rate-notify arg               Run a program when the block rate
                                        undergoes large fluctuations. This
                                        might be a sign of large amounts of
                                        hash rate going on and off the Monero
                                        network, and thus be of potential
                                        interest in predicting attacks. %t will
                                        be replaced by the number of minutes
                                        for the observation window, %b by the
                                        number of blocks observed within that
                                        window, and %e by the number of blocks
                                        that was expected in that window. It is
                                        suggested that this notification is
                                        used to automatically increase the
                                        number of confirmations required before
                                        a payment is acted upon.
  --keep-alt-blocks                     Keep alternative blocks on restart
  --extra-messages-file arg             Specify file for extra messages to
                                        include into coinbase transactions
  --start-mining arg                    Specify wallet address to mining for
  --mining-threads arg                  Specify mining threads count
  --bg-mining-enable                    enable background mining
  --bg-mining-ignore-battery            if true, assumes plugged in when unable
                                        to query system power status
  --bg-mining-min-idle-interval arg     Specify min lookback interval in
                                        seconds for determining idle state
  --bg-mining-idle-threshold arg        Specify minimum avg idle percentage
                                        over lookback interval
  --bg-mining-miner-target arg          Specify maximum percentage cpu use by
                                        miner(s)
  --db-sync-mode arg (=fast:async:250000000bytes)
                                        Specify sync option, using format
                                        [safe|fast|fastest]:[sync|async]:[<nblo
                                        cks_per_sync>[blocks]|<nbytes_per_sync>
                                        [bytes]].
  --db-salvage                          Try to salvage a blockchain database if
                                        it seems corrupted
  --p2p-bind-ip arg (=0.0.0.0)          Interface for p2p network protocol
                                        (IPv4)
  --p2p-bind-ipv6-address arg (=::)     Interface for p2p network protocol
                                        (IPv6)
  --p2p-bind-port arg (=18080, 28080 if 'testnet', 38080 if 'stagenet')
                                        Port for p2p network protocol (IPv4)
  --p2p-bind-port-ipv6 arg (=18080, 28080 if 'testnet', 38080 if 'stagenet')
                                        Port for p2p network protocol (IPv6)
  --p2p-use-ipv6                        Enable IPv6 for p2p
  --p2p-ignore-ipv4                     Ignore unsuccessful IPv4 bind for p2p
  --p2p-external-port arg (=0)          External port for p2p network protocol
                                        (if port forwarding used with NAT)
  --allow-local-ip                      Allow local ip add to peer list, mostly
                                        in debug purposes
  --add-peer arg                        Manually add peer to local peerlist
  --add-priority-node arg               Specify list of peers to connect to and
                                        attempt to keep the connection open
  --add-exclusive-node arg              Specify list of peers to connect to
                                        only. If this option is given the
                                        options add-priority-node and seed-node
                                        are ignored
  --seed-node arg                       Connect to a node to retrieve peer
                                        addresses, and disconnect
  --tx-proxy arg                        Send local txes through proxy:
                                        <network-type>,<socks-ip:port>[,max_con
                                        nections][,disable_noise] i.e.
                                        "tor,127.0.0.1:9050,100,disable_noise"
  --anonymous-inbound arg               <hidden-service-address>,<[bind-ip:]por
                                        t>[,max_connections] i.e.
                                        "x.onion,127.0.0.1:18083,100"
  --hide-my-port                        Do not announce yourself as peerlist
                                        candidate
  --no-sync                             Don't synchronize the blockchain with
                                        other peers
  --no-igd                              Disable UPnP port mapping
  --igd arg (=delayed)                  UPnP port mapping (disabled, enabled,
                                        delayed)
  --out-peers arg (=-1)                 set max number of out peers
  --in-peers arg (=-1)                  set max number of in peers
  --tos-flag arg (=-1)                  set TOS flag
  --limit-rate-up arg (=2048)           set limit-rate-up [kB/s]
  --limit-rate-down arg (=8192)         set limit-rate-down [kB/s]
  --limit-rate arg (=-1)                set limit-rate [kB/s]
  --rpc-bind-port arg (=18081, 28081 if 'testnet', 38081 if 'stagenet')
                                        Port for RPC server
  --rpc-restricted-bind-port arg        Port for restricted RPC server
  --restricted-rpc                      Restrict RPC to view only commands and
                                        do not return privacy sensitive data in
                                        RPC calls
  --bootstrap-daemon-address arg        URL of a 'bootstrap' remote daemon that
                                        the connected wallets can use while
                                        this daemon is still not fully synced.
                                        Use 'auto' to enable automatic public
                                        nodes discovering and bootstrap daemon
                                        switching
  --bootstrap-daemon-login arg          Specify username:password for the
                                        bootstrap daemon login
  --rpc-bind-ip arg (=127.0.0.1)        Specify IP to bind RPC server
  --rpc-bind-ipv6-address arg (=::1)    Specify IPv6 address to bind RPC server
  --rpc-use-ipv6                        Allow IPv6 for RPC
  --rpc-ignore-ipv4                     Ignore unsuccessful IPv4 bind for RPC
  --rpc-login arg                       Specify username[:password] required
                                        for RPC server
  --confirm-external-bind               Confirm rpc-bind-ip value is NOT a
                                        loopback (local) IP
  --rpc-access-control-origins arg      Specify a comma separated list of
                                        origins to allow cross origin resource
                                        sharing
  --rpc-ssl arg (=autodetect)           Enable SSL on RPC connections:
                                        enabled|disabled|autodetect
  --rpc-ssl-private-key arg             Path to a PEM format private key
  --rpc-ssl-certificate arg             Path to a PEM format certificate
  --rpc-ssl-ca-certificates arg         Path to file containing concatenated
                                        PEM format certificate(s) to replace
                                        system CA(s).
  --rpc-ssl-allowed-fingerprints arg    List of certificate fingerprints to
                                        allow
  --rpc-ssl-allow-chained               Allow user (via --rpc-ssl-certificates)
                                        chain certificates
  --rpc-ssl-allow-any-cert              Allow any peer certificate
  --rpc-payment-address arg             Restrict RPC to clients sending
                                        micropayment to this address
  --rpc-payment-difficulty arg (=1000)  Restrict RPC to clients sending
                                        micropayment at this difficulty
  --rpc-payment-credits arg (=100)      Restrict RPC to clients sending
                                        micropayment, yields that many credits
                                        per payment
```
