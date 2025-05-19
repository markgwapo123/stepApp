<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;

class UserController extends Controller
{

    public function index()
{
    $users = User::withCount('events')->get();

    return response()->json($users);
}

    public function fetchAllUsersWithEventCount()
    {
        $users = User::withCount('events')->get();

        return response()->json($users->map(function ($user) {
            return [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'profile_picture' => $user->profile_picture,
                'event_count' => $user->events_count,
            ];
        }));
    }
}
