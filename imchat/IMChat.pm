############################################################
# 
# <p>Wiki��ǥ���åȤ�Ԥ��ץ饰����Ǥ���</p>
# <pre>
# {{imchat ����å�̾}}
# </pre>
# <p>
#   ����å����Ƥϥ���å�̾�Υ������˵�Ͽ����Ƥ����ޤ���
# </p>
# 
############################################################
package plugin::imchat::IMChat;
use strict;
#===========================================================
# ���󥹥ȥ饯��
#===========================================================
sub new {
	my $class = shift;
	my $self = {};
	return bless $self,$class;
}

#===========================================================
# �����ȥե�����
#===========================================================
sub paragraph {
  my $self = shift;
  my $wiki = shift;
  my $opt  = shift;
  my $cgi  = $wiki->get_CGI;
  
  # ̾�������
  my $name = Util::url_decode($cgi->cookie(-name=>'fswiki_post_name'));
  if($name eq ''){
    my $login = $wiki->get_login_info();
    if(defined($login)){
      $name = $login->{id};
    }
  }
  # ���߻���
  my $time = time();
  my ($sec, $min, $hour, $mday, $month, $year, $wday) = localtime($time);
  $year += 1900;
  $month  += 1;

  my $scriptname = $wiki->config('script_name');
  my $pageenc = Util::url_encode($opt);
  my $buf = << "EOD";
<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js"></script>
<table><tr><td valign="top">
�ǿ���å����� [<a href="$scriptname?action=CALENDAR&amp;name=$pageenc&amp;year=$year&amp;month=$month">����</a>]
<div id="imchat-message" style="width:400px;overflow:auto;"></div>
</td><td valign="top">
��������桼��
<div id="imchat-status"></div>
</td></tr><tr><td colspan="2">
<div id="imchat-form">
̾����<input id="imchat-name" type="text" size="20" value="$name" />
�����ȡ�<input id="imchat-text" type="text" size="50" />
<input id="imchat-submit" type="button" value="���" />
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
          if (data.messages.length > 15) {
            i = data.messages.length - 15;
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
\$(function() {
  \$("#imchat-submit").click(imchat.onsubmit);
  \$("#imchat-text").keypress(function(e) {
    if ((e.which && e.which == 13) || (e.keyCode && e.keyCode == 13)) {
      imchat.onsubmit();
    }
  });
  imchat.refresh();
  setInterval(imchat.refresh, 5000);
});
</script>
EOD
	
	return $buf;
}

1;
