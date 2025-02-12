<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Event;
use Illuminate\Support\Facades\Auth;

class EventController extends Controller
{
    // ✅ CREATE EVENT
    public function store(Request $request)
    {
        $validatedData = $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'location' => 'nullable|string',
            'date' => 'required|date',
            'time' => 'required|date_format:H:i',
        ]);

        $userId = Auth::id(); 
        if (!$userId) {
            return response()->json(['error' => 'Unauthorized'], 401);
        }

        $event = Event::create([
            'title' => $validatedData['title'],
            'description' => $validatedData['description'] ?? null,
            'location' => $validatedData['location'] ?? null,
            'date' => $validatedData['date'],
            'time' => $validatedData['time'],
            'user_id' => $userId,
        ]);

        return response()->json([
            'message' => '✅ Event created successfully!',
            'event' => $event
        ], 201);
    }

    // ✅ FETCH ALL EVENTS (With User Details)
    public function index()
    {
        $events = Event::with('user:id,name,profile_picture')->get(); // Fetch events with user info
        return response()->json($events, 200);
    }

    // ✅ FETCH A SINGLE EVENT
    public function show($id)
    {
        $event = Event::with('user:id,name,profile_picture')->find($id);

        if (!$event) {
            return response()->json(['error' => 'Event not found'], 404);
        }

        return response()->json($event, 200);
    }

    // ✅ UPDATE EVENT (Only Owner Can Update)
    public function update(Request $request, $id)
    {
        $event = Event::find($id);

        if (!$event) {
            return response()->json(['error' => 'Event not found'], 404);
        }

        if ($event->user_id !== Auth::id()) {
            return response()->json(['error' => 'Unauthorized'], 403);
        }

        $validatedData = $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'location' => 'nullable|string|max:255',
            'date' => 'required|date',
            'time' => 'required|date_format:H:i',
        ]);

        $event->update($validatedData);

        return response()->json(['message' => '✅ Event updated successfully', 'event' => $event], 200);
    }

    // ✅ DELETE EVENT (Only Owner Can Delete)
    public function destroy($id)
    {
        $event = Event::find($id);

        if (!$event) {
            return response()->json(['error' => 'Event not found'], 404);
        }

        if ($event->user_id !== Auth::id()) {
            return response()->json(['error' => 'Unauthorized'], 403);
        }

        $event->delete();

        return response()->json(['message' => '✅ Event deleted successfully'], 200);
    }
}
