<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Event;
use Illuminate\Support\Facades\Auth;

class EventController extends Controller
{
    // Create an event
    public function store(Request $request)
    {
        $validatedData = $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'location' => 'nullable|string',
            'date' => 'required|date',
            'time' => 'required|date_format:H:i',
        ]);
    
        // Ensure user authentication is working before setting user_id
        $userId = auth()->id(); 
        if (!$userId) {
            return response()->json(['error' => 'Unauthorized'], 401);
        }
    
        // Create the event with proper handling of nullable fields
        $event = Event::create([
            'title' => $validatedData['title'],
            'description' => $validatedData['description'] ?? null, // Handle nullable field
            'location' => $validatedData['location'] ?? null, // Handle nullable field
            'date' => $validatedData['date'],
            'time' => $validatedData['time'],
            'user_id' => $userId, // Assign authenticated user ID
        ]);
    
        if ($event) {
            return response()->json([
                'message' => '✅ Event created successfully!',
                'event' => $event
            ], 201);
        } else {
            return response()->json([
                'message' => '❌ Failed to create event.'
            ], 500);
        }
    }
    

    // Fetch all events (visible to all users)
    public function index()
    {
        return response()->json(Event::all(), 200);
    }
    
    // Fetch a single event
    public function show($id)
    {
        return response()->json(Event::with('user')->findOrFail($id));
    }

    // Update an event
    public function update(Request $request, $id)
    {
        $event = Event::findOrFail($id);

        if ($event->user_id !== Auth::id()) {
            return response()->json(['error' => 'Unauthorized'], 403);
        }

        $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'location' => 'required|string|max:255',
            'date' => 'required|date',
            'time' => 'required',
        ]);

        $event->update($request->all());

        return response()->json(['message' => 'Event updated successfully', 'event' => $event]);
    }

    // Delete an event
    public function destroy($id)
{
    // Find the event
    $event = Event::find($id);

    // Check if event exists
    if (!$event) {
        return response()->json([
            'message' => 'Event not found'
        ], 404);
    }

    // Delete the event
    $event->delete();

    return response()->json([
        'message' => 'Event deleted successfully'
    ], 200);
}

}