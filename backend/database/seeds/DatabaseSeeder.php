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

        factory(\App\User::class,5)->create()->each(function ($user){
            $user->videos()->saveMany(factory(\App\Video::class, rand(1,5))->make([
                'user_id'=>$user->id,

            ]));
        });
    }

}
