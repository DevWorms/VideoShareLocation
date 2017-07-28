<?php

use App\User;
use App\Video;
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

        factory(\App\User::class,5)->create()->each(function ($user){
            $user->videos()->saveMany(factory(\App\Video::class, rand(1,5))->make([
                'user_id'=>$user->id,

            ]));
        });

        Video::create([
            'user_id'=> 1,
            'nombre'=> "hola",
            'descripcion' =>"nose",
            'duracion'=>7,
            'lat'=>19.3929598,
            'long'=>-99.072011,
            'size'=>1,
            'ruta'=>"..",
        ]);
        Video::create([
            'user_id'=> 1,
            'nombre'=> "adios",
            'descripcion' =>"nosee",
            'duracion'=>7,
            'lat'=>19.3933454,
            'long'=>-99.0734997,
            'size'=>1,
            'ruta'=>"..",
        ]);
        Video::create([
            'user_id'=> 5,
            'nombre'=> "si",
            'descripcion' =>"nosee0",
            'duracion'=>7,
            'lat'=>19.3933454,
            'long'=>-99.0734997,
            'size'=>1,
            'ruta'=>"..",
        ]);
        Video::create([
            'user_id'=> 5,
            'nombre'=> "no",
            'descripcion' =>"nosee1",
            'duracion'=>7,
            'lat'=>19.3933454,
            'long'=>-99.0734997,
            'size'=>1,
            'ruta'=>"..",
        ]);
        Video::create([
            'user_id'=> 5,
            'nombre'=> "tal vez",
            'descripcion' =>"nosee2",
            'duracion'=>7,
            'lat'=>19.3871369,
            'long'=>-99.0666843,
            'size'=>1,
            'ruta'=>"..",
        ]);
        Video::create([
            'user_id'=> 5,
            'nombre'=> "quiza",
            'descripcion' =>"nosee3",
            'duracion'=>7,
            'lat'=>19.3847926,
            'long'=>-99.078404,
            'size'=>1,
            'ruta'=>"..",
        ]);
    }

}
