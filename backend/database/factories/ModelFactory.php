<?php

/*
|--------------------------------------------------------------------------
| Model Factories
|--------------------------------------------------------------------------
|
| Here you may define all of your model factories. Model factories give
| you a convenient way to create models for testing and seeding your
| database. Just tell the factory how a default model should look.
|
*/

/** @var \Illuminate\Database\Eloquent\Factory $factory */
$factory->define(App\User::class, function (Faker\Generator $faker) {
    static $password;

    return [
        'name' => $faker->name,
        'email' => $faker->unique()->safeEmail,
        'password' => $password ?: $password = bcrypt('secret'),
        'phone' => $faker->phoneNumber,
        'tokenfb' => str_random(20),
        'apikey' => str_random(10),
        'url_img' => $faker->imageUrl(),
        'remember_token' => str_random(10),
    ];
});

$factory->define(App\Video::class, function (Faker\Generator $faker){
    static $user_id;
    return [
        'user_id' =>$user_id ?: $user_id = rand(1,5) ,
        'nombre' => $faker->word . "." . $faker->fileExtension,
        'descripcion' =>$faker->paragraph,
        'duracion' => $faker->numberBetween(1,7),
        'lat' => $faker->latitude,
        'long' => $faker->longitude,
        'size' => $faker->numberBetween(10000000,100000000),
        'ruta' => $faker->url,
    ];

});
