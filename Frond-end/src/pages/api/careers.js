export async function GET({ request }) {
  const url = new URL(request.url);
  const forceRefresh = url.searchParams.get('forceRefresh') || 'false';
  const upstreamUrl = new URL('https://nginx-production-728f.up.railway.app/api/v1/careers');
  upstreamUrl.searchParams.set('forceRefresh', forceRefresh);

  const auth = request.headers.get('authorization') || '';
  const userRole = request.headers.get('x-user-role') || '';

  const upstreamRes = await fetch(upstreamUrl.toString(), {
    method: 'GET',
    headers: {
      'Accept': 'application/json',
      ...(auth ? { 'Authorization': auth } : {}),
      ...(userRole ? { 'X-User-Role': userRole } : {})
    }
  });

  const body = await upstreamRes.text();
  return new Response(body, {
    status: upstreamRes.status,
    headers: {
      'Content-Type': upstreamRes.headers.get('content-type') || 'application/json'
    }
  });
}
