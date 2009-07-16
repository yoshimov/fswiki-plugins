############################################################
#
# NumSumの表を表示する。
# <pre>
# {{numsum SheetID,[width,height]}}
# </pre>
#
############################################################
package plugin::numsum::Sheet;

sub new {
	my $class = shift;
	my $self  = {};
	return bless $self,$class;
}

sub inline {
	my $self  = shift;
	my $wiki  = shift;
	my $sheetid = shift;
	my $width = shift;
	my $height = shift;
	my $buf = "";

	if ($width eq "") {
	    $width = "100%";
	}
	if ($height eq "") {
	    $height = "300";
	}

	$buf .= <<"EOF";
<iframe src="http://numsum.com/spreadsheet/show_plain/$sheetid"
        width="$width" height="$height"></iframe>
EOF

	return $buf;
}

1;
