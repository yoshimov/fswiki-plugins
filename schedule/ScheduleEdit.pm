################################################################################
#
# �������塼�����Ͽ�ե������ɽ�����ޤ���
# ��Ͽ�襹�����塼��̾����ꤷ�Ƥ���������
# <pre>
# {{scheduleedit �������塼��̾}}
# </pre>
#
################################################################################
package plugin::schedule::ScheduleEdit;
#use strict;
use plugin::schedule::ScheduleCalendar;
#===============================================================================
# ���󥹥ȥ饯��
#===============================================================================
sub new {
	my $class = shift;
	my $self = {};
	return bless $self,$class;
}
#===============================================================================
# ����饤��᥽�å�
#===============================================================================
sub paragraph {
    my $self  = shift;
    my $wiki  = shift;
    my $name  = shift;
    my $buf = "";
    
    if ($name eq ""){
	return "<font class=\"error\">�������塼��̾�����ꤵ��Ƥ��ޤ���</font>";
    }
    if(!$wiki->can_modify_page($name)){
	return "<font class=\"error\">�ڡ������Խ��ϵ��Ĥ���Ƥ��ޤ���</font>";
    }

    return "";

    # ����
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

    #���ϥե�����
    $buf .= "<table><tr><th>�������塼����Ͽ</th></tr><tr><td>";
    $buf .= &make_entry_form($wiki, $name, $cyear, $cmonth, $cday);
    $buf .= "</td></tr>"
	."<tr><th>�������塼���Խ�</th></tr><tr><td>";

    my $time = plugin::schedule::ScheduleCalendar::get_specified_time($cyear, $cmonth);
    my ($sec, $min, $hour, $mday, $month, $year, $wday) = localtime($time);
    $year += 1900;
    $month  += 1;

    # ���ޤǰ�ư
    while ($month == $cmonth) {
	$time -= 24 * 60 * 60;
	($sec, $min, $hour, $mday, $month, $year, $wday) = localtime($time);
	$year += 1900;
	$month  += 1;
    }

    # ����Խ�
    $buf .= &make_edit_anchor($wiki, $name, $year, $month);
    $buf .= "<br>";

    $time = plugin::schedule::ScheduleCalendar::get_specified_time($cyear, $cmonth);
    ($sec, $min, $hour, $mday, $month, $year, $wday) = localtime($time);
    $year += 1900;
    $month  += 1;

    # �����Խ�
    $buf .= &make_edit_anchor($wiki, $name, $year, $month);
    $buf .= "<br>";

    # ���ޤǰ�ư
    while ($month == $cmonth) {
	$time += 24 * 60 * 60;
	($sec, $min, $hour, $mday, $month, $year, $wday) = localtime($time);
	$year += 1900;
	$month  += 1;
    }

    # ���ڡ���
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
	."$yearǯ$month��Υ������塼��</a>";

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

    # ������ʬ
    $buf .= "<form name=\"scheduleedit\" action=\"".$wiki->config('script_name')."\" method=\"post\">"
	."<input type=\"hidden\" name=\"name\" value=\"".$name."\">"
	."<input type=\"hidden\" name=\"action\" value=\"dummy\">"
	."<input type=\"hidden\" name=\"page\" value=\"$name\">"
	."<input name=\"year\" size=\"6\" value=\"$year\">ǯ"
	."<input name=\"month\" size=\"3\" value=\"$month\">��"
	."<input name=\"day\" size=\"3\" value=\"$mday\">��: <ul>";

    # �������塼����Ͽ
    $buf .= "�������塼������:<input name=\"schedule_memo\" size=\"40\">"
	."<input type=\"submit\" value=\"�������塼����Ͽ\" onclick=\"scheduleedit.action.value='SCHEDULEEDIT';\"><br>";

    # ��ȼ���

    # �ץ�������̾��������
    $projects_content = $wiki->get_page("ScheduleProjects");
    my @project_list;
    while ($projects_content =~ m/(^|\n)\*\s*([^\n\*\[\]]+)/mg) {
	push(@project_list, $2);
    }

    $buf .= "�ץ�������̾:<select name=\"project\">";
    foreach (@project_list) {
	$buf .= "<option value=\"$_\">$_</option>";
    }
    $buf .= "</select> "
	."��Ȼ���:<input name=\"duration\" size=\"5\" value=\"0\"> "
	."�������:<input name=\"work_memo\" size=\"40\">"
	."<input type=\"submit\" value=\"��ȼ�����Ͽ\" onclick=\"scheduleedit.action.value='SCHEDULEWORKENTRY';\"><br>";

    # ��������Ͽ
    my $pname = '';
    $pname = $cgi->cookie(-name=>'post_name');
    if($pname eq ''){
	my $login = $wiki->get_login_info();
	if(defined($login)){
	    $pname = $login->{id};
	}
    }
    $buf .= "��̾��:<input name=\"poster\" size=\"10\" value=\"$pname\">";
    $buf .= "������:<input name=\"comment_memo\" size=\"40\">";
    $buf .= "<input type=\"submit\" value=\"��ȼ��ӥ�������Ͽ\" onclick=\"scheduleedit.action.value='SCHEDULECOMMENT';\"><br>";

    $buf .= "</ul></form>";

    return $buf;
}

1;
