# 🔍 Continuous Service Monitor - Complete Guide

## Overview

The `monitor-services.sh` script is a **never-ending monitoring solution** that continuously watches your L3 services and automatically restarts them if they crash.

**Unlike** `start-services-direct.sh` which starts services and exits, the monitor script **runs indefinitely** and keeps your services alive.

---

## 🚀 Quick Start

### Start the Monitor

```bash
bash /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/monitor-services.sh
```

That's it! The monitor will:
- ✅ Start all three services (op-node, op-batcher, op-proposer)
- ✅ Keep running indefinitely
- ✅ Check every 30 seconds if services are still running
- ✅ Auto-restart any crashed service
- ✅ Log all events with timestamps
- ✅ Print status summary every 5 minutes

### Stop the Monitor

Press `Ctrl+C` in the terminal where the monitor is running, or:

```bash
pkill -f "monitor-services.sh"
```

---

## 📊 Features

### Continuous Monitoring
- **Check Interval**: 30 seconds
- **Auto-Restart**: Yes (on crash)
- **Logging**: Full event logging with timestamps
- **Status Reports**: Every 5 minutes

### Service Management
- Automatically starts all services on launch
- Detects crashed processes by PID
- Restarts crashed services immediately
- Tracks restart count
- Monitors error logs

### Logging
- **Monitor Log**: `/l2-deployment/logs/monitor.log`
- **Service Logs**: `/l2-deployment/logs/{service}.log`
- **Timestamps**: All events timestamped
- **Error Tracking**: Counts errors in service logs

### Graceful Shutdown
- Handles `Ctrl+C` gracefully
- Stops all services cleanly
- Removes PID files
- Logs shutdown event

---

## 📝 Log Output Example

```
[2025-10-30 21:02:15] === Starting Service Monitor ===
[2025-10-30 21:02:15] Monitoring interval: 30 seconds
[2025-10-30 21:02:15] Services: op-node, op-batcher, op-proposer
[2025-10-30 21:02:15] Starting op-node...
[2025-10-30 21:02:15] ✅ op-node started (PID: 12345)
[2025-10-30 21:02:18] Starting op-batcher...
[2025-10-30 21:02:18] ✅ op-batcher started (PID: 12346)
[2025-10-30 21:02:21] Starting op-proposer...
[2025-10-30 21:02:21] ✅ op-proposer started (PID: 12347)
[2025-10-30 21:07:15] === Status Summary ===
[2025-10-30 21:07:15] ✅ op-node (PID: 12345) - Running
[2025-10-30 21:07:15] ✅ op-batcher (PID: 12346) - Running
[2025-10-30 21:07:15] ✅ op-proposer (PID: 12347) - Running
```

---

## 🔄 Restart Behavior

### Automatic Restart Scenarios

1. **Process Crashes**: If a service crashes, monitor detects it and restarts
2. **Restart Count**: Tracks how many times each service has been restarted
3. **Logging**: Each restart is logged with timestamp and PID

### Example Restart Log

```
[2025-10-30 21:15:30] ⚠️  op-node crashed (PID: 12345)
[2025-10-30 21:15:30] Starting op-node...
[2025-10-30 21:15:30] ✅ op-node started (PID: 12356)
[2025-10-30 21:15:30] Restart count: 1
```

---

## 📋 Monitor Commands

### View Monitor Log
```bash
tail -f /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/logs/monitor.log
```

### View All Logs
```bash
tail -f /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/logs/*.log
```

### Check Running Processes
```bash
ps aux | grep -E "op-node|op-batcher|op-proposer|monitor" | grep -v grep
```

### Get Monitor PID
```bash
pgrep -f "monitor-services.sh"
```

### Kill Monitor Gracefully
```bash
kill $(pgrep -f "monitor-services.sh")
```

---

## 🔧 Configuration

### Monitoring Interval
Currently set to **30 seconds**. To change, edit the script:

```bash
sleep 30  # Change this value (in seconds)
```

### Status Report Interval
Currently set to **5 minutes** (300 seconds). To change:

```bash
if [ $(($(date +%s) % 300)) -lt 30 ]; then
```

Change `300` to desired seconds.

### Service Arguments
Edit the `services` array in the script to modify service startup arguments:

```bash
services[op-node]="$OPTIMISM_DIR/op-node/bin/op-node --l1=... --l2=..."
```

---

## 🚨 Error Detection

### Monitor Detects

- ✅ Process crashes (PID no longer exists)
- ✅ Missing PID files
- ✅ Errors in service logs (ERROR, CRIT keywords)
- ✅ Service not responding

### Monitor Actions

- 🔄 Restarts crashed services
- 📝 Logs all events
- 📊 Tracks restart count
- ⚠️ Reports errors in logs

---

## 📊 Comparison: Start Scripts

| Feature | start-services.sh | start-services-direct.sh | monitor-services.sh |
|---------|-------------------|--------------------------|---------------------|
| Starts services | ✅ | ✅ | ✅ |
| Runs indefinitely | ❌ | ❌ | ✅ |
| Auto-restart on crash | ❌ | ❌ | ✅ |
| Continuous monitoring | ❌ | ❌ | ✅ |
| Logging | ✅ | ✅ | ✅ |
| Error detection | ❌ | ❌ | ✅ |
| Status reports | ❌ | ❌ | ✅ |
| Graceful shutdown | ✅ | ✅ | ✅ |

---

## 🎯 Recommended Usage

### Development
```bash
# Start monitor in a dedicated terminal
bash /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/monitor-services.sh

# In another terminal, work on your application
# Monitor will keep services alive in background
```

### Production
```bash
# Run monitor in a tmux/screen session
tmux new-session -d -s l3-monitor \
  'bash /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/monitor-services.sh'

# Or with nohup
nohup bash /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/monitor-services.sh \
  > /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/logs/monitor-main.log 2>&1 &
```

### Systemd Service (Advanced)
```bash
# Create systemd service file
sudo tee /etc/systemd/system/celo-l3-monitor.service << 'EOF'
[Unit]
Description=Celo L3 Service Monitor
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=/Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment
ExecStart=/bin/bash /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/monitor-services.sh
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Enable and start
sudo systemctl enable celo-l3-monitor
sudo systemctl start celo-l3-monitor

# Check status
sudo systemctl status celo-l3-monitor

# View logs
sudo journalctl -u celo-l3-monitor -f
```

---

## 🔍 Troubleshooting

### Monitor Not Starting
```bash
# Check if script is executable
ls -l /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/monitor-services.sh

# Make executable if needed
chmod +x /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/monitor-services.sh

# Check for syntax errors
bash -n /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/monitor-services.sh
```

### Services Not Starting
```bash
# Check if binaries exist
ls -lh /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/optimism/optimism/op-{node,batcher,proposer}/bin/*

# Check logs for errors
tail -50 /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/logs/op-node.log
```

### Monitor Consuming Too Much CPU
- Increase monitoring interval (change `sleep 30` to `sleep 60`)
- Reduce log checking frequency
- Check for infinite loops in service logs

### Services Keep Restarting
```bash
# Check service logs for errors
tail -100 /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/logs/op-node.log

# Check monitor log
tail -100 /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/logs/monitor.log

# Look for specific error patterns
grep -i "error\|crit\|fail" /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/logs/*.log
```

---

## 📞 Support

### View Logs
```bash
# Monitor log
tail -f /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/logs/monitor.log

# Service logs
tail -f /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/logs/op-*.log
```

### Check Status
```bash
ps aux | grep -E "op-node|op-batcher|op-proposer" | grep -v grep
```

### Emergency Stop
```bash
pkill -9 -f "op-node"
pkill -9 -f "op-batcher"
pkill -9 -f "op-proposer"
pkill -9 -f "monitor-services.sh"
```

---

## ✅ Summary

**The monitor-services.sh script provides:**
- ✅ Never-ending service monitoring
- ✅ Automatic crash recovery
- ✅ Comprehensive logging
- ✅ Status reporting
- ✅ Production-ready reliability

**Start it with:**
```bash
bash /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/monitor-services.sh
```

**Stop it with:**
```bash
Ctrl+C  # or pkill -f "monitor-services.sh"
```

---

**Status**: Ready for Production 🚀
