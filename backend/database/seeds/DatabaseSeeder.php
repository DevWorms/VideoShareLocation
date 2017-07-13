<?php

use App\User;
use Faker\Factory;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run()
    {
        $faker = Factory::create("es_Es");
        for ($i = 0; $i < 10; $i++) {
            User::create([
                "name" => $faker->name,
                "email" => $faker->email,
                "password" => bcrypt("nose"),
                "phone" => $faker->phoneNumber,
                "tokenfb" => $faker->word,
                "apikey" => $i + 1,
            ]);
        }
    }
}
