<?php

include_once '../module/Request.php';
include_once '../config/Errors.php';

$client_id = $_GET['id'];

$request = new Request();

$result = $request->getPrevStatus($client_id);
$status = $result->status;

if ($result === false) {
    echo Errors::getErrorMsg(http_response_code());
    die;
} else if ($status == 1 || $status == 0) {
//    $updated = $request->getLastRequest($client_id);
    echo json_encode($result);
}else{
    echo 'done';
}
