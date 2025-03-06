<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\EventController;

// ✅ Public Routes
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::get('/test', function () {
    return response()->json(['message' => '🚀 API is working!!!']);
});

// 📅 Public Events Access
Route::get('/events', [EventController::class, 'index']); // Get all events

// ✅ Protected Routes (Require Authentication)
Route::middleware('auth:sanctum')->group(function () {
    // 🔑 Authentication
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/user', function (Request $request) {
        return $request->user();
    });

    // 📅 Events (Protected)
    Route::post('/events', [EventController::class, 'store']); // Create event
    Route::get('/events/{id}', [EventController::class, 'show']); // Get single event
    Route::put('/events/{id}', [EventController::class, 'update']); // Update event
    Route::delete('/events/{id}', [EventController::class, 'destroy']); // Delete event

    // 👍 Like & 💬 Comment
    Route::post('/events/{id}/like', [EventController::class, 'likeEvent']);
    Route::post('/events/{id}/comment', [EventController::class, 'commentOnEvent']);
});
