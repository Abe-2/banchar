<?php

include_once '../../module/Request.php';
include_once '../../config/Errors.php';

$driver_id = $_GET['id'];
$request_id = $_GET['request'];

$request = new Request();

$request_status = $request->checkRequest($request_id)->status;

if ($request_status === false) {
    output("error", http_response_code());
}

if ($request_status == 4) {
    output("error", "request already declined");
}else if ($request_status == 2 || $request_status == 3) {
    output("error", "request not available anymore");
}else if ($request_status == 1) {
    output("error", "request already accepted");
}

// else
$accepted = $request->decline($request_id, $driver_id);

if (!$accepted) {
    output("error", "error in declining request");
}



//if all is fine
output("ok", null);


