############################################################
#
# PiloWebPro 用のコメントを出力します。
# <pre>
# {{pilowebend}}
# </pre>
#
############################################################
package plugin::piloweb::PiloEnd;

sub new {
	my $class = shift;
	my $self  = {};
	return bless $self,$class;
}

sub inline {
	my $self  = shift;
	my $wiki  = shift;
	my $buf = "";

	$buf .= "<!-------- END_PILOWEB_ARTICLE -------->\n";
	$buf .= "<!-- END_PILOWEB_ARTICLE -->\n";
	return $buf;
}

1;
