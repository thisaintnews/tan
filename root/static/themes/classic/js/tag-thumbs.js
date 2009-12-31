var selected;

window.addEvent('domready', function() {
	$('tags').addEvents({
		keyup: function(e) {
			if (e.code === 32){
				get_thumbs();
				e.stop();
			}
		}
	});
	
	$$('.refresh_thumbs').addEvents({
		click: function(e) {
			get_thumbs();
			e.stop();
		}
	});
});

function get_thumbs(id){
	if (id){
		idstr = ' !' + id;
	} else {
		idstr = '';
	}
	if ($('tags').value){
	    var req = new Request.JSON({
	    	url:'/tagthumbs/' + $('tags').value + idstr + '/?time=' + $time(), 
	    	onRequest:function(){
	    		$('thumb_tags').fade(0);
	    	},
	    	onComplete:function(json_data){
	    		$('thumb_tags').set('html', '<label>Picture</label><br /><br />');
	    		add_thumbs(json_data);
	    		$('thumb_tags').fade(1);
	    		if (id){
	    			select_img($('pic' + id));
	    		}
	    	},
	        noCache: true
	    }).get();
	}
}

function select_img(img){
	if (selected){
		selected.morph({
			'width': '50px',
			'height' : '50px'
		});
	}
	selected = img;
    img.morph({
    	'width': '100px',
    	'height' : '100px'
    });
    $('cat').value = parseInt(img.id.substring(3), 10);
}

function add_thumbs(thumbs) {
	thumbs.each(function(thumb) {
        var mod = thumb['object_id'] - (thumb['object_id'] % 1000);
		var img = new Element('img', {
			'src': '/static/cache/thumbs/' + mod + '/' + thumb['object_id'] + '/100',
			'class': 'tag_thumb_img',
			'style': 'margin:5px;',
			'id': 'pic' + thumb['object_id']
		});
		img.addEvent('click',function(e){
			select_img(this);
			e.stop;
		});
		img.inject($('thumb_tags'));
	});
};
