<?php
/**
 * Created by PhpStorm.
 * User: user
 * Date: 18/07/2017
 * Time: 06:33 PM
 */
namespace App\traits;

trait LocationTriat {
    public function getBoundaries($lat, $lng, $distance = 5, $earthRadius = 6371) {
        $return = array();
        // Los angulos para cada dirección
        $cardinalCoords = array('north' => '0',
            'south' => '180',
            'east' => '90',
            'west' => '270');
        $rLat = deg2rad($lat);
        $rLng = deg2rad($lng);
        $rAngDist = $distance/$earthRadius;
        foreach ($cardinalCoords as $name => $angle) {
            $rAngle = deg2rad($angle);
            $rLatB = asin(sin($rLat) * cos($rAngDist) + cos($rLat) * sin($rAngDist) * cos($rAngle));
            $rLonB = $rLng + atan2(sin($rAngle) * sin($rAngDist) * cos($rLat), cos($rAngDist) - sin($rLat) * sin($rLatB));
            $return[$name] = array('lat' => (float) rad2deg($rLatB),
                'lng' => (float) rad2deg($rLonB));
        }
        return array('min_lat'  => $return['south']['lat'],
            'max_lat' => $return['north']['lat'],
            'min_lng' => $return['west']['lng'],
            'max_lng' => $return['east']['lng']);
    }
}