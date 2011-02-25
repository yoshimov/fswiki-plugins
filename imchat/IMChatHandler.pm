############################################################
# 
# Commentプラグインのアクションハンドラ。
# 
############################################################
package plugin::imchat::IMChatHandler;
use Jcode;
#use strict;
#===========================================================
# コンストラクタ
#===========================================================
sub new {
	my $class = shift;
	my $self = {};
	return bless $self,$class;
}

#===========================================================
# コメントの書き込み
#===========================================================
sub do_action {
	my $self = shift;
	my $wiki = shift;
	my $cgi  = $wiki->get_CGI;
	
	my $name    = $cgi->param("name");
        Jcode::convert(\$name, 'euc', 'utf8');
	my $message = $cgi->param("message");
        Jcode::convert(\$message, 'euc', 'utf8');
	my $type    = $cgi->param("type");
	my $page    = $cgi->param("page");

	if ($name eq "") {
		$name = "noname";
	} else {
		# fswiki_post_nameというキーでクッキーをセットする
		my $path   = &Util::cookie_path($wiki);
		my $cookie = $cgi->cookie(-name=>'fswiki_post_name',-value=>Util::url_encode($name),-expires=>'+1M',-path=>$path);
		print "Set-Cookie: ",$cookie->as_string,"\n";
	}
	
  print "Cache-Control: no-cache\n";
  print "Pragma: no-cache\n";
  print "Content-Type: text/html; charset=euc-jp\n\n";
	# フォーマットプラグインへの対応
#	my $format = $wiki->get_edit_format();
#	$name    = $wiki->convert_to_fswiki($name   ,$format,1);
#	$message = $wiki->convert_to_fswiki($message,$format,1);
  my $time = time();

  # 現在時刻
  my ($sec, $min, $hour, $mday, $month, $year, $wday) = localtime($time);
  $year += 1900;
  $month  += 1;

  if ($type eq "status") {
    my $buf = "";

    # statusを読み込む
    my $filename = &Util::make_filename($wiki->config('log_dir'),
                                        &Util::url_encode($page), "imchat");
    my $hash = &Util::load_config_hash(undef,$filename);
    $buf .= "<div id=\"imchat-status\" style=\"position:absolute;left:650px;\">";
    $buf .= "ログイン中ユーザ";
    $hash->{$name} = $time;
    foreach $key (keys %$hash) {
      $ptime = $hash->{$key};
      if ($ptime + 10 < $time) {
        # timeout
        delete $hash->{$key};
      }
      $buf .= "<li>$key</li>\n";
    }
    $buf .= "</div>";
    &Util::save_config_hash(undef,$filename,$hash);

    # messageを読み込む
    $mespage = $page."/".$year."-".$month."-".$mday;
    my $content = $wiki->get_page($mespage);
    $buf .= "<div id=\"imchat-message\" style=\"width:400px;height:400px;overflow:auto;\">";
    $buf .= "最新メッセージ ";
    $buf .= "[<a href=\"".$wiki->config('script_name')."?action=CALENDAR&amp;name=".$page."&amp;year=".$year."&amp;month=".$month."\">";
    $buf .= "過去ログ</a>]";
    # 逆順にする
    my @lines = split(/\n/,$content);
    my $revcont = "";
    while (@lines) {
      $revcont .= pop(@lines)."\n";
    }
    $buf .= $wiki->process_wiki($revcont);
    $buf .= "</div>";
    

    print $buf;
    exit();

  } elsif ($type eq "submit") {
    $mespage = $page."/".$year."-".$month."-".$mday;
    my $content = $wiki->get_page($mespage);
    $content .= "*".$name.": ".$message." - ";
    $content .= $year."/".$month."/".$mday." ".$hour.":".$min.":".$sec."\n";
    $wiki->save_page($mespage, $content);
    exit();
  }
}

1;
