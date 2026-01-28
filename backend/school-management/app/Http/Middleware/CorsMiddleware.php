<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class CorsMiddleware
{
    public function handle(Request $request, Closure $next)
    {
        // Handle preflight requests (OPTIONS)
        if ($request->isMethod('OPTIONS')) {
            return response('', 200)
                ->header('Access-Control-Allow-Origin', '*')
                ->header('Access-Control-Allow-Methods', 'GET, POST, PUT, PATCH, DELETE, OPTIONS')
                ->header('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-User-Role, X-User-Permission')
                ->header('Access-Control-Max-Age', '86400')
                ->header('Access-Control-Expose-Headers', 'Authorization');
        }

        $response = $next($request);

        // Add CORS headers to the response
        $response->header('Access-Control-Allow-Origin', '*');
        $response->header('Access-Control-Allow-Methods', 'GET, POST, PUT, PATCH, DELETE, OPTIONS');
        $response->header('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-User-Role, X-User-Permission');
        $response->header('Access-Control-Max-Age', '86400');
        $response->header('Access-Control-Expose-Headers', 'Authorization');

        return $response;
    }
}
