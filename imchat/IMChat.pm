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
  
  my $page = $cgi->param("page");
  
  if(!defined($self->{$page})){
    $self->{$page} = 1;
  } else {
    $self->{$page}++;
  }
  my $id = $self->{$page};

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
  my $jq_file = "jquery-1.5.1.min.js";
  my $buf = "";
  if (-e $wiki->config('theme_dir')."/".$jq_file) {
    my $theme_uri = $wiki->config('theme_uri');
    $buf .= << "EOD";
<script src="$theme_uri/$jq_file"></script>
EOD
  } else {
    $buf .= << "EOD";
<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.5.1/jquery.min.js"></script>
EOD
  }
  $buf .= << "EOD";
<table><tr><td valign="top">
<div id="imchat-messageheader$id">
最新メッセージ [<a href="$scriptname?action=CALENDAR&amp;name=$pageenc&amp;year=$year&amp;month=$month">過去ログ</a>]
</div>
<div id="imchat-message$id" style="width:500px;overflow:auto;"></div>
</td><td valign="top">
オンラインユーザ
<div id="imchat-status$id"></div>
</td></tr><tr><td colspan="2">
<div class="imchat-form">
名前：<input id="imchat-name$id" type="text" size="20" value="$name" />
コメント：<input id="imchat-text$id" type="text" size="50" />
<input id="imchat-submit$id" type="button" value="投稿" />
</div>
</td></tr>
</table>
<script type="text/javascript">
(function() {
  var imchat = new Object();
  imchat.page = "$opt";
  imchat.name = "$name";
  imchat.lastupdate = 0;
  imchat.onsubmit = function() {
    \$.ajax({url:"$scriptname",
    data:{action: "IMCHAT", type: "submit", page: "$pageenc", name: \$("#imchat-name$id").val(), message: \$("#imchat-text$id").val()},
    cache:false,
    success:function() {
      \$("#imchat-text$id").attr("value", "");
      imchat.refresh();
    }});
  };
  imchat.refresh = function() {
    // fetch statuses
      \$.ajax({url:"$scriptname",
      data:{action: "IMCHAT", type: "status", page: "$pageenc", name: \$("#imchat-name$id").val(), focus: (imchat.blurtime ? "0" : "1")},
      cache:false,
//      dataType:"json",
      success:function(data) {
        data = eval("(" + data + ")");//\$.parseJSON(data);
        if (imchat.lastupdate != data.lastupdate) {
          // message list
          var c = "";
          var i = 0;
          if (data.messages.length > $lines) {
            i = data.messages.length - $lines;
          }
          for (; i < data.messages.length; i ++) {
            var m = data.messages[i];
            var str = m.message;
            var nameexp = "@" + \$("#imchat-name$id").val();
            if (str.match(nameexp)) {
              str = "<font color='red'>" + str + "</font>";
            }
            c += "<b>" + m.name + "</b>: " + str + " - <small>" + m.timestamp + "</small><br />";
          }
          \$("#imchat-message$id").html(c);
          // desktop notify for chrome
          if (imchat.lastupdate && imchat.blurtime && window.webkitNotifications) {
            imchat.showNotification();
          }
          imchat.lastupdate = data.lastupdate;
          imchat.lasttime = new Date();
        }
        // status
        var c = "";
        for (var i = 0; i < data.status.length; i ++) {
          var s = data.status[i];
          c += "<li>" + s.name;
          if (s.focus == "0") {
            c += "(退席中)";
          }
          c += "</li>";
        }
        \$("#imchat-status$id").html(c);
      }});
  };
  imchat.showNotification = function() {
    if (window.webkitNotifications.checkPermission() == 0) {
      var title = 'Wiki Chat Notification';
      var message = 'New message has posted.';
      var n = window.webkitNotifications.createNotification(null, title, message);
      n.ondisplay = function() {
        setTimeout(function() { n.cancel(); }, 10000);
      };
      n.show();
    }
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
  \$("#imchat-submit$id").click(imchat.onsubmit);
  \$("#imchat-text$id").keypress(function(e) {
    if ((e.which && e.which == 13) || (e.keyCode && e.keyCode == 13)) {
      imchat.onsubmit();
    }
  });
  \$(window).blur(imchat.onwindowblur);
  \$(window).focus(imchat.onwindowfocus);
  if (window.webkitNotifications && window.webkitNotifications.checkPermission() != 0) {
    // create permission button
    var b = \$(document.createElement("input"));
    b.attr('type', 'button');
    b.attr('value', 'Allow notification permissions');
    b.click(function() {
      window.webkitNotifications.requestPermission();
    });
    \$("#imchat-messageheader$id").append(b);
  }
  imchat.refresh();
  setInterval(imchat.refresh, 5000);
  setInterval(imchat.blink, 1000);
});
})();
</script>
EOD
	
	return $buf;
}

1;
