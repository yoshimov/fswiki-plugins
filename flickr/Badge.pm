############################################################
#
# FlickrのBadgeを表示する。
# <pre>
# {{flickr_badge Flickr ID,num,[random|latest]}}
# </pre>
#
############################################################
package plugin::flickr::Badge;

sub new {
	my $class = shift;
	my $self  = {};
	return bless $self,$class;
}

sub inline {
	my $self  = shift;
	my $wiki  = shift;
	my $id = shift;
	my $count = shift;
	my $display = shift;
	my $buf = "";

	my $userid = &Util::url_encode($id);
	if ($count eq "") {
	    $count = 3;
	} else {
	    $count = &Util::escapeHTML($count);
	}
	if ($display eq "") {
	    $display = "random";
	} else {
	    $display = &Util::escapeHTML($display);
	}
	$buf .= <<"EOF";
<!-- Start of Flickr Badge -->
<style type="text/css">
#flickr_badge_source_txt {padding:0; font: 11px Arial, Helvetica, Sans serif; color:#666666;}
#flickr_badge_icon {display:block !important; margin:0 !important; border: 1px solid rgb(0, 0, 0) !important;}
#flickr_icon_td {padding:0 5px 0 0 !important;}
.flickr_badge_image {text-align:center !important;}
.flickr_badge_image img {border: 1px solid black !important;}
#flickr_www {display:block; padding:0 10px 0 10px !important; font: 11px Arial, Helvetica, Sans serif !important; color:#3993ff !important;}
#flickr_badge_uber_wrapper a:hover,
#flickr_badge_uber_wrapper a:link,
#flickr_badge_uber_wrapper a:active,
#flickr_badge_uber_wrapper a:visited {text-decoration:none !important; background:inherit !important;color:#3993ff;}
#flickr_badge_wrapper {background-color:#ffffff;border: solid 1px #000000}
#flickr_badge_source {padding:0 !important; font: 11px Arial, Helvetica, Sans serif !important; color:#666666 !important;}
</style>
<table id="flickr_badge_uber_wrapper" cellpadding="0" cellspacing="0" border="0"><tr><td><a href="http://www.flickr.com" id="flickr_www">www.<strong style="color:#3993ff">flick<span style="color:#ff1c92">r</span></strong>.com</a><table cellpadding="0" cellspacing="10" border="0" id="flickr_badge_wrapper">
<script type="text/javascript" src="http://www.flickr.com/badge_code_v2.gne?count=$count&display=$display&size=t&layout=v&source=user&user=$userid"></script>
</table>
</td></tr></table>
<!-- End of Flickr Badge -->
EOF

	return $buf;
}

1;
