import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '30s', target: 100 },
    { duration: '1m', target: 1000 },
    { duration: '2m', target: 1000 },
    { duration: '30s', target: 0 },
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'],
    http_req_failed: ['rate<0.01'],
  },
};

const BASE_URL = 'https://d2af17brxmy0bu.cloudfront.net';
export default function () {
  // GET the task list
  const listRes = http.get(`${BASE_URL}/api/tasks`);
  check(listRes, { 'GET tasks status is 200': (r) => r.status === 200 });
  if (listRes.status !== 200) {
    console.log(`VU #${__VU} iter #${__ITER} GET failed: status=${listRes.status}`);
  }

  sleep(1);

  // POST a new task
  const payload = JSON.stringify({
    title: `Load test task ${__VU}-${__ITER}`,
    description: 'created during load test',
    status: 'pending',
  });
  const params = { headers: { 'Content-Type': 'application/json' } };
  const postRes = http.post(`${BASE_URL}/api/tasks`, payload, params);
  check(postRes, { 'POST task status is 201 or 200': (r) => r.status === 201 || r.status === 200 });
  if (postRes.status >= 400) {
    console.log(`VU #${__VU} iter #${__ITER} POST failed: status=${postRes.status} body=${postRes.body}`);
  }

  sleep(1);
}
