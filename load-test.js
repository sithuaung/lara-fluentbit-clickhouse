import http from 'k6/http';
import { sleep } from 'k6';

export const options = {
  stages: [
    { duration: '30s', target: 20 }, // Ramp up to 20 users
    { duration: '1m', target: 20 },  // Stay at 20 users
    { duration: '30s', target: 0 },  // Ramp down to 0 users
  ],
};

export default function () {
  // Test your endpoints
  http.get('http://localhost:8000/write-log');
  sleep(1);
  
  // POST request example
//   const payload = JSON.stringify({
//     key: 'value'
//   });
  
//   http.post('http://localhost:8000/api/another-endpoint', payload, {
//     headers: { 'Content-Type': 'application/json' },
//   });
  
//   sleep(2);
}