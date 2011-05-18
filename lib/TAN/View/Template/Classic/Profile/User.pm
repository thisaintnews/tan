package TAN::View::Template::Classic::Profile::User;
use Moose;

extends 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c ) = @_;

    my %search_opts = (
        'me.deleted' => 'N',
    );
    my $user = $c->stash->{'user'};
    if ( !$c->nsfw ){
        $search_opts{'nsfw'} = 'N';
    }

    my $comment_count = $user->comments->search( {
        %search_opts,
        'object.deleted' => 'N',
    }, {
        'prefetch' => 'object',
    } )->count || 0;
    my $link_count = $user->objects->search({
            'type' => 'link',
            %search_opts,
        })->count || 0;

    my $blog_count = $user->objects->search({
            'type' => 'blog',
            %search_opts,
        })->count || 0;

    my $pic_count = $user->objects->search({
            'type' => 'picture',
            %search_opts,
        })->count || 0;

    my $poll_count = $user->objects->search({
            'type' => 'poll',
            %search_opts,
        })->count || 0;

    my $video_count = $user->objects->search({
            'type' => 'video',
            %search_opts,
        })->count || 0;

    push(@{$c->stash->{'css_includes'}}, 'Profile');

    return qq\
        <ul class="TAN-inside">
            <li>
                <h1>
                    @{[ $c->view->html($user->username) ]}
                    @{[
                        ( $user->deleted eq 'Y' ) ?
                           ' <span style="color:#f00">DELETED</span>'
                    :
                        ''
                    ]}
                </h1>
            </li>
            <li>
                <ul class="TAN-id-card">
                    <li>
                        <img class="TAN-news-avatar" src="@{[ $user->avatar($c) ]}" alt="@{[ $c->view->html($user->username) ]}" />
                        <br />
                        <br />
                        <br />
                        @{[
                            ( $c->user_exists && ($c->user->username eq $user->username) ) ?
                                qq'<a href="/profile/_avatar/">Change Avatar</a>'
                            :
                                ''
                        ]}
                    </li>
                    <li>
                        <ul>
                            <li>Joined @{[ $c->view->html($user->join_date) ]} ago</li>
                            <li>
                                @{[ $comment_count ? '<a href="comments">' : '' ]}
                                    Comments: ${comment_count}
                                @{[ $comment_count ? '</a>' : '' ]}
                            </li>
                            <li>
                                @{[ $link_count ? '<a href="links">' : '' ]}
                                    Links: ${link_count}
                                @{[ $link_count ? '</a>' : '' ]}
                            </li>
                            <li>
                                @{[ $blog_count ? '<a href="blogs">' : '' ]}
                                    Blogs: ${blog_count}
                                @{[ $blog_count ? '</a>' : '' ]}
                            </li>
                            <li>
                                @{[ $pic_count ? '<a href="pictures">' : '' ]}
                                    Pictures: ${pic_count}
                                @{[ $pic_count ? '</a>' : '' ]}
                            </li>
                            <li>
                                @{[ $poll_count ? '<a href="polls">' : '' ]}
                                    Polls: ${poll_count}
                                @{[ $poll_count ? '</a>' : '' ]}
                            </li>
                            <li>
                                @{[ $video_count ? '<a href="videos">' : '' ]}
                                    Videos: ${video_count}
                                @{[ $video_count ? '</a>' : '' ]}
                            </li>
                        </ul>
                    </li>
                    @{[
                        ( $c->user_exists && $c->check_user_roles(qw/edit_user/) ) ?
                            qq#<li class="TAN-profile-user-admin">
                                @{[ $c->view->template('Profile::User::Admin') ]}
                            </li>#
                        :
                            ''
                    ]}
                </ul>
            </li>
            <li>
                @{[ $c->stash->{'object'}->profile->details ]}
                <br />
                @{[
                    ( $c->user_exists 
                        && (
                            $c->check_user_roles(qw/edit_user/)
                            || ( $c->user->username eq $user->username) 
                        )
                    ) ?
                        qq'<a href="@{[ $user->profile_url ]}edit">Edit</a>'
                    :
                        ''
                ]}
            </li>
        </ul>\;
}

__PACKAGE__->meta->make_immutable;
