package plugin::schedule::ScheduleWorkEntryHandler;
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
    my $memo = $cgi->param("work_memo");
    my $duration = $cgi->param("duration");
    my $project = $cgi->param("project");

    my $content;
    my $pagename = $name."/".$year."-".$month;

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
    $content .= "*$day,[$project] ".$duration."h,$memo\n";
    $wiki->save_page($pagename,$content);

    return $wiki->call_handler("");
}

1;
