############################################################
#
# <p>添付したFreeMindファイルをFlashで表示します。</p>
# <p>縦方向の大きさを指定することもできます。</p>
# <pre>
# {{ref_mm ファイル名[,縦サイズ,折り畳みレベル]}}
# </pre>
#
############################################################
package plugin::filtertable::FilterTable;
use strict;
#===========================================================
# コンストラクタ
#===========================================================
sub new {
	my $class = shift;
	my $self = {};
	$self->{count} = 0;
	return bless $self,$class;
}

#===========================================================
# パラグラフメソッド
#===========================================================
sub paragraph {
	my $self = shift;
	my $wiki = shift;
	my $num = shift;

	if($num eq ""){
		return &Util::paragraph_error("番号が指定されていません。","WIKI");
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
