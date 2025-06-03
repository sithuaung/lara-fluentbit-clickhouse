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
{"date": 1746673481.0, "auditable_id": "b8d7fef6-e84a-458d-b582-d8c305ca1775", "auditable_type": "App\\Models\\LoadTestData", "url": "http://localhost:8010/create-record", "ip_address": "192.168.65.1", "service_name": "Service-A", "version": "1.0", "source": "Service-A", "new_values": {"status": "processing", "ip_address": "66.2.99.32", "mac_address": "74:59:7B:A8:55:4A", "metadata": "{\"tags\":[\"quia\",\"quam\",\"maiores\"],\"features\":[\"perferendis\",\"ea\",\"non\",\"qui\",\"facilis\"],\"specifications\":{\"color\":\"OldLace\",\"size\":\"L\",\"weight\":3.97}}", "rating": 1.8, "code": "MX6113DI", "year_created": "1982", "id": "b8d7fef6-e84a-458d-b582-d8c305ca1775", "name": "neque eum voluptatibus", "description": "Dolores fugiat sint accusantium. Impedit dolores voluptas sit qui eum placeat tempora quasi. Corporis voluptatem eligendi sed et sint. Culpa ipsa quam id velit.", "quantity": 470, "price": 30.8, "is_active": true, "purchase_date": "2024-10-16", "purchase_time": "20:26:23", "views_count": 4224, "email": "kassulke.chance@example.org"}, "occurred_at": "2025-05-08 03:04:41", "user_agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36", "old_values": [], "event": "created"}
```

### file log output
```
lara-app.test: [1746720806.000000000, {"log":"  2025-05-08 16:13:26 /favicon.ico ................................. ~ 0.02ms","container_id":"d1c597c54faaea105eb5baef21a702f2f4de246fbdeca715551c1913cceebc41","container_name":"/laravel-fluentbit-lara-app.test-1"}]
lara-app.test: [1746720806.000000000, {"message":"app.audit","context":{"old_values":[],"new_values":{"id":"caeff529-3f94-4d1b-a904-8de0812ac1ed","name":"sit animi praesentium","description":"Quod cupiditate dolorum quod. Atque et deserunt occaecati delectus rem accusantium.","quantity":531,"price":241.2,"is_active":true,"metadata":"{\"tags\":[\"quos\",\"doloribus\",\"deleniti\"],\"features\":[\"magnam\",\"omnis\",\"fugit\",\"nisi\",\"velit\"],\"specifications\":{\"color\":\"LightBlue\",\"size\":\"XL\",\"weight\":1.61}}","purchase_date":"2024-11-11","purchase_time":"20:24:01","status":"failed","user_id":null,"email":"ydoyle@example.com","ip_address":"71.161.228.120","mac_address":"66:48:E2:2D:C7:A5","views_count":4885,"rating":1.68,"code":"FK0011GP","year_created":"1970"},"event":"created","auditable_id":"caeff529-3f94-4d1b-a904-8de0812ac1ed","auditable_type":"App\\Models\\LoadTestData","user_id":null,"user_type":null,"tags":null,"ip_address":"192.168.65.1","user_agent":"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36","url":"http://localhost:8010/create-record","service_name":"Service-A","version":"1.0","source":"Service-A","occurred_at":"2025-05-08 16:13:26"},"level":200,"level_name":"INFO","channel":"local","datetime":"2025-05-08T16:13:26.519446+00:00","extra":{},"container_id":"d1c597c54faaea105eb5baef21a702f2f4de246fbdeca715551c1913cceebc41","container_name":"/laravel-fluentbit-lara-app.test-1"}]
lara-app.test: [1746720806.000000000, {"container_name":"/laravel-fluentbit-lara-app.test-1","log":"  2025-05-08 16:13:26 /create-record ............................... ~ 0.18ms","container_id":"d1c597c54faaea105eb5baef21a702f2f4de246fbdeca715551c1913cceebc41"}]
lara-app.test: [1746720806.000000000, {"log":"  2025-05-08 16:13:26 /favicon.ico ................................. ~ 0.05ms","container_id":"d1c597c54faaea105eb5baef21a702f2f4de246fbdeca715551c1913cceebc41","container_name":"/laravel-fluentbit-lara-app.test-1"}]
```

### Important TODO
[] User_id and user_type can't save into clickhouse yet
[] Check update event whether it's working or not
[] Check how to receive alert when not saving