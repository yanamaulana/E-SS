<?php
defined('BASEPATH') or exit('No direct script access allowed');

/*
| -------------------------------------------------------------------
|  Email Configuration
| -------------------------------------------------------------------
| This file contains the configuration settings for the Email class.
|
*/

$config['protocol'] = 'smtp';
$config['smtp_host'] = 'mail.samick.co.id';
$config['smtp_port'] = 465;
$config['smtp_user'] = 'personalia@samick.co.id';
$config['smtp_pass'] = '2019Personalia**123';
$config['smtp_crypto'] = 'ssl';
$config['smtp_timeout'] = 30;
$config['mailtype'] = 'html';
$config['charset'] = 'utf-8';
$config['wordwrap'] = TRUE;
$config['newline'] = "\r\n";
$config['crlf'] = "\r\n";
