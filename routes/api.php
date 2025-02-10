<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Auth\AuthenticatedSessionController;
use App\Http\Controllers\Auth\RegisteredUserController;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\EventController;

Route::middleware('auth:sanctum')->get('/events', [EventController::class, 'index']);



Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::middleware('auth:sanctum')->get('/events', [EventController::class, 'index']);

Route::post('/logout', [AuthController::class, 'logout'])->middleware('auth:sanctum');


Route::get('/test', function () {
    return response()->json(['message' => 'API is working!!!']);
});

Route::middleware(['auth:sanctum'])->get('/user', function (Request $request) {
    return $request->user();
});


Route::middleware('auth:sanctum')->get('/events', [EventController::class, 'index']);
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/events', [EventController::class, 'store']); // Create event
    Route::get('/events', [EventController::class, 'index']); // Get all events
    Route::get('/events/{id}', [EventController::class, 'show']); // Get single event
    Route::put('/events/{id}', [EventController::class, 'update']); // Update event
    Route::delete('/events/{id}', [EventController::class, 'destroy']); // Delete event
});

Route::get('/data', [EventController::class, 'index']);

Route::get('/events', [EventController::class, 'index']);


