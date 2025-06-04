<?php

use App\Models\LoadTestData;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Str;

Route::get('/', function () {
    return view('welcome');
});

Route::get('/create-record', function () {
    LoadTestData::factory()->create();
    return response()->json(['message' => 'Record created']);
});

Route::get('/update-record', function () {
    $record = LoadTestData::first();
    $record->update(['name' => Str::random(10)]);
    return response()->json(['message' => 'Record updated']);
});
