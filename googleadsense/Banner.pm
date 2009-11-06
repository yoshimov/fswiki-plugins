############################################################
#
# Google AdSenseのBannerを表示する。
# <pre>
# {{googleadsense_banner AdSense ID,slot ID,[h|v|l|b|w]}}
# h .. 468x60
# v .. 120x240
# l .. 468x15
# b .. 336x280
# w .. 160x600
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
	my $slotid = shift;
	my $dir = shift;
	my $buf = "";

	if ($dir eq "") {
	    $dir = "v";
	}

  $buf .= <<"EOF";
<script type="text/javascript"><!--
google_ad_client = "$userid";
google_ad_slot = "$slotid";
EOF
  
  if ($dir eq "v") {
	    $buf .= <<"EOF";
google_ad_width = 120;
google_ad_height = 240;
EOF
        } elsif ($dir eq "l") {
	    $buf .= <<"EOF";
google_ad_width = 468;
google_ad_height = 15;
EOF
        } elsif ($dir eq "b") {
	    $buf .= <<"EOF";
google_ad_width = 336;
google_ad_height = 280;
EOF
        } elsif ($dir eq "w") {
	    $buf .= <<"EOF";
google_ad_width = 160;
google_ad_height = 600;
EOF
  } else {
	    $buf .= <<"EOF";
google_ad_width = 468;
google_ad_height = 60;
EOF
  }

  $buf .= <<"EOF";
//--></script>
<script type="text/javascript"
  src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
</script>
EOF

  return $buf;
}

1;
