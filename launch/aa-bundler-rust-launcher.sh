#!/bin/bash 
# Launcher script for the aa-bundler in Rust.
set -x 
TEST_DIR=`dirname \`realpath $0\``
echo $TEST_DIR
cd $TEST_DIR
case $1 in

 name)
	echo "aa-bundler in Rust"
	;;

 start)
	docker-compose up -d
    pushd /chain/eth/aa-bundler
    cargo build
    popd
    RUST_LOG=aa_bundler=TRACE RUST_BACKTRACE=full /chain/eth/aa-bundler/target/debug/silius bundler \
        --verbosity 4 \
        --eth-client-address http://127.0.0.1:8545 \
        --mnemonic-file keys/0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 \
        --beneficiary 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 \
        --entry-points 0x5ff137d4b0fdcd49dca30c7cf57e578a026d2789 \
        --http \
        --http.addr 0.0.0.0 \
        --http.port 3000 \
        --http.api eth,debug,web3 \
        --ws \
        --ws.addr 0.0.0.0 \
        --ws.port 3001 \
        --ws.api eth,debug,web3 & echo $! > $TEST_DIR/bundler.pid
	cd $TEST_DIR/../@account-abstraction 
    pwd
    yarn deploy --network localhost
	;;
 stop)
 	docker-compose down
    kill $(cat bundler.pid)
	;;

 *)
	echo "usage: $0 {start|stop|name}"
esac