<?php

include_once '../module/Request.php';
include_once '../config/Errors.php';

if (!isset($_GET['id']) || !isset($_GET['r'])) {
    echo Errors::getErrorMsg(1);
    die;
}

$driver_id = $_GET['id'];
$request_id = $_GET['r'];

$request = new Request();

$request_status = $request->checkRequest($request_id)->status;

if ($request_status === false) {
    output("error", 500);
}

if ($request_status == 1) {
    output("error", 410);
}else if ($request_status == 2 || $request_status == 3) {
    output("error", 411);
}

$accepted = $request->accept($driver_id, $request_id);

if (!$accepted) {
    output("error", 500);
}

output("ok", null);

