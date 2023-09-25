#!/bin/bash

echo
echo "Date: $(date)"
echo "Username: $(whoami)"
echo "Hostname: $(hostname)"
echo

processor=$(sysctl -a machdep.cpu)
processor_model=$(echo "$processor" | sed -n 's|^machdep.cpu.brand_string:[ \t]*||p')
processor_architecture=$(echo $(uname -p))
processor_clock_frequency=$(sysctl -n hw.cpufrequency_max)
cpu_current_clock_speed=$(sysctl -n hw.cpufrequency)
processor_cores=$(echo "$processor" | sed -n 's|^machdep.cpu.core_count:[ \t]*||p')
processor_threads=$(echo "$processor" | sed -n 's|^machdep.cpu.thread_count:[ \t]*||p')
cpu_load=$(top -l 1 | awk '/CPU usage/ {print $3}')

echo "CPU:"
echo "  Model             – $processor_model"
echo "  Architecture      – $processor_architecture"
echo "  Frequency         – $processor_clock_frequency Hz"
echo "  Current frequency - $cpu_current_clock_speed Hz"
echo "  Cores number      – $processor_cores"
echo "  Threads number    – $processor_threads"
echo "  Load              - $cpu_load"
echo

L1_cache=$(echo "$(sysctl -a hw.l1icachesize)" | sed -n 's|^hw.l1icachesize:[ \t]*||p')
L2_cache=$(echo "$(sysctl -a hw.l2cachesize)" | sed -n 's|^hw.l2cachesize:[ \t]*||p')
L3_cache=$(echo "$(sysctl -a hw.l3cachesize)" | sed -n 's|^hw.l3cachesize:[ \t]*||p')

echo "Cache:"
echo "  L1 - $L1_cache bytes"
echo "  L2 - $L2_cache bytes"
echo "  L3 - $L3_cache bytes"
echo

RAM_all=$(echo "$(sysctl -a hw.memsize)" | sed -n 's|^hw.memsize:[ \t]*||p')
RAM_free=$(vm_stat | awk '/Pages free/ {print $3 * 4096}')

echo "RAM:"
echo "  All       – $RAM_all"
echo "  Available – $RAM_free"
echo

disk_info=$(df -H /)
disk_total=$(echo "$disk_info" | awk 'NR==2 {print $2}')
disk_available=$(echo "$disk_info" | awk 'NR==2 {print $4}')
partition_count=$(echo "$disk_info" | grep -c '^/dev/')
unallocated_space=$(diskutil info / | grep 'Free Space' | awk '{print $4}')
mounted_partitions=$(df -H | head -n 2 | sed -n '2 p' | awk '{print $1, $2}')
swap_info=$(sysctl -n debug.intel.swapCount)

echo "Hard drive:"
echo "  All               – $disk_total"
echo "  Available         – $disk_available"
echo "  Partition count   - $partition_count"
echo "  Unallocated space - $unallocated_space"
echo "  SWAP all          – $swap_info"
echo "  SWAP available    – $swap_info"
echo "  Mounted in /      – $mounted_partitions"
echo

echo "  Info on all partitions:"
echo "$disk_info"
echo

network_interfaces=$(networksetup -listallhardwareports | awk '/Hardware Port|Device/ {print $3}')
network_interface_count=$(echo "$network_interfaces" | wc -l)

interfaces=$(networksetup -listallhardwareports | awk '/Device:/{print $2}')
echo "Network:"
echo "  Number of interfaces - $(echo "$interfaces" | wc -l)"
echo

while read -r interface; do
  mac_address=$(ifconfig "$interface" | awk '/ether/{print $2}')
  ip_address=$(ifconfig "$interface" | awk '/inet /{print $2}')
  download=$(networkQuality -I $interface | sed -n '2 p')
  upload=$(networkQuality -I $interface | sed -n '3 p')

  echo "  Interface name: $interface"
  echo "  MAC: $mac_address"
  echo "  IP: $ip_address"
  if [[ "$download" == *"Error"* ]]; then
    echo "  Actual speed: no connection to the Internet"
  else
    echo "  Actual speed: $(echo "$download") | $(echo "$upload")"
  fi
  maxspeed=$(networksetup -getmedia $interface | sed -n '1 p' | cut -d: -f2-)
  if [[ "$maxspeed" == *"<full-duplex>" ]]; then
    echo "  Max supported speed:$(echo "$maxspeed") (1 Gbps)"
  elif [[ "$maxspeed" == *"not set" ]]; then
    echo "  Max supported speed:$(echo "$maxspeed")"
  else
    channel=$(system_profiler SPAirPortDataType | awk '/PHY Mode:/ { print $3 ; exit }')
    if [[ "$channel" == *"802.11n" ]]; then
      echo "  Max supported speed:$(echo "$maxspeed") Wi-Fi $channel (450 Mbps)"
    fi
  fi
  echo
done <<< "$interfaces"
