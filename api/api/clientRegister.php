<?php

include_once '../module/User.php';
include_once '../config/Errors.php';

$name = $_GET['name'];
$email = $_GET['phone']; // needs change
$password = $_GET['pass'];
$plate = $_GET['plate'];
$car_type = $_GET['car'];

if(!isset($_FILES['image']))
    output('error',2);

$user = new User();

$allow = $user->canRegisterClient($email);

if ($allow === false) {
    output("error", http_response_code());
}

$allow = $user->canRegisterDriver($email);

if ($allow === false) {
    output("error", http_response_code());
}

$user_details = $user->registerClient($name, $email, $password, $plate, $car_type);

if ($user_details === false) {
    output("error", http_response_code());
}

output("ok", ["userDetails"=>$user_details]);