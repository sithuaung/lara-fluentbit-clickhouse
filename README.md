### install k6
```
brew install k6
```
### Run load test
```
k6 run load-test.js
```


### Test save to clickhouse
```
INSERT INTO cmp_logs.audits FORMAT JSONEachRow
{"date": 1746673481.0, "auditable_id": "b8d7fef6-e84a-458d-b582-d8c305ca1775", "auditable_type": "App\\Models\\LoadTestData", "url": "http://localhost:8010/create-record", "ip_address": "192.168.65.1", "service_name": "Service-A", "version": "1.0", "source": "Service-A", "new_values": {"status": "processing", "ip_address": "66.2.99.32", "mac_address": "74:59:7B:A8:55:4A", "metadata": "{\"tags\":[\"quia\",\"quam\",\"maiores\"],\"features\":[\"perferendis\",\"ea\",\"non\",\"qui\",\"facilis\"],\"specifications\":{\"color\":\"OldLace\",\"size\":\"L\",\"weight\":3.97}}", "rating": 1.8, "code": "MX6113DI", "year_created": "1982", "id": "b8d7fef6-e84a-458d-b582-d8c305ca1775", "name": "neque eum voluptatibus", "description": "Dolores fugiat sint accusantium. Impedit dolores voluptas sit qui eum placeat tempora quasi. Corporis voluptatem eligendi sed et sint. Culpa ipsa quam id velit.", "quantity": 470, "price": 30.8, "is_active": true, "purchase_date": "2024-10-16", "purchase_time": "20:26:23", "views_count": 4224, "email": "kassulke.chance@example.org"}, "event_time": "2025-05-08 03:04:41", "user_agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36", "old_values": [], "event": "created"}
```