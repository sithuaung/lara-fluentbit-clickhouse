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

        $logData = [
            'service_name' => 'inventory',
            'event_type' => 'create',
            'event_time' => now()->toDateTimeString(),
            'url' => 'https://example.com/orders',
            'ip_address' => '192.168.1.1',
            'user_agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
            'actor_type' =>' user',
            'actor_id' => '22b44ddd-9a9e-4572-a4bc-9ed8e8a27f0c',
            'entity_type' => 'order',
            'entity_id' => '22b44ddd-9a9e-4572-a4bc-9ed8e8a27f0c',
            'old_data' => [
                'status' => 'pending',
                'total_amount' => 100.00,
                'items' => [
                    ['id' => 1, 'quantity' => 2],
                    ['id' => 2, 'quantity' => 1]
                ]
            ],
            'new_data' => [
                'status' => 'completed',
                'total_amount' => 100.00,
                'items' => [
                    ['id' => 1, 'quantity' => 2],
                    ['id' => 2, 'quantity' => 1]
                ]
            ],
            'metadata' => [
                'additional_info' => 'value',
                'another_info' => 'value2',
            ],
            'version' => '1',
            'source' => 'admin',
            'description' => 'This is a demo log entry',
            'correlation_id' => '22b44ddd-9a9e-4572-a4bc-9ed8e8a27f0c',
            'tags' => ['important', 'user_action'],
        ];
        
        Log::channel('stderr')->info('Audit Log', $logData);

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
