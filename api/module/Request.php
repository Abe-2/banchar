<?php

include_once __DIR__.'/../config/Database.php';
include_once __DIR__.'/../config/Errors.php';

class Request {

    // TODO: not needed
    public function getPrevStatus($user_id) {
        $sql = "SELECT status, id, driver_id, pickup_x, pickup_y
                FROM REQUEST
                WHERE client_id = ?
                order by id desc
                limit 1";
        $stmt = getConn()->prepare($sql);

        if(!$stmt->execute([$user_id])){
            http_response_code(500);
            return false;
        }

        if (!$stmt->rowCount()) {
            http_response_code(401);
            return false;
        }

        return $stmt->fetchObject();
    }

//    public function getLastRequest($user_id) {
//        $sql = "SELECT id, dest_x, dest_y, fare, driver_id, type, pickup_x, pickup_y
//                FROM REQUEST
//                WHERE client_id = ?
//                order by id desc
//                limit 1";
//        $stmt = getConn()->prepare($sql);
//
//        if(!$stmt->execute([$user_id])){
//            http_response_code(500);
//            return false;
//        }
//
//        if (!$stmt->rowCount()) {
//            http_response_code(401);
//            return false;
//        }
//
//        return $stmt->fetchObject();
//    }

    public function getDriverPrevStatus($user_id) {
        $sql = "SELECT status, id, driver_id, pickup_x, pickup_y
                FROM REQUEST
                WHERE driver_id = ?
                order by id desc
                limit 1";
        $stmt = getConn()->prepare($sql);

        if(!$stmt->execute([$user_id])){
            http_response_code(500);
            return false;
        }

        if (!$stmt->rowCount()) {
            http_response_code(401);
            return false;
        }

        return $stmt->fetchObject();
    }

    function getStatus($request_id) {
        $sql = "SELECT status
                FROM REQUEST
                WHERE id = ?";
        $stmt = getConn()->prepare($sql);

        if(!$stmt->execute([$request_id])){
            http_response_code(500);
            return false;
        }

        if (!$stmt->rowCount()) {
            http_response_code(404);
            return false;
        }

        return $stmt->fetchObject()->status;
    }

    function getDriverForRequest($request_id) {
        $sql = "SELECT driver_id
                FROM REQUEST
                WHERE id = ?";
        $stmt = getConn()->prepare($sql);

        if(!$stmt->execute([$request_id])){
            http_response_code(500);
            return false;
        }

        if (!$stmt->rowCount()) {
            http_response_code(404);
            return false;
        }

        return $stmt->fetchObject();
    }

    public function cancelLast($id) {
        $sql = "UPDATE REQUEST
                SET status = '3'
                WHERE client_id = ?
                ORDER BY id desc
                LIMIT 1";
        $stmt = getConn()->prepare($sql);

        if (!$stmt->execute([$id])) {
            http_response_code(500);
            return false;
        }

        return true;
    }

    public function insertNew($id, $pick_x, $pick_y, $car, $plate, $img, $desc) {
        $sql = "INSERT INTO REQUEST(client_id, pickup_x, pickup_y, car_type, plate_num, img, description, date) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        $stmt = getConn()->prepare($sql);

        if (!$stmt->execute([$id, $pick_x, $pick_y, $car, $plate, $img, $desc, date("F j, Y", time())])) {
            http_response_code(500);
            return false;
        }

        return getConn()->lastInsertId();
    }

    // removed driver_id from select
    function checkRequest($request_id) {
        $sql = "SELECT status
                FROM REQUEST
                WHERE id = ?";
        $stmt = getConn()->prepare($sql);

        if (!$stmt->execute([$request_id])) {
            http_response_code(500);
            return false;
        }

        return $stmt->fetchObject();
    }

    // TODO: not needed
    function getRequests($type) {
        $sql = "SELECT id, pickup_x, pickup_y
                FROM REQUEST
                WHERE status = '0'";
        $stmt = getConn()->prepare($sql);

        if (!$stmt->execute([$type])) {
            http_response_code(500);
            return false;
        }

        return $stmt->fetchAll();
    }

    public function accept($id, $request) {
        $sql = "UPDATE REQUEST
                SET status = '1', driver_id = ?
                WHERE id = ?";
        $stmt = getConn()->prepare($sql);

        if (!$stmt->execute([$id, $request])) {
            http_response_code(500);
            return false;
        }

        return true;
    }

//    public function decline($request_id) {
//        $sql = "UPDATE REQUEST
//                SET status = '4'
//                WHERE id = ?";
//        $stmt = getConn()->prepare($sql);
//
//        if (!$stmt->execute([$request_id])) {
//            http_response_code(500);
//            return false;
//        }
//
//        return true;
//    }

    public static function decline($request_id, $driver_id) {

        getConn()->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        try {
            getConn()->beginTransaction();

            $sql = "UPDATE REQUEST
                SET status = '4'
                WHERE id = ?";
            $stmt = getConn()->prepare($sql);
            $stmt->execute([$request_id]);

            $sql = "UPDATE DRIVER
                SET current_request = NULL
                WHERE id = ?";
            $stmt = getConn()->prepare($sql);

            $stmt->execute([$driver_id]);

            getConn()->commit();
        } catch (Exception $e) {
            getConn()->rollback();
            http_response_code(500);
            return false;
        }

        getConn()->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_SILENT);

        return true;
    }

    function endRide($id) {
        $sql = "UPDATE REQUEST
                SET status = '2'
                WHERE id = ?";
        $stmt = getConn()->prepare($sql);

        if (!$stmt->execute([$id])) {
            http_response_code(500);
            return false;
        }

        return true;
    }

    function cancelRide($request_id) {
        $sql = "UPDATE REQUEST
                SET status = '3'
                WHERE id = ?";
        $stmt = getConn()->prepare($sql);

        if (!$stmt->execute([$request_id])) {
            http_response_code(500);
            return false;
        }

        return true;
    }

    function getRequestDetails($request_id) {
        $sql = "SELECT *
                FROM REQUEST
                WHERE id = ?";
        $stmt = getConn()->prepare($sql);

        if (!$stmt->execute([$request_id])) {
            http_response_code(500);
            return false;
        }

        if (!$stmt->rowCount()) {
            http_response_code(404);
            return false;
        }

        return $stmt->fetchObject();
    }
}