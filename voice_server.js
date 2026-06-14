const http = require('http');

const PORT = Number(process.env.HR_VOICE_PORT || 15888);
const CODEX_BASE_URL = process.env.CODEX_MODEL_BASE_URL || 'http://127.0.0.1:15721/v1';
const CODEX_MODEL = process.env.CODEX_MODEL || 'ark-code-latest';
const REQUEST_TIMEOUT_MS = Number(process.env.HR_VOICE_TIMEOUT_MS || 45000);

function sendJson(res, status, payload) {
  const body = JSON.stringify(payload);
  res.writeHead(status, {
    'Content-Type': 'application/json; charset=utf-8',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET,POST,OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
    'Cache-Control': 'no-store'
  });
  res.end(body);
}

function readBody(req) {
  return new Promise((resolve, reject) => {
    let raw = '';
    req.setEncoding('utf8');
    req.on('data', chunk => {
      raw += chunk;
      if (raw.length > 12000) {
        reject(new Error('request too large'));
        req.destroy();
      }
    });
    req.on('end', () => resolve(raw));
    req.on('error', reject);
  });
}

function parseQuestion(req, raw, url) {
  if (req.method === 'GET') return url.searchParams.get('q') || '';
  const type = req.headers['content-type'] || '';
  if (type.includes('application/json')) {
    const parsed = raw ? JSON.parse(raw) : {};
    return parsed.q || parsed.question || '';
  }
  const form = new URLSearchParams(raw);
  return form.get('q') || '';
}

function extractResponseText(data) {
  if (typeof data.output_text === 'string' && data.output_text.trim()) return data.output_text.trim();
  if (Array.isArray(data.output)) {
    const parts = [];
    for (const item of data.output) {
      if (Array.isArray(item.content)) {
        for (const content of item.content) {
          if (typeof content.text === 'string') parts.push(content.text);
        }
      }
    }
    const text = parts.join('\n').trim();
    if (text) return text;
  }
  return '';
}

async function askCodex(question) {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), REQUEST_TIMEOUT_MS);
  try {
    const payload = {
      model: CODEX_MODEL,
      input: [
        {
          role: 'system',
          content: 'You are a local voice assistant connected to the user through speech. Answer in concise Simplified Chinese. Keep replies short, normally within 80 Chinese characters. Be direct and useful. Do not read error messages aloud.'
        },
        {
          role: 'user',
          content: question
        }
      ]
    };

    const response = await fetch(`${CODEX_BASE_URL}/responses`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer PROXY_MANAGED'
      },
      body: JSON.stringify(payload),
      signal: controller.signal
    });
    const raw = await response.text();
    let data;
    try {
      data = raw ? JSON.parse(raw) : {};
    } catch (err) {
      throw new Error(`Codex model returned invalid JSON: ${raw.slice(0, 300)}`);
    }
    if (!response.ok) {
      throw new Error(data.error?.message || data.error || `Codex model HTTP ${response.status}`);
    }
    let answer = extractResponseText(data);
    if (!answer) throw new Error('Codex model returned no text');
    if (answer.length > 220) answer = `${answer.slice(0, 220)}...`;
    return answer;
  } finally {
    clearTimeout(timer);
  }
}

const server = http.createServer(async (req, res) => {
  const url = new URL(req.url, `http://${req.headers.host || '127.0.0.1'}`);
  if (req.method === 'OPTIONS') return sendJson(res, 200, { ok: true });
  if (url.pathname === '/health') {
    return sendJson(res, 200, { ok: true, service: 'hr-voice-codex', port: PORT, model: CODEX_MODEL });
  }
  if (url.pathname !== '/ask') return sendJson(res, 404, { ok: false, error: 'not found' });

  try {
    const started = Date.now();
    const raw = await readBody(req);
    let question = parseQuestion(req, raw, url).trim();
    if (!question) return sendJson(res, 400, { ok: false, error: 'empty question' });
    if (question.length > 4000) question = question.slice(0, 4000);
    const answer = await askCodex(question);
    sendJson(res, 200, { ok: true, answer, elapsed_ms: Date.now() - started });
  } catch (err) {
    sendJson(res, 500, { ok: false, error: err.message || 'voice server error' });
  }
});

server.listen(PORT, '127.0.0.1', () => {
  console.log(`HR voice Codex server listening on http://127.0.0.1:${PORT}`);
});
