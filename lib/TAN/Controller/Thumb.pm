package TAN::Controller::Thumb;
use strict;
use warnings;

use parent 'Catalyst::Controller';

use File::Path qw/mkpath/;

=head1 NAME

TAN::Controller::Thumb

=head1 DESCRIPTION

Gets an image and resizes it

Webserver rule means should only be called if thumb doesn't exist in the filesystem already

=head1 EXAMPLE

I</static/cache/thumbs/$mod/$id/$newx>

=over

outside world url

=over

$mod => $id - ($id % 1000)

$id  => picture_id

$newx => the new x of the thumb

=back

=back

I</thumb/$mod/$id/$newx>

=over

internal webserver redirect url

=back

=head1 METHODS

=cut

=head2 index: Path: Args(3)

B<@args = ($mod, $id, $new)>

=over

validates the params as integers

re-calculates mod

forwards to resize

404's (should only get here if thumb creation failed)

=back

=cut
my $int = qr/\D+/;

sub index: Path Args(3) {
    my ( $self, $c, $mod, $id, $x ) = @_;

    $id =~ s/$int//g;
    $x =~ s/$int//g;

    #work out mod incase someone ddoses server by requesting random mods :\
    $mod = $id - ($id % 1000);

    if ($x != 100 && $x != 150 && $x != 160 && $x != 200 && $x != 250 && $x != 300 && $x != 400 && $x != 500 && $x != 600){
        $c->forward('/default');
        $c->detach();
    }

    # if thumb resize works properly, then we'll be redirected back to this page
    # with a time param, just to make sure we don't hit a cache
    $c->forward('resize', [$mod, $id, $x]);
    $c->forward('/default');
    $c->detach();
}


=head2 resize: Private

B<@args = ($mod, $id, $new)>

=over

finds the picture

creates the thumb using convert

redirects to the thumb (webserver should now handle file) if file exists

=back

=cut
sub resize: Private {
    my ( $self, $c, $mod, $id, $x ) = @_;

    my $row = $c->model('MySQL::Picture')->find({
        'picture_id' => $id,
    });

    #def this here coz we might need it if the image dont exist
    my $cache_image = $c->path_to('root') . $c->config->{'thumb_path'} . "/${mod}/${id}";
    mkpath($cache_image);
    $cache_image .= "/${x}";

    if ( defined($row) && (my $filename = $row->filename) ){
        my $orig_image = $c->path_to('root') . $c->config->{'pic_path'} . "/${filename}";

        my $image = $c->model('Thumb')->resize($orig_image, $cache_image, $x);
        if (!$image && -e $cache_image){
            $c->res->redirect("/static/cache/thumbs/${mod}/${id}/${x}?" . int(rand(100)));
            $c->detach();
        }
    }
#if we get here somethings gone wrong
    my $cp_command = 'cp ' . $c->path_to(qw/root static images blank.png/) . " ${cache_image}";
    warn $cp_command;
    `${cp_command}`;
    $c->res->redirect("/static/cache/thumbs/${mod}/${id}/${x}?" . int(rand(100)));
    $c->detach();
}

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
