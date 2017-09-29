<?php

namespace App\Http\Controllers;

use App\User;
use App\Video;
use Exception;
use Illuminate\Database\Eloquent\ModelNotFoundException;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;
use Monolog\Processor\UidProcessorTest;

class UserController extends Controller
{
    public function login(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'tokenfb' => 'required',
            ]);

            if ($validator->fails()) {
                //Si los datos no estan completos, devuelve error
                $errors = $validator->errors();
                $res['estado'] = 0;
                $res['mensaje'] = $errors->first();
                return response()->json($res, 400);
            } else {
                $apikey = Hash::make($request->get('tokenfb'));
                $name = $request->get("name");
                $tokenfb = $request->get("tokenfb");
                $imagen = $request->get("url_img");

                if ($name == null || $name == "") {

                    $usuario = User::firstOrCreate([//busca el usuario y lo crea
                        'tokenfb' => $tokenfb,
                    ], ['apikey' => $apikey, "name" => $name, 'url_img' => $imagen]);

                } else {
                    $usuario = User::where("tokenfb", $tokenfb)->first();
                    if ($usuario) {
                        $usuario->name = $name;
                        $usuario->url_img = $imagen;
                        $usuario->save();
                    } else {
                        $usuario = User::create([
                            'tokenfb' => $tokenfb,
                            'name' => $name,
                            'apikey' => $apikey,
                            'url_img' => $imagen,
                        ]);
                    }
                }
            }

            $res ['estado'] = 1;
            $res ['mensaje'] = "¡Registro con éxito!";
            $res ['user'] = $usuario;
            return response()->json($res, 200);
        } catch
        (Exception $error) {
            $res['estado'] = 0;
            $res['mensaje'] = $error->getMessage();
            return response()->json($res, 500);
        }
    }

    public function profile(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'apikey' => 'required',
                'id' => 'required',

            ]);

            if ($validator->fails()) {
                //Si los datos no estan completos, devuelve error
                $errors = $validator->errors();
                $res['estado'] = 0;
                $res['mensaje'] = $errors->first();
                return response()->json($res, 400);
            } else {
                $user = User::where([
                    'id' => $request->get('id'),
                    'apikey' => $request->get("apikey"),
                ])->with("videos")->firstOrFail();

                foreach ($user->videos as $video) {
                    $video = $this->returnVideo($video);
                }

                $res ['estado'] = 1;
                $res ['user'] = $user;
                return response()->json($res, 200);
            }
        } catch (ModelNotFoundException $error) {
            $res['estado'] = 0;
            $res['mensaje'] = "Usuario incorrecto";
            return response()->json($res, 400);
        } catch (Exception $error) {
            $res['estado'] = 0;
            $res['mensaje'] = $error->getMessage();
            return response()->json($res, 500);
        }
    }

    public function users(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'apikey' => 'required',
                'id' => 'required',

            ]);

            if ($validator->fails()) {
                //Si los datos no estan completos, devuelve error
                $errors = $validator->errors();
                $res['estado'] = 0;
                $res['mensaje'] = $errors->first();
                return response()->json($res, 400);
            }

            $users = User::select("name", "id")->get();

            $res ['estado'] = 1;
            $res ['mensaje'] = "¡success!";
            $res ['users'] = $users;
            return response()->json($res, 200);

        } catch (ModelNotFoundException $error) {
            $res['estado'] = 0;
            $res['mensaje'] = "Usuario incorrecto";
            return response()->json($res, 400);

        } catch (Exception $error) {
            $res['estado'] = 0;
            $res['mensaje'] = $error->getMessage();
            return response()->json($res, 500);
        }
    }

    public function returnVideo(Video $video) {
        $url = $video->ruta;
        $video->url = url(Storage::url($url));

        return $video;
    }
}
