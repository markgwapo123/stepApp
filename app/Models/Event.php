<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Facades\Storage;
use Carbon\Carbon;

class Event extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'title',
        'description',
        'location',
        'date',
        'time',
        'user_id',
        'image'
    ];

    protected $casts = [
        'date' => 'date',
    ];

    protected $dates = ['deleted_at'];

    protected $with = ['user'];

    /**
     * Get the user who created the event.
     */
    public function user()
    {
        return $this->belongsTo(User::class, 'user_id')->select(['id', 'name', 'profile_picture']);
    }

    /**
     * Accessor to get the full URL of the event image.
     */
    public function getImageAttribute($value)
    {
        return $value ? asset('storage/' . ltrim($value, '/')) : null;
    }

    /**
     * Accessor to format the time properly.
     */
    public function getTimeAttribute($value)
    {
        return $value ? Carbon::parse($value)->format('H:i') : null;
    }

    public function getImageUrlAttribute() {
        return $this->image ? Storage::url($this->image) : null;
    }
}
