package TAN::Controller::Profile;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

sub clear_index_caches: Event(object_created) Event(object_deleted) Event(comment_created){
    my ( $self, $c, $object ) = @_;

    $c->clear_cached_page('/profile/.*/links');
    $c->clear_cached_page('/profile/.*/blogs');
    $c->clear_cached_page('/profile/.*/pictures');
}

sub clear_comment_caches: Event(comment_deleted){
    my ( $self, $c, $object ) = @_;

    $c->clear_cached_page('/profile/.*/comments');
}


sub index: Private{
    my ( $self, $c ) = @_;

    $c->cache_page(600);

    my $users = $c->model('MySQL::User')->search({
        'deleted' => 'N',
    },{
        'columns' => [
            'user_id', 
            'username',
        ],
    });

    $c->stash(
        'users' => $users,
        'template' => 'Profile', 
        'page_title' => "User List",
    );
}

sub user: PathPart('profile') Chained('/') CaptureArgs(1){
    my ( $self, $c, $username ) = @_;

    $c->stash->{'user'} = $c->model('MySQL::User')->find({
        'username' => $username,
    });

    if ( !$c->stash->{'user'} ){
        $c->forward('/default');
        $c->detach();
    }
}

sub user_index: PathPart('') Chained('user') Args(0){
    my ( $self, $c ) = @_;

    $c->cache_page(600);

    my $user = $c->stash->{'user'};

#prevent race
    eval{
        $c->model('MySQL')->txn_do(sub{
            $c->stash->{'object'} = $c->model('MySQL::Object')->find_or_create({
                'user_id' => $user->id,
                'type' => 'profile',
            });
            $c->stash->{'object'}->find_or_create_related('profile',{});
        });
    };

    $c->stash(
        'page_title' => $user->username . "'s Profile",
        'template' => 'Profile::User',
    );
}

sub edit: PathPart('edit') Chained('user') Args(0){
    my ( $self, $c ) = @_;

    if ( $c->user_exists && ($c->stash->{'user'}->id == $c->user->id) ){
        $c->stash->{'object'} = $c->model('MySQL::Object')->find({
            'user_id' => $c->stash->{'user'}->id,
            'type' => 'profile',
        });

        if ( $c->req->method eq 'POST' && defined($c->req->param('profile')) ){
            if ( defined($c->stash->{'object'}) ){
                my $profile = $c->stash->{'object'}->profile;
                
                if ( defined($profile) ){
                    $profile->update({
                        'details' => $c->req->param('profile'),
                    });

                    $c->cache->remove("profile.0:" . $c->stash->{'object'}->id);
                    $c->cache->remove("profile.1:" . $c->stash->{'object'}->id);
                }
            }
            $c->res->redirect('/profile/' . $c->stash->{'user'}->username);
            $c->detach;
        }
        $c->stash->{'template'} = 'Profile::Edit';
        $c->detach;
    }

    $c->res->redirect("/profile/@{[ $c->stash->{'user'}->username ]}/");
    $c->detach;
}

sub comments: PathPart('comments') Chained('user') Args(0){
    my ( $self, $c ) = @_;

    $c->cache_page(600);

    my $page = $c->req->param('page') || 1;

    $c->stash->{'comments'} = $c->stash->{'user'}->comments->search({
            'me.deleted' => 'N',
        },
        {
            'prefetch' => ['user', {
                'object' => ['link', 'blog', 'picture'],
            }],
            'page' => $page,
            'rows' => 50,
            'order_by' => {
                '-desc' => 'me.created',
            },
        }
    );

    if ( !$c->stash->{'comments'} ) {
        $c->forward('/default');
        $c->detach;
    }

    $c->stash(
        'page_title' => $c->stash->{'user'}->username . "'s Comments",
        'template' => 'Profile::Comments',
    );
}

sub links: PathPart('links') Chained('user') Args(0){
    my ( $self, $c ) = @_;

    $c->forward('fetch', ['link']);

    $c->stash(
        'template' => 'Index',
        'can_rss' => 1,
    );
}

sub blogs: PathPart('blogs') Chained('user') Args(0){
    my ( $self, $c ) = @_;

    $c->forward('fetch', ['blog']);

    $c->stash(
        'template' => 'Index',
        'can_rss' => 1,
    );
}

sub pictures: PathPart('pictures') Chained('user') Args(0){
    my ( $self, $c ) = @_;

    $c->forward('fetch', ['picture']);

    $c->stash(
        'fancy_picture_index' => 1,
        'template' => 'Index',
        'can_rss' => 1,
    );
}

sub polls: PathPart('polls') Chained('user') Args(0){
    my ( $self, $c ) = @_;

    $c->forward('fetch', ['poll']);

    $c->stash(
        'template' => 'Index',
        'can_rss' => 1,
    );
}

sub fetch: Private{
    my ( $self, $c, $location ) = @_;

    $c->cache_page(600);

    my $page = $c->req->param('page') || 1;
    my $order = $c->req->param('order') || 'created';

    my ( $objects, $pager ) = $c->stash->{'user'}->objects->index( $location, $page, 1, {}, $order, $c->nsfw, "profile:" . $c->stash->{'user'}->id );

    if ( scalar(@{$objects}) ){
        $c->stash(
            'index' => $c->model('Index')->indexinate($c, $objects, $pager),
            'order' => $order,
            'page_title' => $c->stash->{'user'}->username . "'s " . ucfirst($location) . "s",
            'location' => $location,
        );
    } else {
        $c->forward('/default');
        $c->detach;
    }
}

__PACKAGE__->meta->make_immutable;
