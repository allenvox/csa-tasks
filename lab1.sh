#!/bin/bash
echo "Date: $(date)"
echo "Username: $(whoami)"
echo "Hostname: $(hostname)"

processor=$(lscpu)
processor_model=$(echo "$processor" | sed -n 's|^Model name:[ \t]*||p')
processor_architecture=$(echo "$processor" | sed -n 's|^Architecture:[ \t]*||p')
processor_clock_frequency=$(echo "$processor" | sed -n 's|^CPU MHz:[ \t]*||p')
processor_cores=$(echo "$processor" | sed -n 's|^CPU(s):[ \t]*||p')
processor_threads_per_core=$(echo "$processor" | sed -n 's|^Thread(s) per core:[ \t]*||p')

echo "CPU:"
echo "  Model                   – $processor_model"
echo "  Architecture            – $processor_architecture"
echo "  Frequency               – $processor_clock_frequency MHz"
echo "  Cores number            – $processor_cores"
echo "  Threads per core number – $processor_threads_per_core"

RAM=$(free -h)
RAM_all=$(echo "$RAM"  | grep "Mem" | awk '{ print $2 }')
RAM_available=$(echo "$RAM"  | grep "Mem" | awk '{ print $7 }')
SWAP_all=$(echo "$RAM"  | grep "Swap" | awk '{ print $2 }')
SWAP_available=$(echo "$RAM"  | grep "Swap" | awk '{ print $4 }')

echo "RAM:"
echo "  All       – $RAM_all"
echo "  Available – $RAM_available"

hardDrive=$(df -h 2> /dev/null| grep '/$')
hardDrive_all=$(echo "$hardDrive" | awk '{ print $2 }')
hardDrive_available=$(echo "$hardDrive" | awk '{ print $4 }')
hardDrive_root=$(echo "$hardDrive" | awk '{ print $1 }')

echo "Hard drive:"
echo "  All            – $hardDrive_all"
echo "  Available      – $hardDrive_available"
echo "  Mounted in /   – $hardDrive_root"
echo "  SWAP all       – $SWAP_all"
echo "  SWAP available – $SWAP_available"

networkNames=$(ip address show | awk '/^[0-9]+:/ { print $2 }' | sed 's|:||')
echo "Network interfaces:"
echo "  Number of ifaces – $(echo $networkNames | wc -w)"

temp=$(mktemp)
num=0
for name in $networkNames; do
    num=$(($num + 1))
    mac=$(ip address show "$name" | grep 'link' | awk 'NR==1{print $2}')
    ip=$(ip address show "$name" | grep 'inet' | awk 'NR==1{print $2}')    
    echo "$num|$name|$mac|$ip" >> $temp
done
column -t -s '|' -N '#','Name','МАС','IP' $temp
rm $temp
