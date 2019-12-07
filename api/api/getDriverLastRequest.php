<?php

include_once '../module/Request.php';
include_once '../config/Errors.php';

$driver_id = $_GET['id'];

$request = new Request();

$result = $request->getDriverPrevStatus($driver_id);
$status = $result->status;

if ($result === false) {
    echo Errors::getErrorMsg(http_response_code());
    die;
} else if ($status == 1 || $status == 0) {
    echo json_encode($result);
}else{
    echo 'done';
}
