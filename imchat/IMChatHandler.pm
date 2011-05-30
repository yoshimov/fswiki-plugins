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
  my $focus = $cgi->param("focus");
  
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

  # 現在時刻
  my $time = time();
  my ($sec, $min, $hour, $mday, $month, $year, $wday) = localtime($time);
  $year += 1900;
  $month  += 1;

  if ($type eq "status") {
    my $buf = "{";

    # messageを読み込む
    $mespage = $page."/".$year."-".$month."-".$mday;
    $buf .= "\"lastupdate\":\"".$wiki->get_last_modified($mespage)."\"";
    
    my $content = $wiki->get_page($mespage);
    $buf .= ",\"messages\":[";
    my $first = 1;
    my $count = 0;
    while ($content =~ m/(\n|^)\*\s*([^:\n\s]*)\s*:\s*([^\n]*)\s+\-\s+([0-9:\/]+[^\n]*)\s*($|\n)/mg) {
      my $mname = $2;
      my $mmes = $3;
      my $mtime = $4;
      unless ($first) {
        $buf .= ",";
      } else {
        $first = 0;
      }
      $buf .= "{\"name\":\"".$mname."\",\"message\":\"".$mmes."\",\"timestamp\":\"".$mtime."\"}";
#      if ($count++ > 20) {
#        last;
#      }
    }
    $buf .= "]";
    
    # statusを読み込む
    my $filename = &Util::make_filename($wiki->config('log_dir'),
                                        &Util::url_encode($page), "imchat");
    my $hash = &Util::load_config_hash(undef,$filename);
    unless ($name eq "noname") {
      $hash->{$name} = $time;
      $hash->{$name."#focus"} = $focus;
    }
    $buf .= ",status:[";
    my $first = 1;
    foreach $key (keys %$hash) {
      if ($key =~ /#focus$/) {
        next;
      }
      $ptime = $hash->{$key};
      if ($ptime + 10 < $time) {
        # timeout
        delete $hash->{$key};
        delete $hash->{$key."#focus"};
      }
      unless ($first) {
        $buf .= ",";
      } else {
        $first = 0;
      }
      $buf .= "{\"name\":\"".$key."\",\"lastupdate\":\"".$hash->{$key}."\",\"focus\":\"".$hash->{$key."#focus"}."\"}";
    }
    $buf .= "]";
    &Util::save_config_hash(undef,$filename,$hash);

    $buf .= "}";
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
