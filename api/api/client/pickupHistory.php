<?php

include_once '../../module/User.php';
include_once '../../config/Errors.php';

$client_id = $_GET['client'];

$user = new User();

$result = $user->getHistory($client_id);

if ($result === false) {
    output("error", http_response_code());
}

output("ok", ["requests"=>$result]);