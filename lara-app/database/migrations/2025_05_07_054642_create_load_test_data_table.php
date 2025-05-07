<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('load_test_data', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('name', 100)->index();
            $table->text('description')->nullable();
            $table->integer('quantity')->default(0);
            $table->decimal('price', 10, 2);
            $table->boolean('is_active')->default(true);
            $table->json('metadata')->nullable();
            $table->date('purchase_date');
            $table->time('purchase_time');
            $table->enum('status', ['pending', 'processing', 'completed', 'failed'])->default('pending');
            $table->foreignId('user_id')->nullable()->constrained()->onDelete('set null');
            $table->string('email')->unique();
            $table->ipAddress('ip_address')->nullable();
            $table->macAddress('mac_address')->nullable();
            $table->unsignedBigInteger('views_count')->default(0);
            $table->float('rating', 3, 2)->default(0.00);
            $table->char('code', 10)->unique();
            $table->year('year_created');
            $table->timestamps();
            $table->softDeletes();

            // Composite indexes
            $table->index(['status', 'created_at']);
            $table->index(['price', 'quantity']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('load_test_data');
    }
};
