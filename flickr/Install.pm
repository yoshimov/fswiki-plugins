############################################################
#
# Flickr連携用のプラグイン集
#
############################################################
package plugin::flickr::Install;
#use strict;

sub install {
	my $wiki = shift;
	$wiki->add_inline_plugin("flickr_zeitgeist" ,"plugin::flickr::Zeitgeist", "HTML");
	$wiki->add_inline_plugin("flickr_badge" ,"plugin::flickr::Badge", "HTML");
}

1;
