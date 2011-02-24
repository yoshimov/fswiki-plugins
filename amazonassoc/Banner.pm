############################################################
#
# Google AdSenseのBannerを表示する。
# <pre>
# {{amazonassoc_banner AdSense ID,width,height}}
# </pre>
#
############################################################
package plugin::amazonassoc::Banner;

sub new {
	my $class = shift;
	my $self  = {};
	return bless $self,$class;
}

sub inline {
	my $self  = shift;
	my $wiki  = shift;
	my $userid = shift;
	my $width = shift;
	my $height = shift;
	my $buf = "";

  $buf .= <<"EOF";
<script type="text/javascript"><!--
amazon_ad_tag = "$userid";
amazon_ad_width = "$width";
amazon_ad_height = "$height";
//--></script>
<script type="text/javascript" src="http://www.assoc-amazon.jp/s/ads.js"></script>
EOF

  return $buf;
}

1;
