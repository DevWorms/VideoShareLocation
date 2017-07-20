<?php

namespace App\Console\Commands;

use App\Video;
use Carbon\Carbon;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Storage;

class RubVideoCom extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'rub:video';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'elimina video';

    /**
     * Create a new command instance.
     *
     * @return void
     */
    public function __construct()
    {
        parent::__construct();
    }

    /**
     * Execute the console command.
     *
     * @return mixed
     */
    public function handle()
    {
        $hourmin= Carbon:: now()->subHours(3);

        $videos= Video::where("created_at","<=",$hourmin)->get();
        //Storage::delete($videos->pluck("ruta"));
        foreach ($videos as $video) {
            Storage::delete($video->ruta);
        }
        Video::where("created_at","<=",$hourmin)->delete();

    }
}
