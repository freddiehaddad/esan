#!/bin/bash
#
# Configure NVMe over fabrics using NVMe/TCP
#
# In a Non-volatile Memory Express (NVMe) over TCP (NVMe/TCP) setup, the host
# mode is fully supported and the controller setup is not supported.
#
# NVMe-TCP Drawbacks
#   - TCP can increase CPU usage because certain operations like calculating
#     checksums must be done by the CPU as part of the TCP stack.
#   - Although TCP provides high performance with low latency, when compared
#     with RDMA implementations, latency could affect some applications in part
#     because of additional copies of data that must be maintained.
#
# See: https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html/managing_storage_devices/configuring-nvme-over-fabrics-using-nvme-tcp_managing-storage-devices
# See: https://blogs.oracle.com/linux/post/nvme-over-tcp
#

# Name of the executable script.
EXECUTABLE="$(basename "$0")"
# Device to share
DEVICE="/dev/nvme0n2"
# Subsystem name
SUBSYS_NAME="nvmet"
# Subsystem path
SUBSYS_ID=1
# IP address
IP=$(hostname -I | awk '{print $1}')
# Getopts
# Network port to listen on
PORT=4420

OPTSTRING=":d:i:p:s:h"
while getopts "$OPTSTRING" option; do
	case "$option" in
	d)
		DEVICE=$OPTARG
		;;
	i)
		IP=$OPTARG
		;;
	p)
		PORT=$OPTARG
		;;
	s)
		SUBSYS_ID=$OPTARG
		;;
	h)
		printf "Usage: %s [OPTIONS]\n" "$EXECUTABLE"
		printf "Utility script to configure NVMe/TCP.\n"
		printf "Example: %s -d \"%s\" -i \"%s\" -p %d -s %d\n" "$EXECUTABLE" "$DEVICE" "$IP" "$PORT" "$SUBSYS_ID"
		printf "\n"
		printf "Options:\n"
		printf " -d        storage device to use\n"
		printf "           (default: %s)\n" "$DEVICE"
		printf " -i        IP address of host\n"
		printf "           (default: %s)\n" "$IP"
		printf " -p        network port to listen on\n"
		printf "           (default: %d)\n" "$PORT"
		printf " -n        subsystem name\n"
		printf "           (default: %s)\n" "$SUBSYS_NAME"
		printf " -s        subsystem ID\n"
		printf "           (default: %d)\n" "$SUBSYS_ID"
		exit 0
		;;
	?)
		printf "Usage: %s [OPTIONS]\n" "$EXECUTABLE"
		printf "Try '%s -h' for more information.\n" "$EXECUTABLE"
		exit 1
		;;
	esac
done

# Stop firewall service
if ! systemctl stop firewalld; then
	printf "Failed to stop firewalld\n"
	exit 1
fi

# Load kernel modules
for module in nvmet nvmet-tcp; do
	if ! modprobe "$module"; then
		printf "Failed to load module: %s\n" "$module"
		exit 1
	fi
done

# Create NVMe subsystem
SUBSYS_PATH="/sys/kernel/config/nvmet/subsystems/$SUBSYS_NAME$SUBSYS_ID"
echo "Subsystem Path:"
echo "$SUBSYS_PATH"
if ! mkdir -p "$SUBSYS_PATH"; then
	printf "Failed to create subsystem directory \"%s\"\n" "$SUBSYS_NAME$SUBSYS_PATH"
	exit 1
fi

# Allow any host to access the subsystem
if ! echo 1 >"$SUBSYS_PATH/attr_allow_any_host"; then
	printf "Failed to set attr_allow_any_host\n"
	exit 1
fi

# Create namespace directory
NS_PATH="$SUBSYS_PATH/namespaces/$SUBSYS_ID"
echo "Namspace Path:"
echo "$NS_PATH"
if ! mkdir -p "$NS_PATH"; then
	printf "Failed to create namespace directory: \"%s\"\n" "$NS_PATH"
	exit 1
fi

# Set device path for the namespace
if ! echo -n "$DEVICE" >"$NS_PATH/device_path"; then
	printf "Failed to set device path\n"
	exit 1
fi

# Enable the namespace
if ! echo 1 >"$NS_PATH/enable"; then
	printf "Failed to enable namespace\n"
	exit 1
fi

# Create NVMe port directory
PORT_PATH="/sys/kernel/config/nvmet/ports/$SUBSYS_ID"
echo "Port Path:"
echo "$PORT_PATH"
if ! mkdir -p "$PORT_PATH"; then
	printf "Failed to create port directory: \"%s\"\n" "$PORT_PATH"
	exit 1
fi

# Set transport service ID
if ! echo "$PORT" >"$PORT_PATH/addr_trsvcid"; then
	printf "Failed to set transport service ID\n"
	exit 1
fi

# Get IP address
if [ -z "$IP" ]; then
	printf "Failed to get IP address\n"
	exit 1
fi

# Set transport address
if ! echo "$IP" >"$PORT_PATH/addr_traddr"; then
	printf "Failed to set transport address\n"
	exit 1
fi

# Set transport type
if ! echo "tcp" >"$PORT_PATH/addr_trtype"; then
	printf "Failed to set transport type\n"
	exit 1
fi

# Set address family
if ! echo "ipv4" >"$PORT_PATH/addr_adrfam"; then
	printf "Failed to set address family\n"
	exit 1
fi

# Link subsystem to port
if ! ln -s "$SUBSYS_PATH" "$PORT_PATH/subsystems/$SUBSYS_NAME$SUBSYS_ID"; then
	printf "Failed to link subsystem to port\n"
	exit 1
fi

printf "NVMe subsystem and port configuration completed successfully"
