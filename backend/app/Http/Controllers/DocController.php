<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class DocController extends Controller
{
    public function documentacion (){/**la vista que me retornara*/
        return view('swagger');
    }
}
