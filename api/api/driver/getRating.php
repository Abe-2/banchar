<?php

include_once '../../module/Driver.php';
include_once '../../config/Errors.php';

$driver_id = $_GET['driver'];

$user = new Driver();

$user_id = $user->getRating($driver_id);

if ($user_id === false) {
    output("error", http_response_code());
}

output("ok", $user_id);
