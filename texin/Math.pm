############################################################
#
# TeXの数式を表示する
# <pre>
# {{texmath TeX Math}}
# </pre>
#
############################################################
package plugin::texin::Math;

sub new {
	my $class = shift;
	my $self  = {};
	return bless $self,$class;
}

sub inline {
  my $self  = shift;
  my $wiki  = shift;
  my $tex = shift;
  my $buf = "";

  my $texenc = Util::url_encode($tex);
  
  $buf .= <<"EOF";
<img src="http://chart.googleapis.com/chart?cht=tx&chl=$texenc" />
EOF
  return $buf;
}

1;
