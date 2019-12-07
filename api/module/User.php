<?php

include_once __DIR__.'/../config/Database.php';
include_once __DIR__.'/../config/Errors.php';

// you can notice that it is possible to register as both a driver and a client using the same phone number

class User {

    // driver
    function loginDriver($phone, $pass) {
        $sql = "SELECT id, name, email, rating  FROM DRIVER WHERE email = ? AND password = ?";
        $stmt = getConn()->prepare($sql);

        if (!$stmt->execute([$phone, $pass])) {
            http_response_code(500);
            return false;
        }

        if($stmt->rowCount())
            return $stmt->fetchObject();

        // user not found
        http_response_code(403);
        return false;
    }

    public function canRegisterDriver($phone) {
        $sql = "SELECT email FROM DRIVER WHERE email = ?";
        $stmt = getConn()->prepare($sql);
        if(!$stmt->execute([$phone]))
        {
            http_response_code(500);
            return false;
        }
        if(!$stmt->rowCount())
            return true;

        // there is another user with the same phone number
        http_response_code(402);
        return false;
    }

    function registerDriver($name, $phone, $pass) {
        $sql = "INSERT INTO DRIVER(name, email, password) VALUES (?, ?, ?)";
        $stmt = getConn()->prepare($sql);

        if (!$stmt->execute([$name, $phone, $pass])) {
            http_response_code(500);
            return false;
        }

        return self::getDriverInfo(getConn()->lastInsertId());
    }

    public function getDriverInfo($id) {
        $sql = "SELECT id, name, email  FROM DRIVER WHERE id = ?";
        $stmt = getConn()->prepare($sql);
        if(!$stmt->execute([$id]) || !$stmt->rowCount())
        {
            http_response_code(500);
            return false;
        }

        $data = $stmt->fetchObject();

        return $data;
    }

    function getLocation($driver_id) {
        $sql = "SELECT location_x, location_y  FROM DRIVER WHERE id = ?";
        $stmt = getConn()->prepare($sql);
        if(!$stmt->execute([$driver_id])) {
            http_response_code(500);
            return false;
        }

        if (!$stmt->rowCount()) {
            http_response_code(405);
            return false;
        }

        return $stmt->fetchObject();
    }

    function updateDriverLocation($id, $x, $y) {
        $sql = "UPDATE DRIVER
                SET location_x = ?, location_y = ?
                WHERE id = ?";
        $stmt = getConn()->prepare($sql);

        if (!$stmt->execute([$x, $y, $id])) {
            http_response_code(500);
            return false;
        }

        return true;
    }

    // client
    function loginClient($email, $pass) {
        $sql = "SELECT id, name, email, plate_num, car_type, img  FROM CLIENT WHERE email = ? AND password = ?";
        $stmt = getConn()->prepare($sql);

        if (!$stmt->execute([$email, $pass])) {
            http_response_code(500);
            return false;
        }

        if($stmt->rowCount())
            return $stmt->fetchObject();

        // user not found
        http_response_code(403);
        return false;
    }

    public function canRegisterClient($email) {
        $sql = "SELECT email FROM CLIENT WHERE email = ?";
        $stmt = getConn()->prepare($sql);

        if(!$stmt->execute([$email])) {
            http_response_code(500);
            return false;
        }
        if(!$stmt->rowCount())
            return true;

        // there is another user with the same email
        http_response_code(402);
        return false;
    }

//    function registerClient($name, $email, $pass, $plate, $img) {
//        $sql = "INSERT INTO CLIENT(name, email, password, plate_num, img) VALUES (?, ?, ?, ?)";
//        $stmt = getConn()->prepare($sql);
//
//        if (!$stmt->execute([$name, $email, $pass, $plate])) {
//            http_response_code(500);
//            return false;
//        }
//
//        return self::getClientInfo(getConn()->lastInsertId());
//    }

    function registerClient($name, $email, $pass, $plate, $car_type) {
        $dir = "../images/";
        $file_name = randomStr(5).".png";
        while (is_file($dir."/".$file_name))
            $file_name = randomStr(8).".png";
        if(!move_uploaded_file($_FILES['image']['tmp_name'],$dir.$file_name))
        {
            http_response_code(500);
            return false;
        }

        if(!exif_imagetype($dir.$file_name))
        {
            self::delete($dir.$file_name);
//            self::setErrorCode(122);
            http_response_code(122);
            return false;
        }
        if(exif_imagetype($dir.$file_name) == IMAGETYPE_JPEG)
        {
            //convert to png
            $im = @imagecreatefromjpeg($dir.$file_name);
            self::delete($dir.$file_name);
            imagepng($im, $dir.$file_name);
        }
        $im = @imagecreatefrompng($dir.$file_name);
        if(!$im)
        {
            self::delete($dir.$file_name);
//            self::setErrorCode(122);
            http_response_code(122);
            return false;
        }
        $size = getimagesize($dir.$file_name);

        $sql = "INSERT INTO CLIENT(name, email, password, plate_num, car_type, img) VALUES (?, ?, ?, ?, ?, ?)";
        $stmt = getConn()->prepare($sql);

        if (!$stmt->execute([$name, $email, $pass, $plate, $car_type, $file_name])) {
            http_response_code(500);
            return false;
        }

        return self::getClientInfo(getConn()->lastInsertId());
    }

    private static function delete($name) {
        unlink($name);
    }

    public static function getClientInfo($id) {
        $sql = "SELECT id, name, email  FROM CLIENT WHERE id = ?";
        $stmt = getConn()->prepare($sql);
        if(!$stmt->execute([$id]) || !$stmt->rowCount())
        {
            http_response_code(500);
            return false;
        }

        $data = $stmt->fetchObject();

        return $data;
    }

    public function getHistory($client_id) {
        $sql = "SELECT *  FROM REQUEST WHERE client_id = ? AND (status = '2' OR status = '3')"; // only completed ones
        $stmt = getConn()->prepare($sql);

        if(!$stmt->execute([$client_id])) {
            http_response_code(500);
            return false;
        }

        return $stmt->fetchAll();
    }

//    function updateClientLocation($id, $x, $y) {
//        $sql = "UPDATE taxi_app.CLIENT
//                SET location_x = ?, location_y = ?
//                WHERE id = ?";
//        $stmt = getConn()->prepare($sql);
//
//        if (!$stmt->execute([$id, $x, $y])) {
//            http_response_code(500);
//            return false;
//        }
//
//        return true;
//    }

}