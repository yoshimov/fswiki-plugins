################################################################################
#
# Calendar�Υ��������ϥ�ɥ顣
#
################################################################################
package plugin::schedule::ScheduleDayHandler;
use plugin::schedule::Schedule;
use Jcode;
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
    my $nameenc  = Util::url_encode($name);
    my $year     = $cgi->param("year");
    my $month    = $cgi->param("month");
    my $mday     = $cgi->param("mday");
    my $type     = $cgi->param("type");
    my $script   = $wiki->config('script_name');
    my $buf = "";
    
    if($name eq "" || ($year && !Util::check_numeric($year))
       || ($month && !Util::check_numeric($month))
       || ($mday && !Util::check_numeric($mday))) {
	$buf .= "�ѥ�᡼���������Ǥ���";
    } else {
	my $schedule = new plugin::schedule::Schedule;
	my $page_content = $schedule->get_page_content($wiki, $name, $year, $month);
	if ($type eq "edit") {
	    # �����ӥ塼��ɽ������
	    my $content = plugin::schedule::Schedule::extract_schedule_source($page_content, $mday);
	    $buf .= "<textarea cols='20' rows='4' id='day-$month-$mday-text'>$content</textarea>";
	    $buf .= "<br/>";
	    $buf .= "<a href=\"javascript:day_submit($year,$month,$mday)\">����</a> / ";
	    $buf .= "<a href=\"javascript:day_reload($year,$month,$mday)\">����󥻥�</a>\n";
	} elsif ($type eq "view") {
	    # ɽ�����Ƥι����ʥ���󥻥����
	    my $content = plugin::schedule::Schedule::extract_schedule($page_content, $mday);
	    $buf .= $content;
	} elsif ($type eq "submit") {
	    # �ǡ����򹹿�����
	    my $text = $cgi->param("text");
	    Jcode::convert(\$text, 'euc', 'utf8');
	    # ���դ��䴰
	    my @lines = split(/\n/,$text);
	    $text = "";
	    foreach my $line (@lines) {
		if ($line =~ /^[,\*]\s*\d+\s*,.*/) {
		    $text .= $line."\n";
		} elsif ($line ne "") {
		    # ���դ��ɲä���
		    $text .= ",$mday,$line\n";
		}
	    }
	    # �������ʳ��Υ������塼������
	    my $content = plugin::schedule::Schedule::extract_schedule_othersource($page_content, $mday);
	    $schedule->save_page_content($wiki,$name,$year,$month,$content."\n".$text);
	    # ɽ�����Ƥι���
	    $content = plugin::schedule::Schedule::extract_schedule($text, $mday);
	    $buf .= $content;
	} elsif ($type eq "manifest") {
	    # Google Gears��Manifest���֤�
	    my $time = time();
	    my ($sec, $min, $hour, $mday, $thismonth, $thisyear, $wday) = localtime($time);
	    $thisyear += 1900;
	    $thismonth  += 1;
	    my $nextmonth = $thismonth + 1;
	    my $nextyear = $thisyear;
	    if ($nextmonth > 12) {
		$nextyear += 1;
		$nextmonth -= 12;
	    }
	    my $prevmonth = $thismonth - 1;
	    my $prevyear = $thisyear;
	    if ($prevmonth < 1) {
		$prevyear -= 1;
		$prevmonth += 12;
	    }

	    my $version = $wiki->get_last_modified($name."/".$thisyear."-".$thismonth);
	    my $last = $wiki->get_last_modified($name."/".$nextyear."-".$nextmonth);
	    if (!$version || $version < $last) {
		$version = $last;
	    }
	    $last = $wiki->get_last_modified($name."/".$prevyear."-".$prevmonth);
	    if (!$version || $version < $last) {
		$version = $last;
	    }
	    my $theme = $wiki->config('theme');
	    $buf .= << "EOD";
{
    "betaManifestVersion" : 1,
    "version": "v$version",
    "entries": [
	{ "url": "$script?page=$nameenc" },
	{ "url": "$script?action=SCHEDULECALENDAR&year=$thisyear&month=$thismonth&name=$nameenc" },
	{ "url": "$script?action=SCHEDULECALENDAR&year=$nextyear&month=$nextmonth&name=$nameenc" },
	{ "url": "$script?action=SCHEDULECALENDAR&year=$prevyear&month=$prevmonth&name=$nameenc" },
	{ "url": "gears_init.js" },
	{ "url": "theme/$theme/$theme.css" }
	]
}
EOD
	}
    }

    print "Content-Type: text/html; charset=euc-jp\n\n";
    print $buf;

    exit();
}

1;
