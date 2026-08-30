# Zadanie 5 — MongoDB sharding dla logów z MySQL

To jest gotowy wariant rozwiązania zadania 5 w oparciu o zadanie 4.

## Co zawiera projekt
- **MySQL** z tabelą `registrations`
- **trigger MySQL**, który po `INSERT` zapisuje wpis do `audit_logs`
- **serwis WWW** z prostym formularzem rejestracji
- **serwis ETL w Pythonie**, który czyta `audit_logs` i zapisuje logi do MongoDB
- **MongoDB sharded cluster** z:
  - `configsvr`
  - `mongos`
  - 3 shardami po 1 węźle każdy

## Założenie shardingu
Logi trafiają do kolekcji `logsdb.audit_logs` i są shardowane po polu:

`event_id`

Zgodnie z treścią zadania:
- są 3 wydarzenia,
- są 3 shardy,
- każdy zakres `event_id` jest przypisany do innego shardu.

## Start
1. Zbuduj i uruchom kontenery:
```bash
docker compose up -d --build
```

2. Zainicjalizuj MongoDB sharding:
```bash
bash scripts/setup-mongo.sh
```

3. Otwórz aplikację:
```bash
http://localhost:8080
```

## Dane logów
Po wysłaniu formularza:
1. wpis trafia do tabeli `registrations`,
2. trigger zapisuje rekord do `audit_logs`,
3. serwis ETL czyta `audit_logs`,
4. zapisuje dokument do MongoDB przez `mongos`,
5. oznacza log jako przetworzony.

## Sprawdzenie działania
W MongoDB:
```bash
docker compose exec -T mongos mongosh --eval 'db.getSiblingDB("logsdb").audit_logs.getShardDistribution()'
```

W MySQL:
```bash
docker compose exec -T mysql mysql -uapp -papp -e "USE eventsdb; SELECT * FROM registrations; SELECT * FROM audit_logs;"
```
