package TAN::View::Template::Classic::Lib::Editor;

use base 'Catalyst::View::Perl::Template';

my $iPhone_reg = qr/iPhone/;
my $Android_reg = qr/Android/;
sub process{
    my ( $self, $c, $editor ) = @_;

    my $edheight = defined($editor->{'height'}) ? $editor->{'height'} : '300px';
    my $edwidth = defined($editor->{'width'}) ? $editor->{'width'} : '100%';
    my $edname = defined($editor->{'name'}) ? $editor->{'name'} : 'editor';

    my ( $required, $min_length, $max_length );

    $required = defined( $editor->{'required'} ) && 'required';
    if ( defined( $editor->{'length'} ) ){
        $min_length = defined( $editor->{'length'}->{'min'} ) && 'minLength:' . $editor->{'length'}->{'min'};
        $max_length = defined( $editor->{'length'}->{'max'} ) && 'maxLength:' . $editor->{'length'}->{'max'};
    }

    my $out = qq\
        <textarea
            class="${edname} ${required} ${min_length} ${max_length} wysiwyg msgPos:wysiwygAdvice"
            style="height:${edheight};width:${edwidth}"
            id="${edname}"
            name="${edname}"
            rows="80"
            cols="20"
        >@{[ 
            $c->view->html($editor->{'value'}) || '' 
        ]}</textarea>
        <div id="wysiwygAdvice"></div>\;

    if ( 
        ( $c->req->user_agent =~ /${iPhone_reg}/ ) 
        || ( $c->req->user_agent =~ /${Android_reg}/ )
    ){
    #tinymce isn't compatable with iPhone or Android
        #remove comment from js since comment.js references tinymce
        my @js_includes;
        foreach my $js_include ( @{ $c->stash->{'js_includes'} } ){
            if ( $js_include ne 'comment' ){
                push( @js_includes, $js_include );
            }
        }
        $c->stash->{'js_includes'} = \@js_includes;
        return $out;
    }

    push(@{$c->stash->{'js_includes'}}, '/static/tiny_mce/tiny_mce.js?r=10');
    push(@{$c->stash->{'js_includes'}}, 'tiny-mce-config');

    return qq\
        ${out}
        <script type="text/javascript">
        //<![CDATA[
            if ( typeof( tiny_mce_config ) == 'undefined' ){
                var tiny_mce_config = {};
            }

            window.addEvent( 'domready', function(){
                tiny_mce_config['width'] = "${edwidth}";
                tiny_mce_config['height'] = "${edheight}";
                tiny_mce_config['editor_selector'] = "${edname}";
                tiny_mce_config['content_css'] = "@{[ $c->stash->{'theme_settings'}->{'css_path'} ]}/editor.css?r=1";

                tinyMCE.init( tiny_mce_config );
            } );
        //]]>
        </script>\;
}

1;
