############################################################
#
# FlickrのZeitgeistを表示する。
# scopeは0が自分のみ、1がcontacts、2が自分とcontacts
# <pre>
# {{flickr_zeitgeist Flickr ID,scope}}
# </pre>
#
############################################################
package plugin::flickr::Zeitgeist;

sub new {
	my $class = shift;
	my $self  = {};
	return bless $self,$class;
}

sub inline {
	my $self  = shift;
	my $wiki  = shift;
	my $id = shift;
	my $scope = shift;
	my $buf = "";
	if ($scope eq "") {
	    $scope = 0;
	}

	$buf .= "<script type=\"text/javascript\">\n";
	if ($scope == 0) {
	    $buf .= "var zg_nsids = '".&Util::escapeHTML($id)."';\n";
	} else {
	    $buf .=" var zg_person_scope = ".&Util::escapeHTML($scope).";\n";
	    $buf .=" var zg_scope_nsid = '".&Util::escapeHTML($id)."';\n";
	}
	$buf .= <<"EOF";
</script>
<script src="http://www.flickr.com/fun/zeitgeist/badge.js.gne" type="text/javascript"></script>
EOF

	return $buf;
}

1;
