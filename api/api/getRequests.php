<?php

include_once '../module/Request.php';
include_once '../config/Errors.php';

$requests_type = $_GET['id'];

$request = new Request();

$result = $request->getRequests($requests_type);

if ($result === false) {
    echo Errors::getErrorMsg(http_response_code());
    die;
}

echo json_encode($result);

// TODO: remove this method as it is not needed
