############################################################
#
# PiloWebPro用のコメントを出力します。
#
############################################################
package plugin::piloweb::Install;
#use strict;

sub install {
	my $wiki = shift;
	$wiki->add_inline_plugin("pilowebstart" ,"plugin::piloweb::PiloStart", "HTML");
	$wiki->add_inline_plugin("pilowebbegin" ,"plugin::piloweb::PiloStart", "HTML");
	$wiki->add_inline_plugin("pilowebend" ,"plugin::piloweb::PiloEnd", "HTML");
}

1;
