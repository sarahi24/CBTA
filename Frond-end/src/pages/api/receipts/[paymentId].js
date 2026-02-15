const API_BASE = 'https://nginx-production-728f.up.railway.app/api/v1';

export const prerender = false;

export async function GET({ params, request }) {
  const paymentId = params?.paymentId;

  if (!paymentId) {
    return new Response(JSON.stringify({ success: false, message: 'paymentId requerido', errors: {} }), {
      status: 400,
      headers: { 'Content-Type': 'application/json' }
    });
  }

  const auth = request.headers.get('authorization') || '';
  const role = request.headers.get('x-user-role') || 'student';
  const permission = request.headers.get('x-user-permission') || 'view.receipt';

  if (!auth) {
    return new Response(JSON.stringify({ success: false, message: 'Unauthenticated', errors: {} }), {
      status: 401,
      headers: { 'Content-Type': 'application/json' }
    });
  }

  const upstreamUrl = `${API_BASE}/payments/history/receipt/${paymentId}`;

  try {
    const upstreamRes = await fetch(upstreamUrl, {
      method: 'GET',
      headers: {
        'Authorization': auth,
        'Accept': 'application/json',
        'X-User-Role': role,
        'X-User-Permission': permission
      }
    });

    const bodyText = await upstreamRes.text();
    return new Response(bodyText, {
      status: upstreamRes.status,
      headers: {
        'Content-Type': upstreamRes.headers.get('content-type') || 'application/json',
        'Cache-Control': 'no-store'
      }
    });
  } catch (error) {
    return new Response(JSON.stringify({ success: false, message: 'Error al generar el recibo', errors: {} }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    });
  }
}
