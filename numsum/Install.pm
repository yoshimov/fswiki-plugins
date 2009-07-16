############################################################
#
# NumSumの取り込み
#
############################################################
package plugin::numsum::Install;
#use strict;

sub install {
	my $wiki = shift;
	$wiki->add_inline_plugin("numsum" ,"plugin::numsum::Sheet", "HTML");
	$wiki->add_inline_plugin("youtube" ,"plugin::numsum::YouTube", "HTML");
}

1;
