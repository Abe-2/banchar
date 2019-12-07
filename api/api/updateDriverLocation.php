<?php

include_once '../module/User.php';
include_once '../config/Errors.php';

$driver_id = $_GET['id'];
$loc_x = $_GET['x'];
$loc_y = $_GET['y'];

$user = new User();

$updated = $user->updateDriverLocation($driver_id, $loc_x, $loc_y);

if ($updated === false) {
    echo Errors::getErrorMsg(http_response_code());
    die;
}

echo "ok";
