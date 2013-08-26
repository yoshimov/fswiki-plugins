############################################################
#
# FreeStyleWiki上でGraphvizのDOTを表示します
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
