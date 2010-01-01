package TAN::Schema::Result::Object;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("object");
__PACKAGE__->add_columns(
  "object_id",
  { data_type => "BIGINT", default_value => undef, is_nullable => 0, size => 20 },
  "type",
  { data_type => "ENUM", default_value => undef, is_nullable => 0, size => 7 },
  "created",
  {
    data_type => "TIMESTAMP",
    default_value => "CURRENT_TIMESTAMP",
    is_nullable => 0,
    size => 14,
  },
  "promoted",
  {
    data_type => "TIMESTAMP",
    default_value => undef,
    is_nullable => 1,
    size => 14,
    datetime_undef_if_invalid => 1,
  },
  "user_id",
  { data_type => "BIGINT", default_value => undef, is_nullable => 0, size => 20 },
  "nsfw",
  { data_type => "ENUM", default_value => "N", is_nullable => 0, size => 1 },
  "rev",
  { data_type => "INT", default_value => 0, is_nullable => 0, size => 11 },
);
__PACKAGE__->set_primary_key("object_id");


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-11-04 22:01:20
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:zHtxjN50TOUzr4b7Jb877A

__PACKAGE__->belongs_to(
  "user",
  "TAN::Schema::Result::User",
  { user_id => "user_id" },
);

__PACKAGE__->might_have(
  "blog",
  "TAN::Schema::Result::Blog",
  { "foreign.blog_id" => "self.object_id" },
);

__PACKAGE__->might_have(
  "link",
  "TAN::Schema::Result::Link",
  { "foreign.link_id" => "self.object_id" },
);

__PACKAGE__->might_have(
  "picture",
  "TAN::Schema::Result::Picture",
  { "foreign.picture_id" => "self.object_id" },
);

__PACKAGE__->might_have(
  "old_lookup",
  "TAN::Schema::Result::OldLookup",
  { "foreign.new_id" => "self.object_id" },
);

__PACKAGE__->has_many(
  "comments",
  "TAN::Schema::Result::Comments",
  { "foreign.object_id" => "self.object_id" },
);

__PACKAGE__->has_many(
  "plus_minus",
  "TAN::Schema::Result::PlusMinus",
  { "foreign.object_id" => "self.object_id" },
);

__PACKAGE__->has_many(
  "views",
  "TAN::Schema::Result::Views",
  { "foreign.object_id" => "self.object_id" },
);

__PACKAGE__->has_many(
  "tag_objects",
  "TAN::Schema::Result::TagObjects",
  { "foreign.object_id" => "self.object_id" },
);

__PACKAGE__->many_to_many(
  "tags" => "tag_objects",
  "tag" 
);

1;
