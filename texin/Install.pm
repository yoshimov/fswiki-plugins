############################################################
#
# TeXϢ���ѥץ饰����
#
############################################################
package plugin::texin::Install;
#use strict;

sub install {
	my $wiki = shift;
	$wiki->add_inline_plugin("texmath" ,"plugin::texin::Math", "HTML");
}

1;
