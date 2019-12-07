<?php

include_once '../module/User.php';
include_once '../config/Errors.php';

$email = $_GET['phone']; // change here
$password = $_GET['pass'];

$user = new User();

$user_id = $user->loginDriver($email, $password);

if ($user_id === false) {
    output("error", http_response_code());
}

output("ok", $user_id);
