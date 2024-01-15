#!/bin/bash

set -eu

# print msg to stderr
debug_msg () {
	echo "$@" >/dev/stderr
}

if ! [[ -d plugins ]]; then
	debug_msg Creating directory \'plugins\'...
	mkdir plugins
fi

cd plugins

debug_msg downloading spark...
curl --silent \
	https://ci.lucko.me/job/spark/400/artifact/spark-bukkit/build/libs/spark-*-bukkit.jar/*zip*/libs.zip \
	    > spark.zip

debug_msg unzipping...
unzip -oq spark.zip # -o is not 'output', but 'overwrite'. -q is quiet

debug_msg deleting zip...
rm spark.zip
