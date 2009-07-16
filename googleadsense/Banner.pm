############################################################
#
# Google AdSenseのBannerを表示する。
# <pre>
# {{googleadsense_banner AdSense ID,[h|v]}}
# </pre>
#
############################################################
package plugin::googleadsense::Banner;

sub new {
	my $class = shift;
	my $self  = {};
	return bless $self,$class;
}

sub inline {
	my $self  = shift;
	my $wiki  = shift;
	my $userid = shift;
	my $dir = shift;
	my $buf = "";

	if ($dir eq "") {
	    $dir = "v";
	}
	if ($dir eq "v") {
	    $buf .= <<"EOF";
<script type="text/javascript"><!--
google_ad_client = "$userid";
google_ad_width = 120;
google_ad_height = 240;
google_ad_format = "120x240_as";
google_ad_type = "text";
google_ad_channel ="";
//--></script>
<script type="text/javascript"
  src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
</script>
EOF
        } else {
	    $buf .= <<"EOF";
<script type="text/javascript"><!--
google_ad_client = "$userid";
google_ad_width = 468;
google_ad_height = 60;
google_ad_format = "468x60_as";
google_ad_type = "text";
google_ad_channel ="";
//--></script>
<script type="text/javascript"
  src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
</script>
EOF
        }
	return $buf;
}

1;
