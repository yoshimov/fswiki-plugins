############################################################
#
# Google AdSense連携用のプラグイン集
#
############################################################
package plugin::googleadsense::Install;
#use strict;

sub install {
	my $wiki = shift;
	$wiki->add_inline_plugin("googleadsense_banner" ,"plugin::googleadsense::Banner", "HTML");
}

1;
