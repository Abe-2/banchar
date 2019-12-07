<?php

include_once __DIR__.'/../config/Database.php';
include_once __DIR__.'/../config/Errors.php';

class Driver {

    function getDrivers() {
        $sql = "SELECT id, name, email, rating, location_x, location_y, raters FROM DRIVER";
        $stmt = getConn()->prepare($sql);

        if (!$stmt->execute([])) {
            http_response_code(500);
            return false;
        }

        return $stmt->fetchAll();
    }

    function addRequestToDriver($request_id, $driver_id) {
        $sql = "UPDATE DRIVER
                SET current_request = ?
                WHERE id = ?";
        $stmt = getConn()->prepare($sql);

        if (!$stmt->execute([$request_id, $driver_id])) {
            http_response_code(500);
            return false;
        }

        return $stmt->fetchAll();
    }

    function updateRating($driver_id, $new_rating, $new_raters) {
        $sql = "UPDATE DRIVER
                SET rating = ?, raters = ?
                WHERE id = ?";
        $stmt = getConn()->prepare($sql);

        if (!$stmt->execute([$new_rating, $new_raters, $driver_id])) {
            http_response_code(500);
            return false;
        }

        return $stmt->fetchAll();
    }

    function getRating($driver_id) {
        $sql = "SELECT rating, raters FROM DRIVER WHERE id = ?";
        $stmt = getConn()->prepare($sql);

        if (!$stmt->execute([$driver_id])) {
            http_response_code(500);
            return false;
        }

        return $stmt->fetchObject();
    }

    function getRequest($driver_id) {
        $sql = "SELECT current_request FROM DRIVER WHERE id = ?";
        $stmt = getConn()->prepare($sql);

        if (!$stmt->execute([$driver_id])) {
            http_response_code(500);
            return false;
        }

        $request = $stmt->fetchObject()->current_request;
        if ($request === null) {
            http_response_code(406);
            return false;
        }

        return $request;
    }

}