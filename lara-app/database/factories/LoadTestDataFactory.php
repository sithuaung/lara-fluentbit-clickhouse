<?php

namespace Database\Factories;

use App\Models\LoadTestData;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Str;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\LoadTestData>
 */
class LoadTestDataFactory extends Factory
{
    protected $model = LoadTestData::class;

    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $purchaseDate = $this->faker->dateTimeBetween('-1 year', 'now');

        return [
            'id' => Str::uuid(),
            'name' => $this->faker->words(3, true),
            'description' => $this->faker->paragraph(),
            'quantity' => $this->faker->numberBetween(1, 1000),
            'price' => $this->faker->randomFloat(2, 10, 1000),
            'is_active' => $this->faker->boolean(80), // 80% chance of being true
            'metadata' => [
                'tags' => $this->faker->words(3),
                'features' => $this->faker->words(5),
                'specifications' => [
                    'color' => $this->faker->colorName(),
                    'size' => $this->faker->randomElement(['S', 'M', 'L', 'XL']),
                    'weight' => $this->faker->randomFloat(2, 0.1, 10),
                ],
            ],
            'purchase_date' => $purchaseDate->format('Y-m-d'),
            'purchase_time' => $purchaseDate->format('H:i:s'),
            'status' => $this->faker->randomElement(['pending', 'processing', 'completed', 'failed']),
            'user_id' => null, // You might want to create a User factory and use it here
            'email' => $this->faker->unique()->safeEmail(),
            'ip_address' => $this->faker->ipv4(),
            'mac_address' => $this->faker->macAddress(),
            'views_count' => $this->faker->numberBetween(1000, 10000),
            'rating' => $this->faker->randomFloat(2, 0, 5),
            'code' => strtoupper($this->faker->unique()->bothify('??####??')),
            'year_created' => $this->faker->year(),
            'created_at' => now(),
            'updated_at' => now(),
        ];
    }

    /**
     * Indicate that the model is inactive.
     */
    public function inactive(): static
    {
        return $this->state(fn (array $attributes) => [
            'is_active' => false,
        ]);
    }

    /**
     * Indicate that the model is completed.
     */
    public function completed(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'completed',
        ]);
    }

    /**
     * Indicate that the model is failed.
     */
    public function failed(): static
    {
        return $this->state(fn (array $attributes) => [
            'status' => 'failed',
        ]);
    }

    /**
     * Indicate that the model has high price.
     */
    public function highPrice(): static
    {
        return $this->state(fn (array $attributes) => [
            'price' => $this->faker->randomFloat(2, 1000, 5000),
        ]);
    }

    /**
     * Indicate that the model has high quantity.
     */
    public function highQuantity(): static
    {
        return $this->state(fn (array $attributes) => [
            'quantity' => $this->faker->numberBetween(1000, 10000),
        ]);
    }
}
