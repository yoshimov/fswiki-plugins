############################################################
#
# PiloWebPro 用のコメントを出力します。
# <pre>
# {{pilowebstart}}
# </pre>
#
############################################################
package plugin::piloweb::PiloStart;

sub new {
	my $class = shift;
	my $self  = {};
	return bless $self,$class;
}

sub inline {
	my $self  = shift;
	my $wiki  = shift;
	my $buf = "";

	$buf .= "<!-- BEGIN_PILOWEB_ARTICLE -->\n";
	$buf .= "<!-------- BEGIN_PILOWEB_ARTICLE -------->\n";
	return $buf;
}

1;
