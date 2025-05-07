<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

Route::get('/write-log', function () {
    Log::channel('stderr')->info('Test log');
});
