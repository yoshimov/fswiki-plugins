package plugin::schedule::ScheduleCommentHandler;
#use strict;

sub new {
    my $class = shift;
    my $self = {};
    return bless $self,$class;
}

sub do_action {
    my $self = shift;
    my $wiki = shift;
    my $cgi = $wiki->get_CGI;

    my $name = $cgi->param("name");
    my $year = int($cgi->param("year"));
    my $month = int($cgi->param("month"));
    my $day = int($cgi->param("day"));
    my $memo = $cgi->param("comment_memo");
    my $pname = $cgi->param("poster");

    my $content;
    my $pagename = $name."/".$year."-".$month;

    if($pname eq ""){
	$pname = "名無しさん";
    } else {
	# post_nameというキーでクッキーをセットする
	my $path   = &Util::cookie_path($wiki);
	my $cookie = $cgi->cookie(-name=>'post_name',-value=>$pname,-expires=>'+1M',-path=>$path);
	print "Set-Cookie: ",$cookie->as_string,"\n";
    }

    if(!$wiki->can_modify_page($pagename)){
	return $wiki->error("ページの編集は許可されていません。");
    }

    if ($wiki->page_exists($pagename)) {
	$content = $wiki->get_page($pagename);
    } else {
	$content = ",日付,スケジュール\n";
    }

    if ($content =~ m/\n$/) {
    } else {
	$content .= "\n";
    }
    $content .= "*$day,$memo - $pname (".Util::format_date(time()).")\n";
    $wiki->save_page($pagename,$content);

    return $wiki->call_handler("");
}

1;
