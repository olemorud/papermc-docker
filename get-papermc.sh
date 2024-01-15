#!/bin/bash

set -eu

# print msg to stderr
debug_msg () {
	echo "$@" >/dev/stderr
}

# get the download url for the latest version
latest_url() {
	if [[ -v latest_url_cache ]]; then
		echo $latest_url_cache
		return
	fi
	debug_msg "finding download url to latest version..."

	local url=https://papermc.io/api/v2/projects/paper

	local minecraft_version=$(curl --silent "$url" | jq -r '.versions[-1]')
	url+=/versions/$minecraft_version

	local papermc_build=$(curl --silent $url | jq -r '.builds[-1]')
	url+=/builds/$papermc_build

	latest_url_cache=$url/downloads/paper-$minecraft_version-$papermc_build.jar
	debug_msg "Found url" $latest_url_cache
	echo $latest_url_cache
}

debug_msg "downloading..."
curl --silent $(latest_url) > paper.jar


