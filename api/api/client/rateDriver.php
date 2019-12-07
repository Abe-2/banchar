<?php

include_once '../../module/Driver.php';
include_once '../../config/Errors.php';

$driver_id = $_GET['driver'];
$new_rating = $_GET['rating'];
$new_raters = $_GET['raters'];

$user = new Driver();

$user_id = $user->updateRating($driver_id, $new_rating, $new_raters);

if ($user_id === false) {
    output("error", http_response_code());
}

output("ok", null);
