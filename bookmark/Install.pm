############################################################
#
# Wiki�ڡ�����URL��󥯤��ɲä��뤿��Υץ饰������󶡤��ޤ���
#
############################################################
package plugin::bookmark::Install;
use strict;

sub install {
	my $wiki = shift;
	$wiki->add_handler("BOOKMARK","plugin::bookmark::BookmarkHandler");
}

1;
