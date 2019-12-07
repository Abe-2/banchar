<?php

class Errors{

    private static $_Errors = [

        '1' => 'missing parameters',

        '401'=> 'No requests for the specified user',
        '402'=> 'Duplicate email',
        '403'=> 'User not found',
        '404'=> 'Request not found',
        '405'=> 'Driver not found',
        '406'=> 'No request for driver',
        '407'=> 'cant make new request while there is an accepted request',
        '408'=> 'cant cancel accepted request',
        '409'=> 'request either completed or already canceled',
        '410'=> 'request already taken',
        '411'=> 'request not available anymore',

        '500'=> 'internal_error',
        '501'=> 'missing_method',
        'unk'=> 'unknown_error'
    ];

    static function exists($code)
    {
        return isset(self::$_Errors[$code]);
    }

    static function getErrorMsg($error)
    {
        if(isset(self::$_Errors[$error]))
            return self::$_Errors[$error];
        else
            return self::$_Errors['unk'];
    }
}