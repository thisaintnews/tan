(function(){
    var short_username = stash.username.truncate(17);

    console.log( short_username );

    return [
        new Element('h2', {
            'class': 'TAN-type-' + stash.type,
            'text': stash.title
        }),
        new Element('a', {
            'href': 'view/' + stash.type + '/' + stash.id
        }).adopt(
            new Element('img', {
                'class': 'TAN-object-image',
                'src': stash.image,
                'alt': ''
            })
        ),
        new Element('p', {
            'text': stash.description ? stash.description : ''
        }),
        new Element('div', {
            'class': 'TAN-object-info-bar'
        }).adopt(
            new Element('span', {
                'class': 'TAN-pipe-right'
            }).adopt(
                new Element('a', {
                    'class': 'TAN-object-user',
                    'href': 'profile/' + stash.username.toURI(),
                    'text': ' ' + short_username 
                }).grab(
                    new Element('img', {
                        'src': 'images/avatar.gif',
                        'alt': stash.username
                    }),
                    'top'
                )
            ),
            new Element('span', {
                'class': 'TAN-pipe-right'
            }).adopt(
                new Element('a', {
                    'class': 'TAN-plus',
                    'href': '#',
                    'text': 'TIN (' + stash.plus + ')'
                }),
                new Element('span', {
                    'class': 'TAN-object-score',
                    'text': stash.score
                }),
                new Element('a', {
                    'class': 'TAN-minus',
                    'href': '#',
                    'text': 'TAN (' + stash.minus + ')'
                })
            ),
            new Element('span').adopt(
                new Element('a', {
                    'href': '#',
                    'text': ' ' + stash.comments
                }).grab(
                    new Element('img', {
                        'src': 'images/comment.png',
                        'alt': '#'
                    }),
                    'top'
                )
            )
        )
    ];
})();
