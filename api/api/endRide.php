<?php

include_once '../module/User.php';
include_once '../module/Request.php';
include_once '../config/Errors.php';

$request_id = $_GET['r'];

$request = new Request();

$status = $request->getStatus($request_id);

if ($status === false) {
    output("error", 500);
} else if ($status === '1') {
    $result = $request->endRide($request_id);

    if ($result === false) {
        output("error", 500);
    }

    output("ok", null);

} else { // the ride is either already complete, still not accepted, or canceled
    output("error", 409);
}
