import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  vus: 100, // 100 concurrent virtual users
  duration: '5m', // Run for 5 minutes
};

export default function () {
  const payload = JSON.stringify({
    context_id: "9e9fe821-407b-426f-9572-32c55595f856",
    status_id: "9e9fe821-4c42-4787-9a65-895672884ac8",
    country_code: "SG",
    inventory_id: "123e4567-e89b-12d3-a456-426614174000",
    additional_data: {
      make: "Honda",
      name: "APPLE AUTO AUCTION Test Trigger"
    }
  });

  const params = {
    headers: {
      'Content-Type': 'application/json',
    },
  };

  const response = http.post(
    'https://ticket-api-v2.stg.getcars.dev/api/v1/tickets',
    payload,
    params
  );

  check(response, {
    'is status 200': (r) => r.status === 200,
    'transaction time < 200ms': (r) => r.timings.duration < 200,
  });

  sleep(1); // Add a 1 second sleep between iterations
} 