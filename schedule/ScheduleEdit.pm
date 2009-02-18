################################################################################
#
# スケジュールの登録フォームを表示します。
# 登録先スケジュール名を指定してください。
# <pre>
# {{scheduleedit スケジュール名}}
# </pre>
#
################################################################################
package plugin::schedule::ScheduleEdit;
#use strict;
use plugin::schedule::ScheduleCalendar;
#===============================================================================
# コンストラクタ
#===============================================================================
sub new {
	my $class = shift;
	my $self = {};
	return bless $self,$class;
}
#===============================================================================
# インラインメソッド
#===============================================================================
sub paragraph {
    my $self  = shift;
    my $wiki  = shift;
    my $name  = shift;
    my $buf = "";
    
    if ($name eq ""){
	return "<font class=\"error\">スケジュール名が指定されていません。</font>";
    }
    if(!$wiki->can_modify_page($name)){
	return "<font class=\"error\">ページの編集は許可されていません。</font>";
    }

    return "";

    # 今月
#    my $time = time();
#    my ($sec, $min, $hour, $mday, $month, $year, $wday) = localtime($time);
#    $year += 1900;
#    $month  += 1;

#    $buf = make_edit_form($wiki, $name, $year, $month, $mday);
#    return $buf;
}

sub make_edit_form {
    my $wiki = shift;
    my $name = shift;
    my $cyear = shift;
    my $cmonth = shift;
    my $cday = shift;
    my $buf = "";

    #入力フォーム
    $buf .= "<table><tr><th>スケジュール登録</th></tr><tr><td>";
    $buf .= &make_entry_form($wiki, $name, $cyear, $cmonth, $cday);
    $buf .= "</td></tr>"
	."<tr><th>スケジュール編集</th></tr><tr><td>";

    my $time = plugin::schedule::ScheduleCalendar::get_specified_time($cyear, $cmonth);
    my ($sec, $min, $hour, $mday, $month, $year, $wday) = localtime($time);
    $year += 1900;
    $month  += 1;

    # 先月まで移動
    while ($month == $cmonth) {
	$time -= 24 * 60 * 60;
	($sec, $min, $hour, $mday, $month, $year, $wday) = localtime($time);
	$year += 1900;
	$month  += 1;
    }

    # 先月編集
    $buf .= &make_edit_anchor($wiki, $name, $year, $month);
    $buf .= "<br>";

    $time = plugin::schedule::ScheduleCalendar::get_specified_time($cyear, $cmonth);
    ($sec, $min, $hour, $mday, $month, $year, $wday) = localtime($time);
    $year += 1900;
    $month  += 1;

    # 今月編集
    $buf .= &make_edit_anchor($wiki, $name, $year, $month);
    $buf .= "<br>";

    # 来月まで移動
    while ($month == $cmonth) {
	$time += 24 * 60 * 60;
	($sec, $min, $hour, $mday, $month, $year, $wday) = localtime($time);
	$year += 1900;
	$month  += 1;
    }

    # 来月ページ
    $buf .= &make_edit_anchor($wiki, $name, $year, $month);
    $buf .= "<br>";

    $buf .= "</td></tr></table>";
    return $buf;
}

sub make_edit_anchor {
    my $wiki  = shift;
    my $name  = shift;
    my $year  = shift;
    my $month = shift;
    my $buf = "";
    my $pagename = $name."/".$year."-".$month;

    $buf .= "<a href=\"".$wiki->config('script_name')
	."?action=EDIT"
	."&page=".&Util::url_encode($pagename)."\">"
	."$year年$month月のスケジュール</a>";

    return $buf;
}

sub make_entry_form {
    my $wiki = shift;
    my $name = shift;
    my $year = shift;
    my $month = shift;
    my $mday = shift;
    my $cgi  = $wiki->get_CGI;
    my $buf = "";

    # 日付部分
    $buf .= "<form name=\"scheduleedit\" action=\"".$wiki->config('script_name')."\" method=\"post\">"
	."<input type=\"hidden\" name=\"name\" value=\"".$name."\">"
	."<input type=\"hidden\" name=\"action\" value=\"dummy\">"
	."<input type=\"hidden\" name=\"page\" value=\"$name\">"
	."<input name=\"year\" size=\"6\" value=\"$year\">年"
	."<input name=\"month\" size=\"3\" value=\"$month\">月"
	."<input name=\"day\" size=\"3\" value=\"$mday\">日: <ul>";

    # スケジュール登録
    $buf .= "スケジュール内容:<input name=\"schedule_memo\" size=\"40\">"
	."<input type=\"submit\" value=\"スケジュール登録\" onclick=\"scheduleedit.action.value='SCHEDULEEDIT';\"><br>";

    # 作業実績

    # プロジェクト名一覧取得
    $projects_content = $wiki->get_page("ScheduleProjects");
    my @project_list;
    while ($projects_content =~ m/(^|\n)\*\s*([^\n\*\[\]]+)/mg) {
	push(@project_list, $2);
    }

    $buf .= "プロジェクト名:<select name=\"project\">";
    foreach (@project_list) {
	$buf .= "<option value=\"$_\">$_</option>";
    }
    $buf .= "</select> "
	."作業時間:<input name=\"duration\" size=\"5\" value=\"0\"> "
	."作業内容:<input name=\"work_memo\" size=\"40\">"
	."<input type=\"submit\" value=\"作業実績登録\" onclick=\"scheduleedit.action.value='SCHEDULEWORKENTRY';\"><br>";

    # コメント登録
    my $pname = '';
    $pname = $cgi->cookie(-name=>'post_name');
    if($pname eq ''){
	my $login = $wiki->get_login_info();
	if(defined($login)){
	    $pname = $login->{id};
	}
    }
    $buf .= "お名前:<input name=\"poster\" size=\"10\" value=\"$pname\">";
    $buf .= "コメント:<input name=\"comment_memo\" size=\"40\">";
    $buf .= "<input type=\"submit\" value=\"作業実績コメント登録\" onclick=\"scheduleedit.action.value='SCHEDULECOMMENT';\"><br>";

    $buf .= "</ul></form>";

    return $buf;
}

1;
