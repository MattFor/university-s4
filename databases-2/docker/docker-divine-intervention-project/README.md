# Projekt Docker: MySQL trigger + `audit_logs` → MongoDB sharding z 3 shardami

Ta wersja **nie korzysta z MySQL binlog**.

Działa to tak:

1. Formularz Flask zapisuje rejestrację do tabeli `registrations` w MySQL.
2. Trigger MySQL automatycznie dodaje wpis do tabeli `audit_logs`.
3. Osobny worker w Pythonie odczytuje jeszcze nieprzetworzone wpisy z `audit_logs`.
4. Worker zapisuje te wpisy do MongoDB przez `mongos`.
5. MongoDB rozdziela dane na shardach według `event_id`.

---

## Jak działa architektura

```text
Użytkownik
   ↓
Flask WWW
   ↓
MySQL: registrations
   ↓
Trigger MySQL
   ↓
MySQL: audit_logs
   ↓
Python logger
   ↓
mongos
   ↓
+---------+---------+---------+
| shard1  | shard2  | shard3  |
+---------+---------+---------+
```

---

## Kontenery w projekcie

* `mysql` – baza MySQL
* `web` – aplikacja Flask z formularzem
* `logger` – worker Python, który czyta `audit_logs`
* `cfg` – config server MongoDB
* `shard1` – pierwszy shard
* `shard2` – drugi shard
* `shard3` – trzeci shard
* `mongos` – router MongoDB
* `mongo-init` – kontener, który inicjalizuje replica sety i sharding

---

## Uruchomienie projektu

Najpierw wyłącz wszystko i usuń stare wolumeny:

```bash
docker compose down -v
```

Potem zbuduj i uruchom cały projekt:

```bash
docker compose up --build
```

Strona będzie dostępna tutaj:

```text
http://localhost:9001
```

Hasło do formularza:

```text
password1234
```

---

## Sprawdzenie MySQL

Wejdź do kontenera MySQL:

```bash
docker compose exec mysql mysql -uroot -proot
```

W środku sprawdź dane:

```sql
USE events;

SELECT * FROM events;
SELECT * FROM registrations;
SELECT * FROM audit_logs;
```

---

## Sprawdzenie MongoDB przez `mongos`

Wejdź do powłoki MongoDB:

```bash
docker compose exec mongos mongosh
```

W środku sprawdź kolekcję i shardowanie:

```javascript
use logs

db.audit_logs.find()
db.audit_logs.getShardDistribution()
sh.status()
```

---

## Klucz shardingu

Kolekcja `logs.audit_logs` jest shardowana po polu:

```javascript
{ event_id: 1 }
```

Podział danych wygląda tak:

* `event_id = 1` → `shard1`
* `event_id = 2` → `shard2`
* `event_id = 3` → `shard3`

Każdy shard jest osobnym replica setem z jednym węzłem, dzięki czemu cały projekt da się łatwo uruchomić na zwykłym komputerze.
