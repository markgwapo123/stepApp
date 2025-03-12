<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Event;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Log;

class EventController extends Controller
{
    // ✅ CREATE EVENT
    public function store(Request $request)
    {
        $request->validate([
            'title' => 'required|string',
            'description' => 'required|string',
            'location' => 'required|string',
            'date' => 'required|date',
            'time' => 'required',
            'image' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
        ]);
    
        $imagePath = null;
    
        if ($request->hasFile('image')) {
            $imagePath = $request->file('image')->store('event_images', 'public');
            Log::info("Image uploaded: " . $imagePath); // ✅ Log the image path
        }
    
        $event = Event::create([
            'user_id' => auth()->id(),
            'title' => $request->title,
            'description' => $request->description,
            'location' => $request->location,
            'date' => $request->date,
            'time' => $request->time,
            'image' => $imagePath,
        ]);
    
        return response()->json([
            'message' => 'Event created successfully!',
            'event' => $event
        ], 201);
    }
    
    // ✅ FETCH ALL EVENTS
    public function index()
    {
        $events = Event::with('user:id,name,profile_picture')->get();

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
            'time' => 'required',
            'image' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
        ]);

        // ✅ Handle Image Update
        if ($request->hasFile('image')) {
            // Delete old image if exists
            if ($event->image) {
                Storage::disk('public')->delete($event->image);
            }
            $validatedData['image'] = $request->file('image')->store('event_images', 'public');
        }

        $event->update($validatedData);

        return response()->json([
            'message' => '✅ Event updated successfully!',
            'event' => $event
        ], 200);
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

        // ✅ Delete Image
        if ($event->image) {
            Storage::disk('public')->delete($event->image);
        }

        $event->delete();

        return response()->json(['message' => '✅ Event deleted successfully'], 200);
    }

    
}
