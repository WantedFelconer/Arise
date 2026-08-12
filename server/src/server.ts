import http from 'http';
import {
  AIFactory,
  AIPlannerService,
  AuthService,
  BossEngine,
  Envelope,
  GateEngine,
  QuestService,
  XPEngine,
} from './index.ts';

const PORT = process.env.PORT || 3001;

const aiPlannerService = new AIPlannerService();

const server = http.createServer(async (req, res) => {
  const url = req.url || '/';
  const method = req.method || 'GET';

  // Set CORS headers
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PATCH, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Correlation-ID');

  if (method === 'OPTIONS') {
    res.writeHead(204);
    res.end();
    return;
  }

  // Parse JSON body helper
  let bodyData: any = {};
  if (method === 'POST' || method === 'PATCH') {
    const buffers: Uint8Array[] = [];
    for await (const chunk of req) {
      buffers.push(chunk);
    }
    const raw = Buffer.concat(buffers).toString('utf-8');
    if (raw) {
      try {
        bodyData = JSON.parse(raw);
      } catch (e) {}
    }
  }

  res.setHeader('Content-Type', 'application/json');

  if (url === '/' || url === '/health' || url === '/api/v1/health') {
    res.writeHead(200);
    res.end(JSON.stringify(Envelope.success({
      service: 'ARISE Life OS Backend Monolith API',
      version: 'v1.0.0',
      status: 'HEALTHY',
      endpoints: [
        'GET /health',
        'POST /api/v1/auth/login',
        'POST /api/v1/quests/parse-nl',
        'POST /api/v1/ai/plan',
        'POST /api/v1/ai/plan/:jobId/approve'
      ],
      timestamp: new Date().toISOString()
    })));
    return;
  }

  if (url === '/api/v1/auth/login' && method === 'POST') {
    const tokens = AuthService.generateTokens('hunter_1', bodyData.email || 'hunter@arise.sys', 'casual');
    res.writeHead(200);
    res.end(JSON.stringify(Envelope.success(tokens)));
    return;
  }

  if (url === '/api/v1/quests/parse-nl' && method === 'POST') {
    const aiProvider = AIFactory.getProvider();
    const draft = await aiProvider.parseNaturalLanguageQuest(bodyData.text || 'Study OS tomorrow 8pm for 2 hours');
    res.writeHead(200);
    res.end(JSON.stringify(Envelope.success(draft)));
    return;
  }

  if (url === '/api/v1/ai/plan' && method === 'POST') {
    const jobId = await aiPlannerService.createPlanJob('hunter_1', { userId: 'hunter_1', goal: bodyData.goal || 'Master Systems' });
    const draft = aiPlannerService.getPlanDraft(jobId, 'hunter_1');
    res.writeHead(202);
    res.end(JSON.stringify(Envelope.success({ jobId, draft })));
    return;
  }

  if (url.startsWith('/api/v1/ai/plan/') && url.endsWith('/approve') && method === 'POST') {
    const parts = url.split('/');
    const jobId = parts[parts.length - 2];
    const result = aiPlannerService.approveAndMaterializePlan(jobId, 'hunter_1');
    res.writeHead(200);
    res.end(JSON.stringify(Envelope.success(result)));
    return;
  }

  // Default fallback 404
  res.writeHead(404);
  res.end(JSON.stringify(Envelope.error(`Route ${method} ${url} not found`)));
});

server.listen(PORT, () => {
  console.log(`[ARISE Standalone Backend Server] Listening on http://localhost:${PORT}`);
});
