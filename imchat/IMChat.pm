############################################################
# 
# <p>Wiki上でチャットを行うプラグインです。</p>
# <pre>
# {{imchat チャット名}}
# </pre>
# <p>
#   チャット内容はチャット名のカレンダに記録されていきます。
# </p>
# 
############################################################
package plugin::imchat::IMChat;
use strict;
#===========================================================
# コンストラクタ
#===========================================================
sub new {
	my $class = shift;
	my $self = {};
	return bless $self,$class;
}

#===========================================================
# コメントフォーム
#===========================================================
sub paragraph {
	my $self = shift;
	my $wiki = shift;
	my $opt  = shift;
	my $cgi  = $wiki->get_CGI;
	
	# 名前を取得
	my $name = Util::url_decode($cgi->cookie(-name=>'fswiki_post_name'));
	if($name eq ''){
		my $login = $wiki->get_login_info();
		if(defined($login)){
			$name = $login->{id};
		}
	}
  my $scriptname = $wiki->config('script_name');
  my $pageenc = Util::url_encode($opt);
  my $buf = << "EOD";
<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js"></script>
<div id="imchat-message"></div>
<div id="imchat-status"></div>
<div id="imchat-form">
名前：<input id="imchat-name" type="text" size="20" value="$name" />
コメント：<input id="imchat-text" type="text" size="50" />
<input id="imchat-submit" type="button" value="投稿" />
</div>
<script type="text/javascript">
var imchat = new Object();
  imchat.page = "$opt";
  imchat.name = "$name";
  imchat.onchangename = function() {
    imchat.name = \$("#imchat-name").val();
    alert(imchat.page + imchat.name);
  };
  imchat.onsubmit = function() {
    alert("submit");
  };
  imchat.refresh = function() {
    // fetch statuses
      \$.get("$scriptname?action=IMCHAT&type=status&page=$pageenc&name=" + imchat.name, function(data) {
        \$("#imchat-status").html(data);
      });
    // fetch messages
      \$.get("$scriptname?action=IMCHAT&type=get&page=$pageenc&name=" + imchat.name, function(data) {
        \$("#imchat-message").html(data);
      });
  };
\$(function() {
  \$("#imchat-submit").click(imchat.onsubmit);
  \$("#imchat-name").change(imchat.onchangename);
  imchat.refresh();
  setInterval(imchat.refresh, 5000);
});
</script>
EOD
	
	return $buf;
}

1;
