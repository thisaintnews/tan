package TAN::Controller::Profile::Admin::Delete;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

sub delete: Chained('../admin') Args(0){
    my ( $self, $c ) = @_;

    if ( $c->req->method eq 'POST' ){
        #toggle delete
        $c->stash->{'user'}->update( {
            'deleted' => ( $c->stash->{'user'}->deleted eq 'Y' ) ? 'N' : 'Y',
        } );

        $c->forward('_force_logout');
#log action - reason
# ^ link to delete reason on profile page?
#send email

        $c->res->redirect( $c->stash->{'user'}->profile_url, 303 );
        $c->detach;
    }

    $c->stash->{'template'} = 'Profile::Admin::Delete';
}

sub _force_logout: Private{
    my ( $self, $c ) = @_;

    my $views_rs = $c->model('MySql::Views')->search( {
        'user_id' => $c->stash->{'user'}->id,
    },{
        'group_by' => 'session_id',
    } );

    foreach my $view ( $views_rs->all ){
        foreach my $key ( ('session','expires') ){
            $c->delete_session_data( "${key}:" . $view->session_id );
        }
    }
}

__PACKAGE__->meta->make_immutable;