############################################################
#
# <p>ź�դ���FreeMind�ե������Flash��ɽ�����ޤ���</p>
# <p>���������礭������ꤹ�뤳�Ȥ�Ǥ��ޤ���</p>
# <pre>
# {{ref_mm �ե�����̾[,�ĥ�����,�ޤ���ߥ�٥�]}}
# </pre>
#
############################################################
package plugin::filtertable::FilterTable;
use strict;
#===========================================================
# ���󥹥ȥ饯��
#===========================================================
sub new {
	my $class = shift;
	my $self = {};
	$self->{count} = 0;
	return bless $self,$class;
}

#===========================================================
# �ѥ饰��ե᥽�å�
#===========================================================
sub paragraph {
	my $self = shift;
	my $wiki = shift;
	my $num = shift;

	if($num eq ""){
		return &Util::paragraph_error("�ֹ椬���ꤵ��Ƥ��ޤ���","WIKI");
	}

	my $buf = <<"EOB";
<script type="text/javascript" src="theme/jquery.columnfilters.js">
</script>
<script type="text/javascript">
\$('#table$num').columnFilters();
</script>
EOB
	return $buf;
}

1;
