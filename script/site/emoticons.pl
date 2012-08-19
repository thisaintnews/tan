#!/usr/bin/perl
use strict;
use warnings;

=head1 synopsis
makes a html file for the emoticons tiny-mce plugin
=cut

my $header = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<title>{#emotions_dlg.title}</title>
	<script type="text/javascript" src="../../tiny_mce_popup.js"></script>
	<script type="text/javascript" src="js/emotions.js"></script>
</head>
<body style="display: none" role="application" aria-labelledby="app_title">
<span style="display:none;" id="app_title">{#emotions_dlg.title}</span>
<div align="center">
	<div class="title">{#emotions_dlg.title}:<br /><br /></div>

	<table id="emoticon_table" role="presentation" border="0" cellspacing="0" cellpadding="4">';

my $footer = "</table>
    <div>{#emotions_dlg.usage}</div>
    </div>
    </body>
    </html>";

my @smilies = <../../root/static/smilies/*>;
open(OUT_FILE, '>../../root/static/tiny_mce/plugins/emotions/emotions.htm');

#patches the smiley js so that it looks where we tell it
# could be considererd a hack, gets the job done though
my $patch_file = '../../root/static/tiny_mce/plugins/emotions/js/emotions.js';
my $patch_command = "sed -i -e \"s/tinyMCEPopup\\.getWindowArg('plugin_url') + '\\/img\\/' + //\" ${patch_file}";
`$patch_command`;

my $patch_popup_size = '../../root/static/tiny_mce/plugins/emotions/editor_plugin.js';
#width and height are hacked, lookup proper values in js
my $patch_poppup_command0 = "sed -i -e \"s/width:250/width:650/\" ${patch_popup_size}";
my $patch_poppup_command1 = "sed -i -e \"s/height:160/height:325/\" ${patch_popup_size}";
`$patch_poppup_command0`;
`$patch_poppup_command1`;


my $i = 0;
my $middle;
my $columns = 14;

foreach my $smiley (@smilies){
    if ( !($i % $columns) ){
        $middle .= "<tr>";
        $i = 0;
    }

    $smiley =~ s/^.*\///;
    my $name = $smiley;
    $name =~ s/\..*?$//;
    $smiley = "/static/smilies/${smiley}";

    $middle .= qq|<td><a class="emoticon_link" role="button" title="{#emotions_dlg.${name}}. {#emotions_dlg.usage}" href="javascript:EmotionsDialog.insert('${smiley}','emotions_dlg.${name}');"><img src="${smiley}" border="0" alt="{#emotions_dlg.${name}}. {#emotions_dlg.usage}" /></a></td>|;

    if ( ($i > 0) && !($i % $columns) ){
        $middle .= "</tr>";
    }
    ++$i;
}

if ( ($i > 0) && ($i % $columns) ){
    $middle .= "</tr>";
}

print(OUT_FILE $header . $middle . $footer);
close(OUT_FILE);
