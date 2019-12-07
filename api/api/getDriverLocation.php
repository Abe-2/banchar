<?php

include_once '../module/User.php';
include_once '../config/Errors.php';

$driver_id = $_GET['id'];

$user = new User();

$location = $user->getLocation($driver_id);

if ($location === false) {
    echo Errors::getErrorMsg(http_response_code());
    die;
}

echo json_encode($location);
