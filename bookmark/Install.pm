############################################################
#
# WikiページにURLリンクを追加するためのプラグインを提供します。
#
############################################################
package plugin::bookmark::Install;
use strict;

sub install {
	my $wiki = shift;
	$wiki->add_handler("BOOKMARK","plugin::bookmark::BookmarkHandler");
}

1;
