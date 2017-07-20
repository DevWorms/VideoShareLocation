<?php

namespace App\Http\Controllers;

use App\traits\LocationTriat;
use App\User;
use App\Video;
use Carbon\Carbon;
use Exception;
use Illuminate\Database\Eloquent\ModelNotFoundException;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;

class VideoController extends Controller
{

    use LocationTriat;
    private $extensions;
    private $size;
    private $distance;

    function __construct()
    {
        $this->size = 100000000;
        $this->distance= 5;
        $this->extensions = [
            // extensiones de video
            "h263", "h264", "mp4", "mov", "m4v",
            "mp3", "mpg", "mp4v", "avi", "wmv", "mkv",
        ];
    }

    public function video(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'id' => 'required',
                'apikey' => 'required',
                'lat' => 'required',
                'long' => 'required',
            ]);
            if ($validator->fails()) {
                //Si los datos no estan completos, devuelve error
                $errors = $validator->errors();
                $res['estado'] = 0;
                $res['mensaje'] = $errors->first();
                return response()->json($res, 400);
            }
            $user = User::where(['id' => $request->get('id'), 'apikey' => $request->get("apikey")])->firstOrfail();
            $video = $request->file("archivo");
            $validator = Validator::make(['file' => $video], ['file' => 'required']);
            // Si el archivo tiene extensión valida
            if ($validator->passes()) {
                // Si el archivo es mayor a 100mb
                if ($video->getSize() > $this->size) {
                    $response['estado'] = 0;
                    $response['mensaje'] = "El video excede el límite de 100mb";
                    return response()->json($response, 400);
                } else {
                    $extension = strtolower($video->getClientOriginalExtension());

                    if (in_array($extension, $this->extensions)) {
                        // Si va bien, lo mueve a la carpeta y guarda el registro
                        $url = $video->storeAs("/", uniqid() . '.' . $extension);
                        $nombre = $video->getClientOriginalName();
                        $descripcion = ($request->get("descripcion")) ? $request->get("descripcion") : "hola        ";
                        $lat = $request->get("lat");
                        $long = $request->get("long");
                        $size = $video->getSize();

                        Video::create([
                            'user_id' => $user->id,
                            'nombre' => $nombre,
                            'descripcion' => $descripcion,
                            'duracion' => 7,
                            'lat' => $lat,
                            'long' => $long,
                            'size' => $size,
                            'ruta' => $url,
                        ]);

                        $res ['estado'] = 1;
                        $res ['mensaje'] = "Exito";
                        return response()->json($res, 200);
                    } else {
                        return response()->json(['estado' => 0, 'mensaje' => 'Tipo de archivo no permitido: ' . $extension], 400);
                    }
                }
            } else {
                $response['estado'] = 0;
                $response['mensaje'] = "Error, tipo de archivo invalido";
                return response()->json($response, 400);
            }
        } catch (ModelNotFoundException $ex) {
            $res['estado'] = 0;
            $res['mensaje'] = "Usuario o contraseña incorrectos";
            return response()->json($res, 400);
        } catch (Exception $error) {
            $res['estado'] = 0;
            $res['mensaje'] = $error->getMessage();
            return response()->json($res, 500);
        }
    }
    public function allvideos(Request $request){
        try{
            $validator = Validator::make($request->all(), [
                'id' => 'required',
                'apikey' => 'required',
                'lat' => 'required',
                'long' => 'required',
            ]);
            if ($validator->fails()) {
                //Si los datos no estan completos, devuelve error
                $errors = $validator->errors();
                $res['estado'] = 0;
                $res['mensaje'] = $errors->first();
                return response()->json($res, 400);
            }
            $lat = $request->get("lat");
            $long = $request->get("long");
           $boundaries = $this->getBoundaries($lat, $long);
           $horamin = Carbon::now()->subHour(3);

           $allvideo = Video::where('created_at', '>=', $horamin)
               ->whereBetween('lat', [$boundaries['min_lat'], $boundaries['max_lat']])
               ->whereBetween('long', [$boundaries['min_lng'], $boundaries['max_lng']])
               ->selectRaw('*, ( 6371 * acos( cos( radians(?) ) *
                               cos( radians( lat ) )
                               * cos( radians( long ) - radians(?)
                               ) + sin( radians(?) ) *
                               sin( radians( lat ) ) )
                             ) AS distance', [$lat, $long, $lat])
               ->havingRaw("distance < ?", [$this->distance])
               ->orderBy('created_at')->get();

           foreach ($allvideo as $video) {
               $video = $this->returnVideo($video);
           }

            $res ['estado'] = 1;
            $res ['videos'] = $allvideo;
            $res ['mensaje'] = "Exito";
            return response()->json($res, 200);


        }catch (ModelNotFoundException $ex) {
            $res['estado'] = 0;
            $res['mensaje'] = "Usuario o contraseña incorrectos";
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
