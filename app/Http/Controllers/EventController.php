<?php

namespace App\Http\Controllers;

use App\Models\Event;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;

class EventController extends Controller
{
    public function index()
    {
        $events = Event::with('user:id,name,profile_picture')->get();
        return response()->json($events);
    }

    public function show($id)
    {
        $event = Event::with('user:id,name,profile_picture')->find($id);
        if (!$event) {
            return response()->json(['error' => 'Event not found'], 404);
        }
        return response()->json($event);
    }

    public function store(Request $request)
    {
        $user = Auth::user();
        if (!$user) return response()->json(['error' => 'Unauthenticated'], 401);

        $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'required|string',
            'location' => 'required|string|max:255',
            'date' => 'required|date',
            'time' => 'required',
            'image' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
        ]);

        $imagePath = $request->hasFile('image') ? $request->file('image')->store('event_images', 'public') : null;

        $event = Event::create([
            'user_id' => $user->id,
            'title' => $request->title,
            'description' => $request->description,
            'location' => $request->location,
            'date' => $request->date,
            'time' => $request->time,
            'image' => $imagePath,
        ]);

        return response()->json(['message' => 'Event created successfully!', 'event' => $event], 201);
    }

    public function update(Request $request, $id)
    {
        $event = Event::find($id);
        if (!$event) return response()->json(['error' => 'Event not found'], 404);

        $user = Auth::user();
        if (!$user || $event->user_id !== $user->id) {
            return response()->json(['error' => 'Unauthorized'], 403);
        }

        $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'location' => 'nullable|string|max:255',
            'date' => 'required|date',
            'time' => 'required',
            'image' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
        ]);

        $data = $request->only(['title', 'description', 'location', 'date', 'time']);

        if ($request->hasFile('image')) {
            if ($event->image) Storage::disk('public')->delete($event->image);
            $data['image'] = $request->file('image')->store('event_images', 'public');
        }

        $event->update($data);

        return response()->json(['message' => 'Event updated successfully!', 'event' => $event]);
    }

    public function destroy($id)
    {
        $event = Event::find($id);
        if (!$event) return response()->json(['error' => 'Event not found'], 404);

        $user = Auth::user();
        if (!$user || $event->user_id !== $user->id) {
            return response()->json(['error' => 'Unauthorized'], 403);
        }

        if ($event->image) Storage::disk('public')->delete($event->image);

        $event->delete();

        return response()->json(['message' => 'Event deleted successfully']);
    }

    public function toggleInterested($id)
    {
        $user = Auth::user();
        if (!$user) return response()->json(['error' => 'Unauthenticated'], 401);

        $event = Event::find($id);
        if (!$event) return response()->json(['error' => 'Event not found'], 404);

        $alreadyInterested = $user->interestedEvents()->where('event_id', $id)->exists();

        if ($alreadyInterested) {
            $user->interestedEvents()->detach($id);
            $status = 'removed';
        } else {
            $user->interestedEvents()->attach($id);
            $status = 'added';
        }

        $interestedEvents = $user->interestedEvents()->with('user:id,name,profile_picture')->get();

        return response()->json([
            'message' => "Interested event $status successfully.",
            'interested_events' => $interestedEvents,
        ]);
    }

    public function myInterestedEvents()
    {
        $user = Auth::user();
        if (!$user) return response()->json(['error' => 'Unauthenticated'], 401);

        $interestedEvents = $user->interestedEvents()->with('user:id,name,profile_picture')->get();
        return response()->json($interestedEvents);
    }

    public function userEvents()
    {
        $user = Auth::user();
        if (!$user) return response()->json(['error' => 'Unauthenticated'], 401);

        $events = Event::where('user_id', $user->id)->with('user:id,name,profile_picture')->get();
        return response()->json($events);
    }

    public function suggestedEvents()
    {
        $user = Auth::user();
        if (!$user) return response()->json(['error' => 'Unauthenticated'], 401);

        $events = Event::where('user_id', '!=', $user->id)->with('user:id,name,profile_picture')->get();
        return response()->json($events);
    }

    // You can implement likeEvent() and commentOnEvent() if needed
}
