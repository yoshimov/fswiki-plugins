############################################################
#
# Wikiページでチャット
#
############################################################
package plugin::imchat::Install;
use strict;

sub install {
	my $wiki = shift;
	$wiki->add_paragraph_plugin("imchat","plugin::imchat::IMChat","HTML");
	$wiki->add_handler("IMCHAT","plugin::imchat::IMChatHandler");
}

1;
