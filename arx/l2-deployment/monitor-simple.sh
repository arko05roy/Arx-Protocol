#!/bin/bash

# Celo Sepolia L3 - Simple Continuous Service Monitor
# Simplified version compatible with all shells

DEPLOYMENT_DIR="/Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment"
OPTIMISM_DIR="/Users/arkoroy/Desktop/arx/Arx-Protocol/arx/optimism/optimism"
LOG_DIR="$DEPLOYMENT_DIR/logs"
MONITOR_LOG="$LOG_DIR/monitor.log"

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
    
    log_message "Starting ${service}..."
    
    if [ ! -f "$binary" ]; then
        log_message "ERROR: Binary not found: $binary"
        return 1
    fi
    
    # Start service
    nohup $binary $args > "$LOG_DIR/${service}.log" 2>&1 &
    local pid=$!
    
    echo "$pid" > "$pid_file"
    log_message "✅ ${service} started (PID: $pid)"
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
            log_message "Killing ${service} (PID: $old_pid)"
            kill "$old_pid" 2>/dev/null || true
            sleep 2
        fi
    fi
    
    start_service "$service" "$binary" "$args"
}

# Trap signals for graceful shutdown
trap_handler() {
    log_message "Received shutdown signal..."
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
    
    log_message "✅ All services stopped"
    log_message "Monitor exiting..."
    exit 0
}

# Set up signal handlers
trap trap_handler SIGINT SIGTERM

# Start monitoring
log_message "=== Celo Sepolia L3 Service Monitor ==="
log_message "Deployment directory: $DEPLOYMENT_DIR"
log_message "Log directory: $LOG_DIR"
log_message "Monitor log: $MONITOR_LOG"
log_message ""
log_message "=== Starting Service Monitor ==="
log_message "Monitoring interval: 30 seconds"
log_message "Services: op-node, op-batcher, op-proposer"

# Initial startup
start_service "op-node" "$OPTIMISM_DIR/op-node/bin/op-node" "--l1=https://rpc.ankr.com/celo_sepolia --l2=http://localhost:8551 --l2.jwt-secret=$DEPLOYMENT_DIR/jwt-secret.txt --rollup.config=$DEPLOYMENT_DIR/rollup.json --rpc.addr=0.0.0.0 --rpc.port=9545 --metrics.enabled --metrics.addr=0.0.0.0 --metrics.port=7300 --p2p.disable --l1.trustrpc --l1.http-poll-interval=100ms"
sleep 5

start_service "op-batcher" "$OPTIMISM_DIR/op-batcher/bin/op-batcher" "--l1-eth-rpc=https://rpc.ankr.com/celo_sepolia --l2-eth-rpc=http://localhost:8545 --private-key=f2d83d4bb547d821db1e33c6a488a9350d263dee584acadbd6603f862931349c --metrics.enabled --metrics.addr=0.0.0.0 --metrics.port=7301"
sleep 3

start_service "op-proposer" "$OPTIMISM_DIR/op-proposer/bin/op-proposer" "--l1-eth-rpc=https://rpc.ankr.com/celo_sepolia --l2-eth-rpc=http://localhost:8545 --private-key=9ebad8e26c7d816238400f806f0c81b25ce6f8e937c3386efc5223c5bad12a02 --l2-output-oracle-address=0x6C5Fd71d75Fa4b6054E0b9b5cC154AEBb18930c1 --metrics.enabled --metrics.addr=0.0.0.0 --metrics.port=7302 --rpc.addr=0.0.0.0 --rpc.port=8560"

log_message ""
log_message "=== All services started ==="
log_message "Press Ctrl+C to stop"

# Continuous monitoring loop
restart_count=0
status_counter=0

while true; do
    sleep 30
    status_counter=$((status_counter + 1))
    
    # Check op-node
    op_node_pid_file="$DEPLOYMENT_DIR/op-node.pid"
    if [ -f "$op_node_pid_file" ]; then
        op_node_pid=$(cat "$op_node_pid_file")
        if ! is_running "$op_node_pid"; then
            log_message "WARNING: op-node crashed (PID: $op_node_pid)"
            restart_count=$((restart_count + 1))
            restart_service "op-node" "$OPTIMISM_DIR/op-node/bin/op-node" "--l1=https://rpc.ankr.com/celo_sepolia --l2=http://localhost:8551 --l2.jwt-secret=$DEPLOYMENT_DIR/jwt-secret.txt --rollup.config=$DEPLOYMENT_DIR/rollup.json --rpc.addr=0.0.0.0 --rpc.port=9545 --metrics.enabled --metrics.addr=0.0.0.0 --metrics.port=7300 --p2p.disable"
            log_message "Restart count: $restart_count"
        fi
    fi
    
    # Check op-batcher
    op_batcher_pid_file="$DEPLOYMENT_DIR/op-batcher.pid"
    if [ -f "$op_batcher_pid_file" ]; then
        op_batcher_pid=$(cat "$op_batcher_pid_file")
        if ! is_running "$op_batcher_pid"; then
            log_message "WARNING: op-batcher crashed (PID: $op_batcher_pid)"
            restart_count=$((restart_count + 1))
            restart_service "op-batcher" "$OPTIMISM_DIR/op-batcher/bin/op-batcher" "--l1-eth-rpc=https://rpc.ankr.com/celo_sepolia --l2-eth-rpc=http://localhost:8545 --private-key=f2d83d4bb547d821db1e33c6a488a9350d263dee584acadbd6603f862931349c --metrics.enabled --metrics.addr=0.0.0.0 --metrics.port=7301"
            log_message "Restart count: $restart_count"
        fi
    fi
    
    # Check op-proposer
    op_proposer_pid_file="$DEPLOYMENT_DIR/op-proposer.pid"
    if [ -f "$op_proposer_pid_file" ]; then
        op_proposer_pid=$(cat "$op_proposer_pid_file")
        if ! is_running "$op_proposer_pid"; then
            log_message "WARNING: op-proposer crashed (PID: $op_proposer_pid)"
            restart_count=$((restart_count + 1))
            restart_service "op-proposer" "$OPTIMISM_DIR/op-proposer/bin/op-proposer" "--l1-eth-rpc=https://rpc.ankr.com/celo_sepolia --l2-eth-rpc=http://localhost:8545 --private-key=9ebad8e26c7d816238400f806f0c81b25ce6f8e937c3386efc5223c5bad12a02 --l2-output-oracle-address=0x6C5Fd71d75Fa4b6054E0b9b5cC154AEBb18930c1 --metrics.enabled --metrics.addr=0.0.0.0 --metrics.port=7302 --rpc.addr=0.0.0.0 --rpc.port=8560"
            log_message "Restart count: $restart_count"
        fi
    fi
    
    # Print status summary every 5 minutes (10 iterations of 30 seconds)
    if [ $status_counter -ge 10 ]; then
        log_message "=== Status Summary ==="
        
        if [ -f "$op_node_pid_file" ]; then
            op_node_pid=$(cat "$op_node_pid_file")
            if is_running "$op_node_pid"; then
                log_message "✅ op-node (PID: $op_node_pid) - Running"
            else
                log_message "❌ op-node - Not Running"
            fi
        fi
        
        if [ -f "$op_batcher_pid_file" ]; then
            op_batcher_pid=$(cat "$op_batcher_pid_file")
            if is_running "$op_batcher_pid"; then
                log_message "✅ op-batcher (PID: $op_batcher_pid) - Running"
            else
                log_message "❌ op-batcher - Not Running"
            fi
        fi
        
        if [ -f "$op_proposer_pid_file" ]; then
            op_proposer_pid=$(cat "$op_proposer_pid_file")
            if is_running "$op_proposer_pid"; then
                log_message "✅ op-proposer (PID: $op_proposer_pid) - Running"
            else
                log_message "❌ op-proposer - Not Running"
            fi
        fi
        
        status_counter=0
    fi
done
