<?php

include_once '../module/User.php';
include_once '../config/Errors.php';

$email = $_GET['phone'];
$password = $_GET['pass'];

$user = new User();

$user_id = $user->loginClient($email, $password);

if ($user_id === false) {
    output("error", http_response_code());
}

$user_id->img = "http://exabx.com/apps/banchar/images/" . $user_id->img;

output("ok", $user_id);
