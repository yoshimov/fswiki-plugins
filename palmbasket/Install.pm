############################################################
#
# PalmBasket�ѤΥ�󥯤���Ϥ��ޤ���
#
############################################################
package plugin::palmbasket::Install;
#use strict;

sub install {
	my $wiki = shift;
	$wiki->add_paragraph_plugin("palmbasket" ,"plugin::palmbasket::PalmBasket", "HTML");
}

1;
