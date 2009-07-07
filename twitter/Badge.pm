############################################################
#
# TwitterのBadgeを表示する。
# <pre>
# {{twitter_badge Twitter ID}}
# </pre>
#
############################################################
package plugin::twitter::Badge;

sub new {
	my $class = shift;
	my $self  = {};
	return bless $self,$class;
}

sub inline {
	my $self  = shift;
	my $wiki  = shift;
	my $id = shift;

	my $userid = &Util::escapeHTML($id);
	$buf .= <<"EOD";
<div style="width:176px;text-align:center"><embed src="http://twitter.com/flash/twitter_badge.swf"  flashvars="color1=16594585&type=user&id=$userid"  quality="high" width="176" height="176" name="twitter_badge" align="middle" allowScriptAccess="always" wmode="transparent" type="application/x-shockwave-flash" pluginspage="http://www.macromedia.com/go/getflashplayer" /><br><a style="font-size: 10px; color: #FD3699; text-decoration: none" href="http://twitter.com/yoshimov">follow $userid at http://twitter.com</a></div>
EOD

	return $buf;
}

1;
