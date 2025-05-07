<?php

use App\Models\LoadTestData;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

Route::get('/create-record', function () {
    LoadTestData::factory()->create();
});
