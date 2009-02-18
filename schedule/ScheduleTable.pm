################################################################################
#
# �������塼������դ����ɽ�����ޤ���
# ���ץ����ˡ�Ʊ���ơ��֥����ɽ�����륹�����塼��̾����󤷤Ƥ���������
# <pre>
# {{scheduletable ɽ������,�������塼��̾1,�������塼��̾2,,}}
# </pre>
#
################################################################################
package plugin::schedule::ScheduleTable;
use plugin::schedule::Schedule;
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
# ����饤��᥽�å�
#===============================================================================
sub paragraph {
    my $self  = shift;
    my $wiki  = shift;
    my $count = shift;
    my @namelist  = @_;
    my $buf = "";

    if($#namelist == -1){
	return "<font class=\"error\">�������塼��̾�����ꤵ��Ƥ��ޤ���</font>";
    }

    my $time = time();
    my $odd = "false";

    $buf .= "<table>";
    my @week = ("��","��","��","��","��","��","��");

    my $schedule = new plugin::schedule::Schedule;

    $buf .= make_schedule_header($wiki, @namelist);

    for (my $i = 0; $i < $count; $i++) {
	my ($sec, $min, $hour, $mday, $month, $year, $wday) = localtime($time);
	$year += 1900;
	$month  += 1;

	my $holidayname = $schedule->get_holiday_name($wiki, $year, $month, $mday);

	$buf .= "<tr>";
	if ($holidayname eq "" && $wday != 0 && $wday != 6) {
	    $buf .= "<th>";
	} else {
	    $buf .= "<th style=\"background-color:#ffcccc;\">";
	}
	$buf .= $month."��".$mday."��(".$week[$wday].")";
	$buf .= "</th>";

	$buf .= make_schedule_row($wiki, $schedule, $year, $month, $mday, $odd, @namelist);
	$buf .= "</tr>";
	$time += 24 * 60 * 60;
	if ($odd eq "true") {
	    $odd = "false";
	} else {
	    $odd = "true";
	}
	if ($wday == 0) {
	    $buf .= make_schedule_header($wiki, @namelist);
	}
    }

    $buf .= "</table>";

    return $buf;
}

sub make_schedule_header {
    my $wiki = shift;
    my @namelist = @_;
    my $buf = "";

    $buf .= "<tr><th>ô��</th>";
    foreach my $name (@namelist) {
	my $baselink = plugin::schedule::Schedule::make_schedule_anchor($wiki, $name);
	$buf .= "<th>$baselink</th>";
    }
    $buf .= "</tr>";
    return $buf;
}

sub make_schedule_row {
    my $wiki = shift;
    my $schedule = shift;
    my $year = shift;
    my $month = shift;
    my $mday = shift;
    my $odd = shift;
    my @namelist = @_;
    my $buf = "";
    my $bgcolor = "#ffffff";
    if ($odd eq "true") {
	$bgcolor = "#eeeeff";
    }

    foreach my $name (@namelist) {
	my $content = $schedule->get_page_content($wiki, $name, $year, $month);
	my $sched = &plugin::schedule::Schedule::extract_schedule($content, $mday);
	my $style = "background-color: $bgcolor; ";
	$buf .= "<td style=\"$style\">$sched</td>";
    }
    return $buf;
}

1;
