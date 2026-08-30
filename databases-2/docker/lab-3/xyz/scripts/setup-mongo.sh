#!/usr/bin/env bash
set -euo pipefail

wait_for_ping () {
  local service="$1"
  local port="$2"
  until docker compose exec -T "$service" mongosh --port "$port" --quiet --eval 'db.adminCommand({ ping: 1 }).ok' | grep -q 1; do
    sleep 2
  done
}

echo "Start MySQL, web i shardów Mongo..."
docker compose up -d mysql web configsvr shard1 shard2 shard3

echo "Czekam na configsvr i shardy..."
wait_for_ping configsvr 27019
wait_for_ping shard1 27018
wait_for_ping shard2 27018
wait_for_ping shard3 27018

echo "Inicjalizacja config server..."
docker compose exec -T configsvr mongosh --port 27019 --eval '
rs.initiate({
  _id: "cfgRS",
  configsvr: true,
  members: [{ _id: 0, host: "configsvr:27019" }]
})
'

echo "Inicjalizacja shard1..."
docker compose exec -T shard1 mongosh --port 27018 --eval '
rs.initiate({
  _id: "shard1RS",
  members: [{ _id: 0, host: "shard1:27018" }]
})
'

echo "Inicjalizacja shard2..."
docker compose exec -T shard2 mongosh --port 27018 --eval '
rs.initiate({
  _id: "shard2RS",
  members: [{ _id: 0, host: "shard2:27018" }]
})
'

echo "Inicjalizacja shard3..."
docker compose exec -T shard3 mongosh --port 27018 --eval '
rs.initiate({
  _id: "shard3RS",
  members: [{ _id: 0, host: "shard3:27018" }]
})
'

echo "Start mongos..."
docker compose up -d mongos

echo "Czekam na mongos..."
until docker compose exec -T mongos mongosh --port 27017 --quiet --eval 'db.adminCommand({ ping: 1 }).ok' | grep -q 1; do
  sleep 2
done

echo "Dodawanie shardów i włączenie shardingu..."
docker compose exec -T mongos mongosh --port 27017 --eval '
sh.addShard("shard1RS/shard1:27018");
sh.addShard("shard2RS/shard2:27018");
sh.addShard("shard3RS/shard3:27018");

sh.enableSharding("logsdb");
db = db.getSiblingDB("logsdb");
db.audit_logs.createIndex({ event_id: 1 });
sh.shardCollection("logsdb.audit_logs", { event_id: 1 });

sh.addShardToZone("shard1RS", "event1");
sh.addShardToZone("shard2RS", "event2");
sh.addShardToZone("shard3RS", "event3");

sh.updateZoneKeyRange("logsdb.audit_logs", { event_id: 1 }, { event_id: 2 }, "event1");
sh.updateZoneKeyRange("logsdb.audit_logs", { event_id: 2 }, { event_id: 3 }, "event2");
sh.updateZoneKeyRange("logsdb.audit_logs", { event_id: 3 }, { event_id: MaxKey }, "event3");

sh.status();
'

echo "Start ETL..."
docker compose up -d etl

echo "Gotowe."
