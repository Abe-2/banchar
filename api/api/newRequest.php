<?php

include_once '../module/Request.php';
include_once '../config/Errors.php';

$client_id = $_GET['id'];
//$dest_x = $_GET['dest_x']; // client destination location longitude // TODO: remove
//$dest_y = $_GET['dest_y']; // client destination location latitude // TODO: remove
$pick_x = $_GET['pick_x'];
$pick_y = $_GET['pick_y'];
//$fare = $_GET['fare']; // TODO: remove
//$type = $_GET['type']; // TODO: remove
$car = $_GET['car'];
$plate = $_GET['plate'];
$img = $_GET['img'];
$desc = $_GET['desc'];

// initialize object
$request = new Request();

$prev_status = $request->getPrevStatus($client_id)->status;

//echo json_encode($prev_status);

if ($prev_status === false && http_response_code() == 500) {
    output("error", http_response_code());
}

if ($prev_status == 1) {
    output("error", 407);
}else if ($prev_status == 0) {
    $request->cancelLast($client_id);
}

$added = $request->insertNew($client_id, $pick_x, $pick_y, $car, $plate, $img, $desc);

if (!$added) {
    output("error", 500);
}

//if all is fine
output("ok", ['requestID'=>$added]);
