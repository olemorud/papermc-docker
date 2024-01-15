#!/bin/bash

set -eu

memory_heuristic () {
	if [[ -v memory_heuristic_cache ]]; then
		echo $memory_heuristic_cache
		return
	fi

	local total_memory=$(free | awk  '/Mem:/{print $2}')

	# Below 8 GB we assume this is running on a dedicated server, so we
	# allocate all but 10mb of the RAM. Otherwise allocate 30%. This is not
	# based on any profiling or testing
	if [[ total_memory -lt 8388608 ]]; then
		memory_heuristic_cache=$((total_memory - 10240))
	else
		memory_heuristic_cache=$((total_memory * 3/10))
	fi

	memory_heuristic_cache+=k

	echo $memory_heuristic_cache
}

# https://docs.papermc.io/paper/aikars-flags
args=()
args+=("-Xms$(memory_heuristic)")
args+=("-Xmx$(memory_heuristic)")
args+=("-XX:+UnlockExperimentalVMOptions")
args+=("-XX:+ParallelRefProcEnabled")
args+=("-XX:+DisableExplicitGC")
args+=("-XX:+AlwaysPreTouch")
args+=("-XX:+PerfDisableSharedMem")
args+=("-XX:MaxGCPauseMillis=200")
args+=("-XX:InitiatingHeapOccupancyPercent=15")
args+=("-XX:SurvivorRatio=32")
args+=("-XX:MaxTenuringThreshold=1")
# G1 options
args+=("-XX:+UseG1GC")
args+=("-XX:G1NewSizePercent=30")
args+=("-XX:G1MaxNewSizePercent=40")
args+=("-XX:G1HeapRegionSize=8M")
args+=("-XX:G1ReservePercent=20")
args+=("-XX:G1HeapWastePercent=5")
args+=("-XX:G1MixedGCCountTarget=4")
args+=("-XX:G1MixedGCLiveThresholdPercent=90")
args+=("-XX:G1RSetUpdatingPauseTimePercent=5")
mkdir -p logs
args+=("-Xlog:gc*:logs/gc.log:time,uptime:filecount=5,filesize=1M")
args+=("-Dcom.mojang.eula.agree=true")

args+=("-jar" "paper.jar" "--nogui")

exec java ${args[@]}
