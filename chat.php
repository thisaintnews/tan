<?php
require_once('code/header.php');

require_once("code/user.php");
$user = new user();
$title = 'webchat';

$uname = $user->getUserName();
if ($uname == ''){
    $uname = 'n00b';
} 

$middle .= '<div style="text-align:center;">
    <iframe width=720 height=400 scrolling=no style="border:0" 
    src="http://embed.mibbit.com/?server=irc.abjects.net
    &chatOutputShowTimes=true
    &channel=%23thisaintnews&settings=8a8a5ac18a22e7eecd04026233c3df93t&nick='.$uname.'">
    </iframe></div>';

require_once('code/footer.php');
?>