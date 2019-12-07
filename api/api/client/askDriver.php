<?php

include_once '../../module/Driver.php';
include_once '../../module/Request.php';
include_once '../../config/Errors.php';

$driver_id = $_GET["driver"];
$request_id = $_GET["request"];

$request = new Driver();

$result = $request->addRequestToDriver($request_id, $driver_id);

if ($result === false) {
    echo Errors::getErrorMsg(http_response_code());
    die;
}

output("ok", ["drivers"=>$result]);