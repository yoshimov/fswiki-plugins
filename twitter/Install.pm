############################################################
#
# Twitter連携用のプラグイン集
#
############################################################
package plugin::twitter::Install;
#use strict;

sub install {
	my $wiki = shift;
	$wiki->add_inline_plugin("twitter_text" ,"plugin::twitter::Text", "HTML");
	$wiki->add_inline_plugin("twitter_badge" ,"plugin::twitter::Badge", "HTML");
}

1;
