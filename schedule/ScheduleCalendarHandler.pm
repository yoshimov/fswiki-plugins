################################################################################
#
# Calendar�Υ��������ϥ�ɥ顣
#
################################################################################
package plugin::schedule::ScheduleCalendarHandler;
use plugin::schedule::ScheduleCalendar;
use plugin::schedule::ScheduleEdit;
#use strict;
#===============================================================================
# ���󥹥ȥ饯��
#===============================================================================
sub new {
	my $class = shift;
	my $self = {};
	return bless $self,$class;
}

#===============================================================================
# ���������ϥ�ɥ�᥽�å�
#===============================================================================
sub do_action {
    my $self = shift;
    my $wiki = shift;
    my $cgi = $wiki->get_CGI;
    
    my $name     = $cgi->param("name");
    my $year     = $cgi->param("year");
    my $month    = $cgi->param("month");
    my $mday     = $cgi->param("mday");
    my $holidaytmp = $cgi->param("holiday");
    
    if($name eq "" || !Util::check_numeric($year) || !Util::check_numeric($month)){
	return $wiki->error("�ѥ�᡼���������Ǥ���");
	
    }

    my @holiday = split(/,/, $holidaytmp);
    $wiki->set_title("$name/$year-$month");
    my $buf = "<h3>".Util::escapeHTML($name)." �������塼��</h3>";
    $buf .= plugin::schedule::ScheduleCalendar::make_calendar($wiki,$year,$month,$mday,$name,@holiday);
    $buf .= plugin::schedule::ScheduleEdit::make_edit_form($wiki,$name,$year,$month,$mday);
    return $buf;
}

1;
