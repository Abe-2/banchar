<?php

include_once '../module/Request.php';
include_once '../config/Errors.php';

$request_id = $_GET['r'];

$request = new Request();

$status = $request->getStatus($request_id);

if ($status === false) {
    output("error", 500);
} else if ($status === '0' || $status === '4') { // a request can only be canceled if it has not been accepted yet
    $result = $request->cancelRide($request_id);

    if ($result === false) {
        output("error", 500);
    }

    $result = $request->cancelRide($request_id);

    if ($result === false) {
        output("error", 500);
    }

    output("ok", null);

} else if ($status === '1') {
    output("error", 408);
} else if ($status === '2' || $status === '3') {
    output("error", 409);
}
