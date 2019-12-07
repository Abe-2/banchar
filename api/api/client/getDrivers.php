<?php

include_once '../../module/Driver.php';
include_once '../../module/Request.php';
include_once '../../config/Errors.php';

$request = new Driver();

$result = $request->getDrivers();

if ($result === false) {
    output("error", http_response_code());
}

output("ok", ["drivers"=>$result]);
