<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Event extends Model
{
    use HasFactory;

    protected $fillable = [
        'title',
        'description',
        'location',
        'date',
        'time',
        'user_id'
    ];

    /**
     * Get the user who created the event.
     */
    public function user()
    {
        return $this->belongsTo(User::class, 'user_id')->select(['id', 'name', 'profile_picture']);
    }
}
