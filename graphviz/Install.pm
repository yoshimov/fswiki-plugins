############################################################
#
# FreeStyleWiki���Graphviz��DOT��ɽ�����ޤ�
#
############################################################
package plugin::graphviz::Install;
use strict;

sub install {
    my $wiki = shift;
    $wiki->add_block_plugin(
	"graphviz", "plugin::graphviz::Graphviz", "HTML");
}

1;
