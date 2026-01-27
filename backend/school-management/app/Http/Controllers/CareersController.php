<?php

namespace App\Http\Controllers;

use App\Models\Career;
use Illuminate\Http\Request;

class CareersController extends Controller
{
    public function index()
    {
        $careers = Career::all();
        return response()->json([
            'success' => true,
            'message' => 'Carreras encontradas.',
            'data' => ['careers' => $careers]
        ]);
    }

    public function show(Career $career)
    {
        return response()->json([
            'success' => true,
            'message' => 'Carrera encontrada.',
            'data' => ['career' => $career]
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'career_name' => 'required|string|max:255|unique:careers,career_name'
        ]);

        $career = Career::create($request->only('career_name'));

        return response()->json([
            'success' => true,
            'message' => 'Carrera creada exitosamente.',
            'data' => ['career' => $career]
        ], 201);
    }

    public function update(Request $request, Career $career)
    {
        $validated = $request->validate([
            'career_name' => 'required|string|max:255|unique:careers,career_name,' . $career->id
        ]);

        $career->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'Carrera actualizada.',
            'data' => ['updated' => $career]
        ]);
    }

    public function destroy(Career $career)
    {
        $name = $career->career_name;
        $career->delete();

        return response()->json([
            'success' => true,
            'message' => "Carrera $name eliminada exitosamente."
        ]);
    }
}
