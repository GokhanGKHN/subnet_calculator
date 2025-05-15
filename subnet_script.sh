#!/bin/bash

# IP alt ağ hesaplayıcı script
# Kullanım: ./subnet.sh 192.168.10.10/24

if [ $# -ne 1 ]; then
    echo "Kullanım: $0 <IP-adresi/prefix>"
    exit 1
fi

# IP adresi ve prefix'i ayır
IP_CIDR=$1
IP=$(echo $IP_CIDR | cut -d/ -f1)
PREFIX=$(echo $IP_CIDR | cut -d/ -f2)

# IP octets
IFS='.' read -r -a IP_OCTETS <<< "$IP"

# IP'yi binary formata çevir
IP_BIN=""
for octet in "${IP_OCTETS[@]}"; do
    binary=$(printf "%08d" $(bc <<< "obase=2;$octet"))
    IP_BIN="$IP_BIN$binary"
    if [ ${#IP_BIN} -lt 32 ]; then
        IP_BIN="$IP_BIN."
    fi
done

# Subnet maskesini hesapla
SUBNET_MASK=""
SUBNET_BIN=""
WILDCARD_MASK=""
WILDCARD_BIN=""

for ((i=1; i<=4; i++)); do
    bits=$((i * 8 > PREFIX ? PREFIX - (i-1) * 8 : 8))
    bits=$((bits < 0 ? 0 : bits))
    
    mask=$((256 - 2**(8-bits)))
    mask=$((mask < 0 ? 0 : mask))
    
    wildcard=$((255 - mask))
    
    SUBNET_MASK="${SUBNET_MASK}${mask}"
    WILDCARD_MASK="${WILDCARD_MASK}${wildcard}"
    
    if [ $i -lt 4 ]; then
        SUBNET_MASK="${SUBNET_MASK}."
        WILDCARD_MASK="${WILDCARD_MASK}."
    fi
    
    subnet_bin=$(printf "%08d" $(bc <<< "obase=2;$mask"))
    wildcard_bin=$(printf "%08d" $(bc <<< "obase=2;$wildcard"))
    
    SUBNET_BIN="${SUBNET_BIN}${subnet_bin}"
    WILDCARD_BIN="${WILDCARD_BIN}${wildcard_bin}"
    
    if [ $i -lt 4 ]; then
        SUBNET_BIN="${SUBNET_BIN}."
        WILDCARD_BIN="${WILDCARD_BIN}."
    fi
done

# Network adresini hesapla
NETWORK=""
NETWORK_BIN=""
for ((i=0; i<4; i++)); do
    mask_octet=$(echo $SUBNET_MASK | cut -d. -f$((i+1)))
    ip_octet=${IP_OCTETS[$i]}
    
    network_octet=$((ip_octet & mask_octet))
    NETWORK="${NETWORK}${network_octet}"
    
    network_bin=$(printf "%08d" $(bc <<< "obase=2;$network_octet"))
    NETWORK_BIN="${NETWORK_BIN}${network_bin}"
    
    if [ $i -lt 3 ]; then
        NETWORK="${NETWORK}."
        NETWORK_BIN="${NETWORK_BIN}."
    fi
done

# Broadcast adresini hesapla
BROADCAST=""
BROADCAST_BIN=""
for ((i=0; i<4; i++)); do
    network_octet=$(echo $NETWORK | cut -d. -f$((i+1)))
    wildcard_octet=$(echo $WILDCARD_MASK | cut -d. -f$((i+1)))
    
    broadcast_octet=$((network_octet | wildcard_octet))
    BROADCAST="${BROADCAST}${broadcast_octet}"
    
    broadcast_bin=$(printf "%08d" $(bc <<< "obase=2;$broadcast_octet"))
    BROADCAST_BIN="${BROADCAST_BIN}${broadcast_bin}"
    
    if [ $i -lt 3 ]; then
        BROADCAST="${BROADCAST}."
        BROADCAST_BIN="${BROADCAST_BIN}."
    fi
done

# Minimum ve maximum host adreslerini hesapla
MIN_HOST=""
MIN_HOST_BIN=""
MAX_HOST=""
MAX_HOST_BIN=""

IFS='.' read -r -a NETWORK_OCTETS <<< "$NETWORK"
IFS='.' read -r -a BROADCAST_OCTETS <<< "$BROADCAST"

for ((i=0; i<4; i++)); do
    if [ $i -eq 3 ]; then
        min_octet=$((NETWORK_OCTETS[i] + 1))
        max_octet=$((BROADCAST_OCTETS[i] - 1))
    else
        min_octet=${NETWORK_OCTETS[i]}
        max_octet=${BROADCAST_OCTETS[i]}
    fi
    
    MIN_HOST="${MIN_HOST}${min_octet}"
    MAX_HOST="${MAX_HOST}${max_octet}"
    
    min_bin=$(printf "%08d" $(bc <<< "obase=2;$min_octet"))
    max_bin=$(printf "%08d" $(bc <<< "obase=2;$max_octet"))
    
    MIN_HOST_BIN="${MIN_HOST_BIN}${min_bin}"
    MAX_HOST_BIN="${MAX_HOST_BIN}${max_bin}"
    
    if [ $i -lt 3 ]; then
        MIN_HOST="${MIN_HOST}."
        MAX_HOST="${MAX_HOST}."
        MIN_HOST_BIN="${MIN_HOST_BIN}."
        MAX_HOST_BIN="${MAX_HOST_BIN}."
    fi
done

# Host sayısını hesapla
HOST_COUNT=$((2 ** (32 - PREFIX) - 2))

# Sonuçları yazdır
printf "%-14s: %-15s %s\n" "Showing" "$IP_CIDR" "$IP_BIN"
printf "%-14s: %-15s %s\n" "Subnet Mask" "$SUBNET_MASK" "$SUBNET_BIN"
printf "%-14s: %-15s %s\n" "Wildcard Mask" "$WILDCARD_MASK" "$WILDCARD_BIN"
printf "%-14s: %d\n" "Host Count" "$HOST_COUNT"
printf "%-14s: %-15s %s\n" "Network" "$NETWORK" "$NETWORK_BIN"
printf "%-14s: %-15s %s\n" "Minimum Host" "$MIN_HOST" "$MIN_HOST_BIN"
printf "%-14s: %-15s %s\n" "Maximum Host" "$MAX_HOST" "$MAX_HOST_BIN"
printf "%-14s: %-15s %s\n" "Broadcast" "$BROADCAST" "$BROADCAST_BIN"
