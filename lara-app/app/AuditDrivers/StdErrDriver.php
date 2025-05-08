<?php

namespace App\AuditDrivers;

use Illuminate\Support\Facades\Log;
use OwenIt\Auditing\Contracts\Audit;
use OwenIt\Auditing\Contracts\AuditDriver;
use OwenIt\Auditing\Contracts\Auditable;
use OwenIt\Auditing\Models\Audit as AuditModel;

class StdErrDriver implements AuditDriver
{
    /**
     * Perform an audit.
     *
     * @param \OwenIt\Auditing\Contracts\Auditable $model
     *
     * @return \OwenIt\Auditing\Contracts\Audit
     */
    public function audit(Auditable $model): Audit
    {
        $auditData = $model->toAudit();

        $auditData = array_merge($auditData, [
            'service_name' => 'Service-A',
            'version' => '1.0',
            'source' => 'Service-A',
            'event_time' => now()->toDateTimeString(),
        ]);

        // Log to stderr with proper formatting
        Log::channel('stderr')->info('StdErrLog', $auditData);

        // Create and return an Audit model instance
        return new AuditModel($auditData);
    }

    /**
     * Remove older audits that go over the threshold.
     *
     * @param \OwenIt\Auditing\Contracts\Auditable $model
     *
     * @return bool
     */
    public function prune(Auditable $model): bool
    {
        // Since we're using stderr, we don't need to implement pruning
        return true;
    }
}
