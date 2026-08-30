# Projekt — Replikacja MongoDB + System rejestracji wydarzeń

## Opis
Projekt przedstawia:
- działanie replikacji MongoDB,
- aplikację WWW do zapisów na wydarzenia,
- MySQL jako główną bazę danych,
- MongoDB jako bazę logów,
- Pythonowy serwis synchronizujący logi z MySQL do MongoDB.

## Kontenery
1. mysql-db — baza MySQL
2. web-app — Flask WWW
3. mongo1 — MongoDB PRIMARY
4. mongo2 — MongoDB SECONDARY
5. mongo3 — MongoDB SECONDARY
6. log-service — serwis Python kopiujący logi

## Uruchomienie
```bash
docker compose up --build
```

## Inicjalizacja replica set MongoDB
Po uruchomieniu:

```bash
docker exec -it mongo1 mongosh
```

Następnie:

```javascript
rs.initiate({
  _id: "rs0",
  members: [
    { _id: 0, host: "mongo1:27017" },
    { _id: 1, host: "mongo2:27017" },
    { _id: 2, host: "mongo3:27017" }
  ]
})
```

Sprawdzenie statusu:
```javascript
rs.status()
```

## Formularz WWW
http://localhost:5000

Hasło:
```text
tajnehaslo
```

## Replikacja MongoDB
- mongo1 = PRIMARY
- mongo2 i mongo3 = SECONDARY
- dane zapisane w PRIMARY są automatycznie kopiowane na SECONDARY
- w przypadku awarii PRIMARY następuje wybór nowego PRIMARY

## Mechanizm logów
Trigger MySQL zapisuje każdą rejestrację do tabeli audit_logs.

Pythonowy serwis:
- pobiera logi z MySQL,
- zapisuje je do MongoDB,
- oznacza log jako przetworzony.
