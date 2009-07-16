############################################################
#
# Palm:Basket 用のリンクを出力します。
# <pre>
# {{palmbasket チャンネル番号,[tiny|small]}}
# </pre>
# tiny または small を指定すると、画像付きのリンクを出力します。
#
############################################################
package plugin::palmbasket::PalmBasket;

sub new {
	my $class = shift;
	my $self  = {};
	return bless $self,$class;
}

sub paragraph {
	my $self  = shift;
	my $wiki  = shift;
	my $channel = shift;
	my $image = shift;
	my $buf = "";

	$buf .= "<div class=\"palmbasket\">";
	$buf .= "<a href=\"http://newsclip.chem.nagoya-u.ac.jp/cgi-bin/palmbasket.cgi?c".Util::escapeHTML($channel)."=1\">";
	if ($image eq "small") {
	    $buf .= "<img src=\"http://newsclip.chem.nagoya-u.ac.jp/palmbasket/PalmBasket_small.png\" alt=\"このページをPalm:Basketに入れる\" border=\"0\">";
	} elsif ($image eq "tiny") {
	    $buf .= "<img src=\"http://newsclip.chem.nagoya-u.ac.jp/palmbasket/PalmBasket_tiny.png\" alt=\"このページをPalm:Basketに入れる\" border=\"0\">";
	} else {
	    $buf .= "このページをPalm:Basketに入れる";
	}
	$buf .= "</a>";
	$buf .= "</div>";

	return $buf;
}

1;
