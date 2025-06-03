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
use Psr\Log\LoggerInterface;

class StderrAuditDriver implements AuditDriver
{
    private const LOG_LABEL = 'app.audit';

    private const HEADER_CORRELATION_ID = 'X-CORRELATION-ID';

    private const HEADER_USER_ID = 'X-USER-ID';

    private const HEADER_USER_TYPE = 'X-USER-TYPE';

    private const DEFAULT_USER_TYPE = 'sso';

    /**
     * The name of the application.
     */
    protected string $appName;

    /**
     * The logger instance.
     */
    protected LoggerInterface $logger;

    /**
     * Create a new instance of the audit driver.
     */
    public function __construct()
    {
        $this->appName = config('app.name') ?: 'unknown';
        $this->logger = $this->createLogger();
    }

    /**
     * Create and configure the logger instance.
     */
    protected function createLogger(): LoggerInterface
    {
        return Log::build([
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
     * Prepare the audit data with additional context.
     *
     * @param  Auditable  $model  The model to audit
     */
    protected function prepareAuditData(Auditable $model): array
    {
        $auditData = $model->toAudit();
        $request = request();

        $auditData['service_name'] = $this->appName;
        $auditData['occurred_at'] = now()->toIso8601String();

        $correlationId = $request->header(self::HEADER_CORRELATION_ID);
        if ($correlationId !== null) {
            $auditData['correlation_id'] = $correlationId;
        }

        $userId = $request->header(self::HEADER_USER_ID);
        if ($userId !== null) {
            $auditData['user_id'] = $userId;
            $auditData['user_type'] = $request->header(self::HEADER_USER_TYPE, self::DEFAULT_USER_TYPE);
        }

        return $auditData;
    }

    /**
     * Perform an audit.
     */
    public function audit(Auditable $model): Audit
    {
        $auditData = $this->prepareAuditData($model);
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
}