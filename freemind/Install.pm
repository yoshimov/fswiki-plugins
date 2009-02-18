############################################################
#
# FreeMind表示用のプラグイン
#
############################################################
package plugin::freemind::Install;
#use strict;

sub install {
	my $wiki = shift;
	$wiki->add_paragraph_plugin("ref_mm" ,"plugin::freemind::RefFreeMindFlash", "HTML");
}

1;
