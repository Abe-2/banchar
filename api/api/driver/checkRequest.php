<?php

include_once '../../module/Request.php';
include_once '../../module/Driver.php';
include_once '../../config/Errors.php';

$driver_id = $_GET['driver'];

$driver = new Driver();

$result = $driver->getRequest($driver_id);

if ($result === false && http_response_code() == 500) {
    output("error", http_response_code());
}else if ($result === false && http_response_code() == 406) {
    output("ok", null);
}

$request = new Request();

$details = $request->getRequestDetails($result);

if ($details === false) {
    output("error", http_response_code());
}

//$details->img = "http://exabx.com/apps/banchar/images/" . $details->img;

output("ok", ["request"=>$details]);
