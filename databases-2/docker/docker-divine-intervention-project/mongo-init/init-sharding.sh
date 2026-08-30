#!/bin/bash
set -e

log() {
  echo "[INFO] $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

warn() {
  echo "[WARN] $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

step() {
  echo
  echo "=================================================="
  echo "[STEP] $(date '+%Y-%m-%d %H:%M:%S') - $1"
  echo "=================================================="
}

run_mongosh() {
  local host="$1"
  local script="$2"

  log "Connecting to $host"
  mongosh --host "$host" --quiet --eval "$script"
  log "Finished on $host"
}

set -e

step "Waiting for MongoDB processes to start"
log "Sleeping for 12 seconds before initialization"
sleep 12

step "Initializing config server replica set"
run_mongosh "cfg:27017" '
try {
  rs.initiate({
    _id: "cfgRS",
    configsvr: true,
    members: [{ _id: 0, host: "cfg:27017" }]
  })
  print("[OK] Config server replica set initiated")
} catch(e) {
  print("[ERROR] " + e)
}
'

step "Initializing shard1 replica set"
run_mongosh "shard1:27017" '
try {
  rs.initiate({
    _id: "shard1RS",
    members: [{ _id: 0, host: "shard1:27017" }]
  })
  print("[OK] Shard1 replica set initiated")
} catch(e) {
  print("[ERROR] " + e)
}
'

step "Initializing shard2 replica set"
run_mongosh "shard2:27017" '
try {
  rs.initiate({
    _id: "shard2RS",
    members: [{ _id: 0, host: "shard2:27017" }]
  })
  print("[OK] Shard2 replica set initiated")
} catch(e) {
  print("[ERROR] " + e)
}
'

step "Initializing shard3 replica set"
run_mongosh "shard3:27017" '
try {
  rs.initiate({
    _id: "shard3RS",
    members: [{ _id: 0, host: "shard3:27017" }]
  })
  print("[OK] Shard3 replica set initiated")
} catch(e) {
  print("[ERROR] " + e)
}
'

step "Waiting for PRIMARY election"
log "Sleeping for 20 seconds to allow replica sets to elect PRIMARY nodes"
sleep 20

step "Configuring sharding"
run_mongosh "mongos:27017" '
function safe(label, fn) {
  try {
    print("[OK] " + label)
    printjson(fn())
  } catch(e) {
    print("[ERROR] " + label + ": " + e)
  }
}

print("[INFO] Starting shard configuration")

safe("Adding shard1", () => sh.addShard("shard1RS/shard1:27017"))
safe("Adding shard2", () => sh.addShard("shard2RS/shard2:27017"))
safe("Adding shard3", () => sh.addShard("shard3RS/shard3:27017"))

safe("Enabling sharding for database logs", () => sh.enableSharding("logs"))

db = db.getSiblingDB("logs")
print("[INFO] Using database: " + db.getName())

safe("Creating index on audit_logs.event_id", () => db.audit_logs.createIndex({ event_id: 1 }))
safe("Sharding logs.audit_logs by event_id", () => sh.shardCollection("logs.audit_logs", { event_id: 1 }))

safe("Assigning shard1 to zone event1", () => sh.addShardToZone("shard1RS", "event1"))
safe("Assigning shard2 to zone event2", () => sh.addShardToZone("shard2RS", "event2"))
safe("Assigning shard3 to zone event3", () => sh.addShardToZone("shard3RS", "event3"))

safe("Updating zone range for shard1", () => sh.updateZoneKeyRange(
  "logs.audit_logs",
  { event_id: MinKey },
  { event_id: 4 },
  "event1"
))

safe("Updating zone range for shard2", () => sh.updateZoneKeyRange(
  "logs.audit_logs",
  { event_id: 4 },
  { event_id: 8 },
  "event2"
))

safe("Updating zone range for shard3", () => sh.updateZoneKeyRange(
  "logs.audit_logs",
  { event_id: 8 },
  { event_id: MaxKey },
  "event3"
))

print("[INFO] Current sharding status:")
sh.status()

print("[INFO] Sharding configuration completed")
'

step "Sharding completed"
log "All MongoDB sharding steps finished successfully"
