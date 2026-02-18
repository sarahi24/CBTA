const API_BASE = `${(import.meta.env.PUBLIC_API_BASE_URL ?? (() => { throw new Error('Falta PUBLIC_API_BASE_URL'); })()).replace(/\/$/, '')}/v1`;

export const prerender = false;

function parseRetryAfterMs(retryAfterHeader) {
  const parsed = Number(retryAfterHeader);
  if (Number.isFinite(parsed) && parsed > 0) {
    return Math.max(1000, parsed * 1000);
  }
  return 2000;
}

function wait(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function toJsonResponse(payload, status = 200) {
  return new Response(JSON.stringify(payload), {
    status,
    headers: {
      'Content-Type': 'application/json',
      'Cache-Control': 'no-store'
    }
  });
}

export async function POST({ request }) {
  const auth = request.headers.get('authorization') || '';
  if (!auth) {
    return toJsonResponse({ success: false, message: 'Unauthenticated', errors: {} }, 401);
  }

  const requestBody = await request.json().catch(() => ({}));
  const portalRoleRaw = String(requestBody?.portalRole || '').toLowerCase().trim();
  const portalRole = portalRoleRaw || 'student';

  const attempts = portalRole === 'applicant'
    ? [
        { role: 'student', permission: 'create.setup' },
        { role: 'student', permission: '' },
        { role: 'applicant', permission: 'create.setup' },
        { role: 'applicant', permission: '' }
      ]
    : [
        { role: portalRole, permission: 'create.setup' },
        { role: portalRole, permission: '' },
        { role: 'student', permission: 'create.setup' },
        { role: 'student', permission: '' }
      ];

  const uniqueAttempts = attempts.filter((attempt, index, arr) => {
    return arr.findIndex((entry) => entry.role === attempt.role && entry.permission === attempt.permission) === index;
  });

  let sawRateLimit = false;
  let retryAfterMs = 2000;
  let lastStatus = 500;
  let lastPayload = { success: false, message: 'No se pudo crear la sesión de vinculación de tarjeta', errors: {} };

  for (const attempt of uniqueAttempts) {
    const headers = {
      'Authorization': auth,
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'X-User-Role': attempt.role
    };

    if (attempt.permission) {
      headers['X-User-Permission'] = attempt.permission;
    }

    try {
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), 30000);

      const upstreamRes = await fetch(`${API_BASE}/cards`, {
        method: 'POST',
        headers,
        signal: controller.signal
      });
      clearTimeout(timeoutId);

      const textBody = await upstreamRes.text();
      const parsedBody = (() => {
        try {
          return JSON.parse(textBody);
        } catch {
          return null;
        }
      })();

      if (upstreamRes.ok) {
        return toJsonResponse(parsedBody || { success: true, data: {} }, 200);
      }

      lastStatus = upstreamRes.status;
      lastPayload = parsedBody || { success: false, message: `Error ${upstreamRes.status}: ${upstreamRes.statusText}`, errors: {} };

      if (upstreamRes.status === 429) {
        sawRateLimit = true;
        retryAfterMs = parseRetryAfterMs(upstreamRes.headers.get('Retry-After'));
        await wait(retryAfterMs);
        continue;
      }

      if (upstreamRes.status === 403 || upstreamRes.status === 404) {
        continue;
      }

      if (upstreamRes.status >= 500 && upstreamRes.status <= 599) {
        continue;
      }

      break;
    } catch (error) {
      const isTimeout = String(error?.name || '').toLowerCase() === 'aborterror';
      lastStatus = 500;
      lastPayload = {
        success: false,
        message: isTimeout
          ? 'El servidor tardó demasiado en responder al vincular tarjeta'
          : String(error?.message || error || 'Error al crear la sesión de tarjeta'),
        errors: {}
      };
    }
  }

  if (sawRateLimit) {
    return toJsonResponse({
      success: false,
      rate_limited: true,
      retry_after_ms: retryAfterMs,
      message: 'Has excedido el límite de solicitudes, intenta nuevamente en unos segundos',
      errors: {}
    }, 200);
  }

  const safeMessage = lastPayload?.message || (lastStatus === 403 ? 'No tienes permisos para vincular tarjeta' : 'No se pudo crear la sesión de tarjeta');
  return toJsonResponse({
    success: false,
    message: safeMessage,
    errors: lastPayload?.errors || {}
  }, 200);
}
