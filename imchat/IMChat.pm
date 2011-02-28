############################################################
# 
# <p>Wiki上でチャットを行うプラグインです。</p>
# <pre>
# {{imchat チャット名[,表示行数]}}
# </pre>
# <p>
#   チャット内容はチャット名のカレンダに記録されていきます。
#   表示行数のデフォルトは16です。
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
  my $lines = shift;
  my $cgi  = $wiki->get_CGI;
  
  # 名前を取得
  my $name = Util::url_decode($cgi->cookie(-name=>'fswiki_post_name'));
  if($name eq ''){
    my $login = $wiki->get_login_info();
    if(defined($login)){
      $name = $login->{id};
    }
  }
  if ($lines eq '') {
    $lines = 16;
  }
  
  # 現在時刻
  my $time = time();
  my ($sec, $min, $hour, $mday, $month, $year, $wday) = localtime($time);
  $year += 1900;
  $month  += 1;

  my $scriptname = $wiki->config('script_name');
  my $pageenc = Util::url_encode($opt);
  my $buf = << "EOD";
<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js"></script>
<table><tr><td valign="top">
最新メッセージ [<a href="$scriptname?action=CALENDAR&amp;name=$pageenc&amp;year=$year&amp;month=$month">過去ログ</a>]
<div id="imchat-message" style="width:400px;overflow:auto;"></div>
</td><td valign="top">
ログイン中ユーザ
<div id="imchat-status"></div>
</td></tr><tr><td colspan="2">
<div id="imchat-form">
名前：<input id="imchat-name" type="text" size="20" value="$name" />
コメント：<input id="imchat-text" type="text" size="50" />
<input id="imchat-submit" type="button" value="投稿" />
</div>
</td></tr>
</table>
<script type="text/javascript">
var imchat = new Object();
  imchat.page = "$opt";
  imchat.name = "$name";
  imchat.lastupdate = 0;
  imchat.onsubmit = function() {
    \$.ajax({url:"$scriptname",
    data:{action: "IMCHAT", type: "submit", page: "$pageenc", name: \$("#imchat-name").val(), message: \$("#imchat-text").val()},
    cache:false,
    success:function() {
      \$("#imchat-text").attr("value", "");
      imchat.refresh();
    }});
    //    alert("submit");
  };
  imchat.refresh = function() {
    // fetch statuses
      \$.ajax({url:"$scriptname",
      data:{action: "IMCHAT", type: "status", page: "$pageenc", name: \$("#imchat-name").val()},
      cache:false,
//      dataType:"json",
      success:function(data) {
//        \$("#imchat-status").html(data);
        data = eval("(" + data + ")");//\$.parseJSON(data);
        if (imchat.lastupdate != data.lastupdate) {
          imchat.lastupdate = data.lastupdate;
          imchat.lasttime = new Date();
          // message list
          var c = "";
          var i = 0;
          if (data.messages.length > $lines) {
            i = data.messages.length - $lines;
          }
          for (; i < data.messages.length; i ++) {
            var m = data.messages[i];
            c += "<b>" + m.name + "</b>: " + m.message + " - <small>" + m.timestamp + "</small><br />";
          }
          \$("#imchat-message").html(c);
        }
        // status
        var c = "";
        for (var i = 0; i < data.status.length; i ++) {
          var s = data.status[i];
          c+= "<li>" + s.name + "</li>";
        }
        \$("#imchat-status").html(c);
      }});
    // TODO: notify new message
  };
  imchat.blink = function() {
    if (imchat.blurtime && imchat.lasttime && imchat.lasttime.getTime() > imchat.blurtime.getTime()) {
      if (document.title.match(/^\\[New/)) {
        document.title = imchat.origtitle;
      } else {
        imchat.origtitle = document.title;
        document.title = "[New message!] " + document.title;
      }
    } else {
      if (document.title.match(/^\\[New/)) {
        document.title = imchat.origtitle;
      }
    }
  };
  imchat.onwindowblur = function() {
    imchat.blurtime = new Date();
  };
  imchat.onwindowfocus = function() {
    imchat.blurtime = null;
  };
\$(function() {
  \$("#imchat-submit").click(imchat.onsubmit);
  \$("#imchat-text").keypress(function(e) {
    if ((e.which && e.which == 13) || (e.keyCode && e.keyCode == 13)) {
      imchat.onsubmit();
    }
  });
  \$(window).blur(imchat.onwindowblur);
  \$(window).focus(imchat.onwindowfocus);
  imchat.refresh();
  setInterval(imchat.refresh, 5000);
  setInterval(imchat.blink, 1000);
});
</script>
EOD
	
	return $buf;
}

1;
