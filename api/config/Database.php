<?php

function getConn()
{
    if(Config::$conn !== null)
        return Config::$conn;

    try{
        Config::$conn = new PDO(
            "mysql:host=localhost;dbname=".Config::DB['name'],
            Config::DB['username'],
            Config::DB['password'],
            Config::DB['config']
        );
    }catch (Exception $e){
        echo ($e->getTraceAsString());
        die;
    }
    return getConn();
}

class Config {
    const DB = [
        'name'=>'banchar',
        'username'=>'banchar-user',
        'password'=>'123456789',
        'config'=>[
            PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC,
            PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci"
        ]
    ];

    /* @var PDO*/
    public static $conn = null;
}

function randomStr($length = 16) {
    $characters = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    $charactersLength = strlen($characters);
    $randomString = '';
    for ($i = 0; $i < $length; $i++) {
        $randomString .= $characters[rand(0, $charactersLength - 1)];
    }
    return $randomString;
}

function output($status,$data = [])
{
//    debug_print_backtrace();
//    if(Config::DEBUG && $status != 'ok')
//        debug_print_backtrace();
    $output_data = [
        'status' => $status
    ];
    if(is_array($data) && isset($data['message']))
    {
        if(Errors::exists($data['message']))
            $output_data['message'] = Errors::getErrorMsg($data['message']);
        else
            $output_data['message'] = $data['message'];
    }else if(is_array($data) && isset($data['payload']))
        $output_data['payload'] = $data['payload'];
    else if($status == 'ok')
    {
        $output_data['payload'] = $data;
    }else if($status == "error")
    {
        $output_data['message'] = Errors::getErrorMsg($data);
    }
    echo json_encode($output_data);
    die;
}