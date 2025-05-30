<?php

namespace App\AuditDrivers;

use Illuminate\Support\Facades\Log;
use Monolog\Formatter\JsonFormatter;
use Monolog\Handler\StreamHandler;
use Monolog\Processor\PsrLogMessageProcessor;
use OwenIt\Auditing\Contracts\Audit;
use OwenIt\Auditing\Contracts\Auditable;
use OwenIt\Auditing\Contracts\AuditDriver;
use OwenIt\Auditing\Models\Audit as AuditModel;

class StderrAuditLogger implements AuditDriver
{
    /**
     * The logger instance.
     *
     * @var \Illuminate\Log\Logger
     */
    protected $logger;

    /**
     * The name of the application.
     *
     * @var string
     */
    protected $appName;

    const LOG_LABEL = 'ClickHouseAuditLogger';

    /**
     * Create a new instance of the audit driver.
     */
    public function __construct()
    {
        $this->appName = config('app.name') ?: 'unknown';
        $this->logger = Log::build([
            'driver' => 'monolog',
            'level' => 'debug',
            'handler' => StreamHandler::class,
            'handler_with' => [
                'stream' => 'php://stderr',
            ],
            'formatter' => JsonFormatter::class,
            'processors' => [PsrLogMessageProcessor::class],
        ]);
    }

    /**
     * Perform an audit.
     */
    public function audit(Auditable $model): Audit
    {
        $auditData = $model->toAudit();

        $auditData['service_name'] = $this->appName;
        $auditData['event_time'] = now()->toIso8601String();
        $auditData['user_id'] = "abcd21212121212";
        $auditData['user_type'] = "App\SomeNamespace\SomeClass";
        $correlationId = request()->header('X-CORRELATION-ID');
        if ($correlationId !== null) {
            $auditData['correlation_id'] = $correlationId;
        }
        $userId = request()->header('X-USER-ID');
        if ($userId !== null) {
            $auditData['user_type'] = request()->header('X-USER-TYPE', 'sso');
            $auditData['user_id'] = $userId;
        }

        $this->logger->info(self::LOG_LABEL, $auditData);

        return new AuditModel($auditData);
    }

    /**
     * Remove older audits that go over the threshold.
     */
    public function prune(Auditable $model): bool
    {
        return false;
    }

    // protected function sanitize(array $audit)
    // {
    //     foreach (['old_values', 'new_values'] as $key) {
    //         if (isset($audit[$key]) && is_array($audit[$key])) {
    //             $audit[$key] = json_encode($audit[$key]);
    //         }
    //     }

    //     return $audit;
    // }
}
