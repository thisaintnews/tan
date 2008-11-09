<?php
require_once("user.php");

class page{
     
    static $output;   

    function __construct(){
        $user = new user();
    }

    function createMenu($where, $type){
        $selclass = ' mainselected';
        $subclass = ' subselected';
        
	    $linkmenu = null;
 	    $picturemenu = null;
	    $blogmenu = null;

        if ($where == 'link'){
            $menu = & $linkmenu;
            $lselected = & $selclass;
            if ($type === 0){$plink = & $subclass;}
            if ($type === 1){$ulink = & $subclass;}
            $lnav = " lnav";
        }
        if ($where == 'picture'){
            $menu = & $picturemenu;
            $pselected = & $selclass;
            if ($type === 0){$ppic = & $subclass;}
            if ($type === 1){$upic = & $subclass;}
            $pnav = " pnav";
        }
        if ($where == 'blog'){
            $menu = & $blogmenu;
            $bselected = & $selclass;
            if ($type === 0){$pblog = & $subclass;}
            if ($type === 1){$ublog = & $subclass;}
            $bnav = " bnav";
        }
        if ($where == 'submit'){
            if ($type === 0){
                $lselected = & $selclass;
                $menu = & $linkmenu;
                $lsub = & $subclass;
            }
            if ($type === 1){
                $pselected = & $selclass;
                $menu = & $picturemenu;
                $psub = & $subclass;
            }
            if ($type === 2){
                $bselected = & $selclass;            
                $menu = & $blogmenu;
                $bsub = & $subclass;
            }
        }

//        $allmenu = "<a href='/random/all/' class='nav anav'>Random</a>
//            <a href='/all/0/1/' class='nav anav'>Promoted</a> 
//            <a href='/all/1/1/' class='nav anav'>Upcoming</a>";

        $blogmenu = "<a href='/submit/blog/' class='nav bnav $bsub'>Submit</a><br/>
            <a href='/random/blog/' class='nav bnav'>Random</a><br/>
            <a href='/blog/0/1/' class='nav  bnav $pblog'>Promoted</a><br/>
            <a href='/blog/1/1/' class='nav bnav $ublog'>Upcoming</a>";

        $picturemenu = "<a href='/submit/picture/' class='nav pnav $psub'>Submit</a><br/>
            <a href='/random/picture/' class='nav pnav'>Random</a><br/>
            <a href='/picture/0/1/' class='nav pnav $ppic'>Promoted</a><br/>
            <a href='/picture/1/1/' class='nav pnav $upic'>Upcoming</a>";

        $linkmenu = "<a href='/submit/link/' class='nav lnav $lsub'>Submit</a><br/>
            <a href='/random/link/' class='nav lnav'>Random</a><br/>
            <a href='/link/0/1/' class='nav lnav $plink'>Promoted</a><br/> 
            <a href='/link/1/1/' class='nav lnav $ulink'>Upcoming</a>";

        $mainmenu = //"<div style='display:none' id='allmenu'>$allmenu</div>
            "<div style='display:none' id='blogmenu'>$blogmenu</div>
            <div style='display:none' id='picturemenu'>$picturemenu</div>
            <div style='display:none' id='linkmenu'>$linkmenu</div>
            <div style='height:60px;float:right;text-align:right;'>";
//            <a href='#' onclick=\"changeMenu('all')\" id='alllink' class='nav anav $aselected'>All</a>

        $mainmenu .= "<a href='#' onclick=\"changeMenu('link');return false;\" id='linklink' class='nav lnav $lselected'>Links</a>"
            . "<a href='#' onclick=\"changeMenu('blog');return false;\" id='bloglink' class='nav bnav $bselected'>Blogs</a>"
            . "<a href='#' onclick=\"changeMenu('picture');return false;\" id='picturelink' class='nav pnav $pselected'>Pictures</a>"
            . "<span id='menuholder' class='$lnav $pnav $bnav'>$menu</span></div>";

        return $mainmenu;
}

    private function createHead($title, $script){
        $this->output = "<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN'
            'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'>
            <html xmlns='http://www.w3.org/1999/xhtml'>
            <head>
            <title>$title</title>
            <meta name='Description' content='We&#039;re the newest social news site. Ran by the community, for the community, no corporations involved.'/>
            <meta name='keywords' content='news community comments english lulz lol social lulzhq fun jokes 
            videos pictures share sharing lol lolz funny humour humur'/>
            <meta http-equiv='Content-Type' content='text/html; charset=utf-8'/>
            <link rel='stylesheet' type='text/css' title='default' href='/css/default.css' />
            <link rel='shortcut icon' href='/favicon.ico' />
            <script type='text/javascript' src='/sys/js/clientside.js'></script>
            $script
            </head>";
    }
    
    private function createBody($where, $type, $sortby = null){
        $user = new user();
        $this->output .= "<body>
            <div id='main'>
<div id='right_menu'><div id='menu_holder'>" .$this->createMenu($where, $type) ."</div>$sortby</div>
<div id='those_damn_dirty_evil_ads'><!-- Begin: AdBrite, Generated: 2008-11-09 10:41:42  -->
<script type=\"text/javascript\">
var AdBrite_Title_Color = 'FFFFFF';
var AdBrite_Text_Color = 'EEEEEE';
var AdBrite_Background_Color = '888888';
var AdBrite_Border_Color = '555555';
var AdBrite_URL_Color = 'DDDDDD';
try{var AdBrite_Iframe=window.top!=window.self?2:1;var AdBrite_Referrer=document.referrer==''?document.location:document.referrer;AdBrite_Referrer=encodeURIComponent(AdBrite_Referrer);}catch(e){var AdBrite_Iframe='';var AdBrite_Referrer='';}
</script>
<script type=\"text/javascript\">document.write(String.fromCharCode(60,83,67,82,73,80,84));document.write(' src=\"http://ads.adbrite.com/mb/text_group.php?sid=917367&amp;zs=3136305f363030&amp;ifr='+AdBrite_Iframe+'&amp;ref='+AdBrite_Referrer+'\" type=\"text/javascript\">');document.write(String.fromCharCode(60,47,83,67,82,73,80,84,62));</script>
<div><a target=\"_top\" href=\"http://www.adbrite.com/mb/commerce/purchase_form.php?opid=917367&amp;afsid=1\" style=\"font-weight:bold;font-family:Arial;font-size:13px;\"></a></div>
<!-- End: AdBrite --></div>
            <div id='top'>
<div style='float:right;margin-top:25px;margin-right:5px;text-align:right;'>";
        if ($user->isLoggedIn()){
            $this->output .= "<a href='/users/".urlencode($user->getUserName())."/plus/1' class='menulink'>Profile</a> | ";
        } else {
            $this->output .= "<a href='/login/' class='menulink'>Login/Register</a> | ";
        }

/*        if($_SESSION['filteroff']== 1){
            $this->output .="<a href='/filteron' class='menulink'>Enable NSFW filter</a> | ";
        } else {
            $this->output .="<a href='/filteroff' class='menulink'>Disable NSFW filter</a> | ";
        }*/
        $this->output .= "<a href='/shop/' class='menulink'>Shop</a> |
            <a href='/chat/' class='menulink'>Chat</a> | 
            <a href='/tagcloud/' class='menulink'>Tag Cloud</a>";

        if ($user->isLoggedIn()){
            $this->output .= " | <a href='/logout/' class='menulink'>Logout</a>";
        }
        $this->output .= " </div>
            <div class='logoimg'/><a href='/' class='logo'></a></div>";
        $this->output .= "</div><div id='middle'>"; 
    }

    private function closePage($footer){
        $this->output .= "<div id='bottom'>
            <a href=\"http://validator.w3.org/check?uri=referer\">
            <img src=\"http://www.w3.org/Icons/valid-xhtml10\"
            style='height:31px;width:88px;margin-top:20px;float:right;'
            alt=\"Valid XHTML 1.0 Transitional\" /></a><br/><br/>
            <span style='display:block;margin-bottom:10px;'>$footer, All User-generated content is licensed under a <a href='http://creativecommons.org/'>Creative Commons Public Domain license</a></span>
            </div></div>
            <script src=\"http://www.google-analytics.com/ga.js\" type=\"text/javascript\"></script>
            <script type=\"text/javascript\">
            var pageTracker = _gat._getTracker(\"UA-5148406-3\");
            pageTracker._initData();
            pageTracker._trackPageview();
            </script>
            </body></html>";
    }

    public function createPage($title,$header, $middle, $footer, $where, $type = -1, $sortby = null){
        if ($_SESSION['filteroff']== 0) {
        //     $middle = $this->sfw($middle); 
         //    $title = $this->sfw($title); 
        }
        $this->createHead($title, $header);
        $this->createBody($where, $type, $sortby);
        $this->output .= $middle;
        $this->closePage($footer);
        return $this->output;
    }

    public function minify($code, $js=0){
        if ($js){
            $code = preg_replace(array("/(^[\/]{2}[^\n]*)|([\n]{1,}[\/]{2}[^\n]*)/"), ' ', $code);
        }
        return preg_replace(array("/\r/", "/\t/", "/\n/", "/\s+\ /"), ' ', $code);
    }

    public function compress($data){
        if(strstr($_SERVER['HTTP_ACCEPT_ENCODING'],'gzip')){
            ob_start();
            echo $data;
            $data=gzencode(ob_get_contents(),9);
            ob_end_clean();
            header('Content-Encoding: gzip');
        }
        return $data;
    }
    
    public function sfw($content){
        $search = array('/(f)[u](ck)/i', '/(sh)[i](t)/i', '/(c)[o](ck)/i', '/(b)[o](llocks)/i', '/(c)[u](nt)/i', '/(n)[i](gger)/i', '/(p)[a](ki)/i', '/(b)[a](stard)/i', '/(f)[a](g)/i', '/(f)[a](ggot)/i', '/(p)[i](ss)/i');
        return preg_replace($search, '$1*$2', $content);
    }
}
?>
