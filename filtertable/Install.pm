############################################################
#
# FreeMindɽ���ѤΥץ饰����
#
############################################################
package plugin::filtertable::Install;
#use strict;

sub install {
	my $wiki = shift;
	$wiki->add_paragraph_plugin("filtertable" ,"plugin::filtertable::FilterTable", "HTML");
}

1;
