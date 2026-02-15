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
      redirect: 'manual',
      headers: {
        'Authorization': auth,
        'Accept': 'application/json',
        'X-User-Role': role,
        'X-User-Permission': permission
      }
    });

    const contentType = upstreamRes.headers.get('content-type') || '';
    const locationHeader = upstreamRes.headers.get('location');

    if (locationHeader && [301, 302, 303, 307, 308].includes(upstreamRes.status)) {
      const expiresIn = (() => {
        try {
          const url = new URL(locationHeader);
          return Number(url.searchParams.get('X-Goog-Expires') || url.searchParams.get('Expires') || 0) || null;
        } catch {
          return null;
        }
      })();

      return new Response(JSON.stringify({
        success: true,
        data: {
          url: locationHeader,
          expires_in: expiresIn,
          content_type: 'text/html'
        },
        message: 'Recibo generado correctamente'
      }), {
        status: 200,
        headers: {
          'Content-Type': 'application/json',
          'Cache-Control': 'no-store'
        }
      });
    }

    if (contentType.includes('application/json')) {
      const bodyText = await upstreamRes.text();
      return new Response(bodyText, {
        status: upstreamRes.status,
        headers: {
          'Content-Type': 'application/json',
          'Cache-Control': 'no-store'
        }
      });
    }

    if (upstreamRes.ok) {
      return new Response(JSON.stringify({
        success: true,
        data: {
          url: upstreamRes.url,
          expires_in: null,
          content_type: contentType || 'text/html'
        },
        message: 'Recibo generado correctamente'
      }), {
        status: 200,
        headers: {
          'Content-Type': 'application/json',
          'Cache-Control': 'no-store'
        }
      });
    }

    const errorText = await upstreamRes.text();
    return new Response(errorText || JSON.stringify({ success: false, message: 'Error al generar el recibo', errors: {} }), {
      status: upstreamRes.status,
      headers: {
        'Content-Type': 'application/json',
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
