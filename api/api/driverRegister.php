<?php

include_once '../module/User.php';
include_once '../config/Errors.php';

$name = $_GET['name'];
$email = $_GET['phone']; // TODO
$password = $_GET['pass'];
//$type = $_GET['type']; // TODO

$user = new User();

$allow = $user->canRegisterDriver($email);

if ($allow === false) {
    output("error", http_response_code());
}

$allow = $user->canRegisterClient($email);

if ($allow === false) {
    output("error", http_response_code());
}

$user_details = $user->registerDriver($name, $email, $password);

if ($user_details === false) {
    output("error", http_response_code());
}

output("ok", $user_details);