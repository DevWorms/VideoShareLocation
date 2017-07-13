<?php

namespace App;

use Illuminate\Database\Eloquent\Model;

class Video extends Model
{
    protected $fillable = [
        'user_id','nombre', 'descripcion','duracion', 'lat','long', 'size','ruta',
    ];
}
