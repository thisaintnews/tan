package TAN::Controller::Submit;

use strict;
use warnings;
use parent 'Catalyst::Controller';
use Data::Validate::URI;

my $int_reg = qr/\D+/;

=head1 NAME

TAN::Controller::Submit

=head1 DESCRIPTION

Submit controller

=head1 EXAMPLE

''/submit/$location/''

 * submission form

''/submit/$location/post''

 * post here

 Args::

  * $location => link|blog|picture 

=head1 METHODS

=cut

=head2 location: PathPart('submit') Chained('/') CaptureArgs(1)

'''@args = ($location)'''

 * checks user is logged in
 * checks the location is valid

=cut
my $location_reg = qr/^link|blog|picture$/;
sub location: PathPart('submit') Chained('/') CaptureArgs(1){
    my ( $self, $c, $location ) = @_;

    if (!$c->user_exists){
        $c->flash->{'message'} = 'Please login';
        $c->res->redirect('/login/');
        $c->detach();
    }

    if ($location !~ m/$location_reg/){
        $c->forward('/default');
        $c->detach();
    }
    $c->stash->{'location'} = $location;
}


=head2 index: PathPart('') Chained('location') Args(0) 

'''@args = undef'''

 * loads the submit template

=cut
sub index: PathPart('') Chained('location') Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{'template'} = 'submit.tt';
}


=head2 validate: PathPart('') Chained('location') CaptureArgs(0)

'''@args = undef'''

'''@params = (title, description)'''

 * validates generic submission things (title etc)
 * forwards to validate_$location

=cut

#no point redefining these on each request...
my $title_min = 3;
my $desc_min = 5;
my $title_max = 100;
my $desc_max = 1000;
my $blog_min = 20;

my @error_codes = (
    'Title cannont be blank',
    'Description cannot be blank',
    "Title cannot be over ${title_max} characters",
    "Description cannot be over ${desc_max} characters",
    "Title must be over ${title_min} characters",
    "Description must be over ${desc_min} characters",
    'Url is invalid',
    'This link has already been submitted',
    "Blog must be over ${blog_min} characters",
    "Please select an image",
);
sub validate: PathPart('') Chained('location') CaptureArgs(0){
    my ( $self, $c ) = @_;

    my $title = $c->req->param('title');
    my $description = $c->req->param('description');

    if ( $title eq '' ) {
    #blank title
        $c->stash->{'error'} = $error_codes[0];

    } elsif ( length($title) > $title_max ) {
    #long title
        $c->stash->{'error'} = $error_codes[2];

    } elsif ( defined($c->req->param('description')) && length($c->req->param('description')) > $desc_max ) {
    #long description
        $c->stash->{'error'} = $error_codes[3];

    } elsif ( !defined($title) || length($title) < $title_min ) {
    #short title
        $c->stash->{'error'} = $error_codes[4];

    } else {
        if ($c->stash->{'location'} eq 'link'){
        #validate link specific details

            $c->forward('validate_link');

        } elsif ($c->stash->{'location'} eq 'blog') {
        #validate blog specific details

            $c->forward('validate_blog');

        } elsif ($c->stash->{'location'} eq 'picture') {
        #validate picture specific details

            $c->forward('validate_picture');
        }
    }
}

=head2 validate_link: Private

'''@args = undef'''

'''@params = (description, cat, url)'''

 * validates link specific details

=cut
sub validate_link: Private{
    my ( $self, $c ) = @_;

    my $description = $c->req->param('description');
    my $cat = $c->req->param('cat');

    $cat =~s/$int_reg//g;
    if (!defined($cat)){
    #no image selected
        $c->stash->{'error'} = $error_codes[9];
    }

    if (length($description) < $desc_min){
    #desc too short
        $c->stash->{'error'} = $error_codes[5];
    }

    my $valid_url = Data::Validate::URI->new();
    my $url = $c->req->param('url');

    if ( !defined($valid_url->is_web_uri($url)) ){
    #invalid url
        $c->stash->{'error'} = $error_codes[6];                
    }

    my $link = $c->model('MySQL::Link')->search({
        'url' => $url,
    });

    if ($link->count){
    #already submitted
        $c->stash->{'error'} = $error_codes[7];
    }
}

=head2 validate_blog: Private

'''@args = undef'''

'''@params = (description, cat, blogmain)'''

 * validates blog specific details

=cut
sub validate_blog: Private{
    my ( $self, $c ) = @_;
    
    my $description = $c->req->param('description');
    my $cat = $c->req->param('cat');

    $cat =~ s/$int_reg//g;
    if (!defined($cat)){
    #no image selected
        $c->stash->{'error'} = $error_codes[9];
    }

    if (length($description) < $desc_min){
    #desc too short
        $c->stash->{'error'} = $error_codes[5];
    }

    if (length($c->req->param('blogmain')) < $blog_min) {
    #blog too short
        $c->stash->{'error'} = $error_codes[8];
    }
}

=head2 validate_picture: Private

'''@args = undef'''

'''@params = (pic_url, pic)'''

 * validates picture specific details

=cut
sub validate_picture: Private{
    my ( $self, $c ) = @_;

    my $title = $c->req->param('title');
    my $url_title = $c->url_title($title);
    my @path = split('/', 'root/' . $c->config->{'pic_path'} . '/' . time . '_' . $url_title);

    my ( $fileinfo, $fetcher ) = (0, undef);

    my $url = $c->req->param('pic_url');
    if ( $url ){
    #fetch
        my $valid_url = Data::Validate::URI->new();
        if ( !defined($valid_url->is_web_uri($url)) ){
        #invalid url
            $c->stash->{'error'} = $error_codes[6];                
        } else {
        #valid url, fetch and validate
            $fetcher = $c->model('FetchImage');
            $fileinfo = $fetcher->fetch($c->req->param('pic_url'), $c->path_to(@path));
            if ( !$fileinfo ){
                $c->stash->{'error'} = $fetcher->{'error'};
            }
        }
    } elsif (my $upload = $c->request->upload('pic')) {
    #upload
        $fileinfo = $c->model('ValidateImage')->is_image($upload->tempname);
        $fileinfo = $c->stash->{'fileinfo'};

        if( $fileinfo ){
        #is an image
            $fileinfo->{'filename'} = $c->path_to(@path) . '.' . $fileinfo->{'file_ext'};
            $upload->copy_to($fileinfo->{'filename'});
        } else {
            $c->stash->{'error'} = 'Invalid filetype';
        }
    } else {
        $c->stash->{'error'} = 'No image';
    }

    if ( $fileinfo ) {
        $c->stash->{'fileinfo'} = $fileinfo;
    }
}

=head2 post: PathPart('post') Chained('validate') Args(0)

'''@args = undef'''

 * checks stash for $error
 * forwards to submit_$location

=cut
sub post: PathPart('post') Chained('validate') Args(0){
    my ( $self, $c ) = @_;

    if ( $c->stash->{'error'} ){
        $c->flash->{'message'} = $c->stash->{'error'};
        $c->res->redirect('/submit/' . $c->stash->{'location'} . '/');
        $c->detach();
    }

    if ($c->stash->{'location'} eq 'link'){
    #submit link

        $c->forward('submit_link');

    } elsif ($c->stash->{'location'} eq 'blog'){
    #submit blog

        $c->forward('submit_blog');

    } elsif ($c->stash->{'location'} eq 'picture') {
    #submit picture

        $c->forward('submit_picture');

    }

    $c->res->redirect('/index/' . $c->stash->{'location'} . '/1/1/');
    $c->detach();
}

=head2 submit_link: Private

'''@args = undef'''

'''@params = (title, description, cat, url)'''

 * submits a link

=cut
sub submit_link: Private{
    my ( $self, $c ) = @_;

    my $object = $c->model('MySQL::Object')->create({
        'type' => $c->stash->{'location'},
        'created' => \'NOW()',
        'promoted' => 0,
        'user_id' => $c->user->user_id,
        'nsfw' => 'N',
        'rev' => 0,
        'link' => {
            'title' => $c->req->param('title'),
            'description' => $c->req->param('description'),
            'picture_id' => $c->req->param('cat'),
            'url' => $c->req->param('url'),
        },
        'plus_minus' => [{
            'type' => 'plus',
            'user_id' => $c->user->user_id,
        }],
    });

    if (!$object->id){
        $c->flash->{'message'} = 'Error submitting link';
    }
}

=head2 submit_blog: Private

'''@args = undef'''

'''@params = (title, description, cat, blogmain)'''

 * submits a blog

=cut
sub submit_blog: Private{
    my ( $self, $c ) = @_;

    my $object = $c->model('MySQL::Object')->create({
        'type' => $c->stash->{'location'},
        'created' => \'NOW()',
        'promoted' => 0,
        'user_id' => $c->user->user_id,
        'nsfw' => 'N',
        'rev' => 0,
        'blog' => {
            'title' => $c->req->param('title'),
            'description' => $c->req->param('description'),
            'picture_id' => $c->req->param('cat'),
            'details' => $c->req->param('blogmain'),
        },
        'plus_minus' => [{
            'type' => 'plus',
            'user_id' => $c->user->user_id,
        }],
    });

    if (!$object->id){
        $c->flash->{'message'} = 'Error submitting blog';
    }
}

=head2 submit_picture: Private

'''@args = undef'''

'''@params = (nsfw, title, pdescription)'''

 * submits a picture

=cut
sub submit_picture: Private{
    my ( $self, $c ) = @_;

    my $fileinfo = $c->stash->{'fileinfo'};

    my @path = split('/', $fileinfo->{'filename'});
    my $filename = $path[-1];

    my $object = $c->model('MySQL::Object')->create({
        'type' => $c->stash->{'location'},
        'created' => \'NOW()',
        'promoted' => 0,
        'user_id' => $c->user->user_id,
        'nsfw' => defined($c->req->param('nsfw')) ? 'Y' : 'N',
        'rev' => 0,
        'picture' => {
            'title' => $c->req->param('title'),
            'description' => $c->req->param('pdescription') || '',
            'filename' => $filename,
            'x' => $fileinfo->{'x'},
            'y' => $fileinfo->{'y'},
            'size' => $fileinfo->{'size'},
        },
        'plus_minus' => [{
            'type' => 'plus',
            'user_id' => $c->user->user_id,
        }],
    });
}

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
