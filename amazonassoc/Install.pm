############################################################
#
# Google AdSense連携用のプラグイン集
#
############################################################
package plugin::amazonassoc::Install;
#use strict;

sub install {
	my $wiki = shift;
	$wiki->add_inline_plugin("amazonassoc_banner" ,"plugin::amazonassoc::Banner", "HTML");
}

1;
