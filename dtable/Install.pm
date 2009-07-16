################################################################################
#
# ダイナミックテーブル機能を実現するプラグインを提供します。
#
################################################################################
package plugin::dtable::Install;
#use strict;
sub install {
	my $wiki = shift;
	$wiki->add_paragraph_plugin("tablepage","plugin::dtable::TablePage","WIKI");
	$wiki->add_paragraph_plugin("tablecategory","plugin::dtable::TableCategory","WIKI");
	$wiki->add_handler("TABLECATEGORY_SORT","plugin::dtable::TableCategory");
}

1;
