<?php

include_once '../module/Request.php';
include_once '../config/Errors.php';

$request_id = $_GET['id'];

$request = new Request();

$result = $request->checkRequest($request_id);

if ($result === false) {
    output("error", http_response_code());
}

if ($result->status != 1) {
    $result->driver_id = '0';
}

output("ok", $result);
