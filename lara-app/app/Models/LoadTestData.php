<?php

namespace App\Models;

use Database\Factories\LoadTestDataFactory;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use OwenIt\Auditing\Auditable;
use OwenIt\Auditing\Contracts\Auditable as AuditableContract;

class LoadTestData extends Model implements AuditableContract
{
    use HasFactory, HasUuids, SoftDeletes, Auditable;
    protected $guarded = ['id'];

    protected $table = 'load_test_data';

    protected $casts = ['metadata' => 'json'];

    protected static function newFactory()
    {
        return LoadTestDataFactory::new();
    }
}
