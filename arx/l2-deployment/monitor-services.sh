#!/bin/bash

# Celo Sepolia L3 - Continuous Service Monitor
# This script continuously monitors all services and restarts them if they crash

DEPLOYMENT_DIR="/Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment"
OPTIMISM_DIR="/Users/arkoroy/Desktop/arx/Arx-Protocol/arx/optimism/optimism"
LOG_DIR="$DEPLOYMENT_DIR/logs"
MONITOR_LOG="$LOG_DIR/monitor.log"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Create logs directory
mkdir -p "$LOG_DIR"

# Function to log messages
log_message() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $1" | tee -a "$MONITOR_LOG"
}

# Function to check if process is running
is_running() {
    local pid=$1
    if [ -z "$pid" ]; then
        return 1
    fi
    if kill -0 "$pid" 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to start a service
start_service() {
    local service=$1
    local binary=$2
    local args=$3
    local pid_file="$DEPLOYMENT_DIR/${service}.pid"
    
    log_message "${YELLOW}Starting ${service}...${NC}"
    
    if [ ! -f "$binary" ]; then
        log_message "${RED}❌ Binary not found: $binary${NC}"
        return 1
    fi
    
    # Start service
    nohup $binary $args > "$LOG_DIR/${service}.log" 2>&1 &
    local pid=$!
    
    echo "$pid" > "$pid_file"
    log_message "${GREEN}✅ ${service} started (PID: $pid)${NC}"
    return 0
}

# Function to restart a service
restart_service() {
    local service=$1
    local binary=$2
    local args=$3
    local pid_file="$DEPLOYMENT_DIR/${service}.pid"
    
    if [ -f "$pid_file" ]; then
        local old_pid=$(cat "$pid_file")
        if is_running "$old_pid"; then
            log_message "${YELLOW}Killing ${service} (PID: $old_pid)${NC}"
            kill "$old_pid" 2>/dev/null || true
            sleep 2
        fi
    fi
    
    start_service "$service" "$binary" "$args"
}

# Function to monitor services
monitor_services() {
    log_message "${BLUE}=== Starting Service Monitor ===${NC}"
    log_message "Monitoring interval: 30 seconds"
    log_message "Services: op-node, op-batcher, op-proposer"
    
    # Define services
    local services=("op-node" "op-batcher" "op-proposer")
    
    # Initial startup
    start_service "op-node" "$OPTIMISM_DIR/op-node/bin/op-node" "--l1=https://rpc.ankr.com/celo_sepolia --l2=http://localhost:8551 --l2.jwt-secret=$DEPLOYMENT_DIR/jwt-secret.txt --rollup.config=$DEPLOYMENT_DIR/rollup.json --rpc.addr=0.0.0.0 --rpc.port=9545 --metrics.enabled --metrics.addr=0.0.0.0 --metrics.port=7300 --p2p.disable"
    sleep 3
    
    start_service "op-batcher" "$OPTIMISM_DIR/op-batcher/bin/op-batcher" "--l1-eth-rpc=https://rpc.ankr.com/celo_sepolia --l2-eth-rpc=http://localhost:8545 --private-key=f2d83d4bb547d821db1e33c6a488a9350d263dee584acadbd6603f862931349c --metrics.enabled --metrics.addr=0.0.0.0 --metrics.port=7301"
    sleep 3
    
    start_service "op-proposer" "$OPTIMISM_DIR/op-proposer/bin/op-proposer" "--l1-eth-rpc=https://rpc.ankr.com/celo_sepolia --l2-eth-rpc=http://localhost:8545 --private-key=9ebad8e26c7d816238400f806f0c81b25ce6f8e937c3386efc5223c5bad12a02 --l2-output-oracle-address=0x6C5Fd71d75Fa4b6054E0b9b5cC154AEBb18930c1 --metrics.enabled --metrics.addr=0.0.0.0 --metrics.port=7302 --rpc.addr=0.0.0.0 --rpc.port=8560"
    
    # Continuous monitoring loop
    local restart_count=0
    while true; do
        sleep 30
        
        for service in "${services[@]}"; do
            local pid_file="$DEPLOYMENT_DIR/${service}.pid"
            
            if [ -f "$pid_file" ]; then
                local pid=$(cat "$pid_file")
                
                if ! is_running "$pid"; then
                    log_message "${RED}⚠️  ${service} crashed (PID: $pid)${NC}"
                    ((restart_count++))
                    
                    local binary=$(echo "${services[$service]}" | awk '{print $1}')
                    local args=$(echo "${services[$service]}" | cut -d' ' -f2-)
                    restart_service "$service" "$binary" "$args"
                    
                    log_message "${YELLOW}Restart count: $restart_count${NC}"
                else
                    # Service is running, check logs for errors
                    local error_count=$(grep -c "ERROR\|CRIT" "$LOG_DIR/${service}.log" 2>/dev/null || echo 0)
                    if [ "$error_count" -gt 0 ]; then
                        log_message "${YELLOW}⚠️  ${service} has errors (Count: $error_count)${NC}"
                    fi
                fi
            else
                log_message "${RED}❌ PID file not found for ${service}${NC}"
                local binary=$(echo "${services[$service]}" | awk '{print $1}')
                local args=$(echo "${services[$service]}" | cut -d' ' -f2-)
                start_service "$service" "$binary" "$args"
            fi
        done
        
        # Print status summary every 5 minutes
        if [ $(($(date +%s) % 300)) -lt 30 ]; then
            log_message "${BLUE}=== Status Summary ===${NC}"
            for service in "${services[@]}"; do
                local pid_file="$DEPLOYMENT_DIR/${service}.pid"
                if [ -f "$pid_file" ]; then
                    local pid=$(cat "$pid_file")
                    if is_running "$pid"; then
                        log_message "${GREEN}✅ ${service} (PID: $pid) - Running${NC}"
                    else
                        log_message "${RED}❌ ${service} - Not Running${NC}"
                    fi
                fi
            done
        fi
    done
}

# Trap signals for graceful shutdown
trap_handler() {
    log_message "${YELLOW}Received shutdown signal...${NC}"
    log_message "Stopping all services..."
    
    for service in op-node op-batcher op-proposer; do
        local pid_file="$DEPLOYMENT_DIR/${service}.pid"
        if [ -f "$pid_file" ]; then
            local pid=$(cat "$pid_file")
            if is_running "$pid"; then
                log_message "Killing ${service} (PID: $pid)"
                kill "$pid" 2>/dev/null || true
            fi
            rm "$pid_file"
        fi
    done
    
    log_message "${GREEN}✅ All services stopped${NC}"
    log_message "Monitor exiting..."
    exit 0
}

# Set up signal handlers
trap trap_handler SIGINT SIGTERM

# Start monitoring
log_message "${GREEN}=== Celo Sepolia L3 Service Monitor ===${NC}"
log_message "Deployment directory: $DEPLOYMENT_DIR"
log_message "Log directory: $LOG_DIR"
log_message "Monitor log: $MONITOR_LOG"
log_message ""

monitor_services
