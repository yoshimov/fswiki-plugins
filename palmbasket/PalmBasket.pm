############################################################
#
# Palm:Basket �ѤΥ�󥯤���Ϥ��ޤ���
# <pre>
# {{palmbasket �����ͥ��ֹ�,[tiny|small]}}
# </pre>
# tiny �ޤ��� small ����ꤹ��ȡ������դ��Υ�󥯤���Ϥ��ޤ���
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
	    $buf .= "<img src=\"http://newsclip.chem.nagoya-u.ac.jp/palmbasket/PalmBasket_small.png\" alt=\"���Υڡ�����Palm:Basket�������\" border=\"0\">";
	} elsif ($image eq "tiny") {
	    $buf .= "<img src=\"http://newsclip.chem.nagoya-u.ac.jp/palmbasket/PalmBasket_tiny.png\" alt=\"���Υڡ�����Palm:Basket�������\" border=\"0\">";
	} else {
	    $buf .= "���Υڡ�����Palm:Basket�������";
	}
	$buf .= "</a>";
	$buf .= "</div>";

	return $buf;
}

1;
