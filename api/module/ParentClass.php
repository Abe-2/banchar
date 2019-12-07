<?php


class ParentClass
{
    static $ErrorCode = 0;
    public static function getErrorCode()
    {
        return self::$ErrorCode;
    }
    public static function setErrorCode($code)
    {
        self::$ErrorCode = $code;
    }
}