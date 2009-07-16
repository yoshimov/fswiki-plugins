############################################################
#
# YouTubeを表示する。
# <pre>
# {{youtube ID,[width,height]}}
# </pre>
#
############################################################
package plugin::numsum::YouTube;

sub new {
	my $class = shift;
	my $self  = {};
	return bless $self,$class;
}

sub inline {
	my $self  = shift;
	my $wiki  = shift;
	my $id = shift;
	my $width = shift;
	my $height = shift;
	my $buf = "";

	if ($width eq "") {
	    $width = "425";
	}
	if ($height eq "") {
	    $height = "350";
	}

	$buf .= <<"EOF";
<object width="$width" height="$height"><param name="movie" value="http://www.youtube.com/v/$id"></param><param name="wmode" value="transparent"></param><embed src="http://www.youtube.com/v/$id" type="application/x-shockwave-flash" wmode="transparent" width="$width" height="$height"></embed></object>
EOF

	return $buf;
}

1;
