################################################################################
#
# スケジュールを表示します。
# オプションに、同じテーブル内に表示するスケジュール名を列挙してください。
# <pre>
# {{schedule 表示日数,スケジュール名1,スケジュール名2,,}}
# </pre>
#
################################################################################
package plugin::schedule::Schedule;
#use strict;
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
	my $count = shift;
	my @namelist  = @_;
	my $buf = "";

	if($#namelist == -1){
		return "<font class=\"error\">スケジュール名が指定されていません。</font>";
	}

	my $time = time();
	my $odd = "false";

	$buf .= "<table>";
	foreach (@namelist) {
	    $buf .= $self->make_schedule_row($wiki,$_,$time,$count,$odd);
	    if ($odd eq "true") {
		$odd = "false";
	    } else {
		$odd = "true";
	    }
	}
	$buf .= "</table>";

	return $buf;
}

sub make_schedule_row {
    my $self = shift;
    my $wiki = shift;
    my $basepage = shift;
    my $time = shift;
    my $count = shift;
    my $odd = shift;
    my $buf = "";
    my $rows = 0;
    my $content;
    my $bgcolor = "#ffffff";
    if ($odd eq "true") {
	$bgcolor = "#eeeeff";
    }
    my @week = ("日","月","火","水","木","金","土");

    for (my $i = 0; $i < $count; $i++) {
	my ($sec, $min, $hour, $mday, $month, $year, $wday) = localtime($time);
	$year += 1900;
	$month  += 1;

	$content = $self->get_page_content($wiki, $basepage, $year, $month);

	my $sched = extract_schedule($content, $mday);
	if ($sched ne "") {
	    my $style = "background-color: $bgcolor; ";
	    my $dstyle = $style;
	    if ($i eq 0) {
		$dstyle .= "color: red; font-weight: bold;";
	    }
	    my $holidayname = $self->get_holiday_name($wiki, $year, $month, $mday);
	    if ($holidayname ne "" || $wday == 0 || $wday == 6) {
		$dstyle .= "background-color: #ffcccc;";
	    }
	    $buf .= "<tr><td style=\"$dstyle\">";
	    $buf .= $month."月".$mday."日(".$week[$wday].")";
	    $buf .= "</td><td style=\"$style\">".$sched."</td></tr>";
	    $rows ++;
	}
	$time += 24 * 60 * 60;
    }
    my $baselink = make_schedule_anchor($wiki, $basepage);
    if ($rows eq 0) {
	$buf = "<tr><th>$baselink</th></tr>";
	return $buf;
    }
    my $head = "<tr><th rowspan=\"$rows\">$baselink</th>";
    $buf =~ s/^\<tr\>/$head/;
    return $buf;
}

sub get_holiday_name {
    my $self = shift;
    my $wiki = shift;
    my $year = shift;
    my $month = shift;
    my $day = shift;

    my $pagename = "ScheduleHolidays/$year";
    my $pagename2 = "ScheduleHoliday";
    my $holiday = "";

    if (defined($self->{$pagename})) {
	$holiday = $self->{$pagename};
    } elsif ($wiki->page_exists($pagename)) {
	$holiday = $wiki->get_page($pagename);
	$self->{$pagename} = $holiday;
    } elsif ($wiki->page_exists($pagename2)) {
	$holiday = $wiki->get_page($pagename2);
	$self->{$pagename} = $holiday;
    }
    if ($holiday =~ m/(^|\n),\s*0*$month[\/\.\-]0*$day\s*,(.*)(\n|$)/) {
	return $2;
    }
    return "";
}

sub get_page_content {
    my $self = shift;
    my $wiki = shift;
    my $name = shift;
    my $year = shift;
    my $month = shift;

    my $page = $name."/".$year."-".$month;
    my $content;

    if ($wiki->page_exists($page)) {
	my %pagecache;
	if (defined($self->{pagecache})) {
	    %pagecache = $self->{pagecache};
	}
	if (%pagecache->{$page} eq "") {
	    $content = $wiki->get_page($page);
	    %pagecache->{$page} = $content;
	} else {
	    $content = %pagecache->{$page};
	}
	$self->{pagecache} = %pagecache;
	return $content;
    }

    return "";
}

sub save_page_content {
    my $self = shift;
    my $wiki = shift;
    my $name = shift;
    my $year = shift;
    my $month = shift;
    my $content = shift;

    my $page = $name."/".$year."-".$month;

    $wiki->save_page($page,$content);
    my %pagecache;
    if (defined($self->{pagecache})) {
	%pagecache = $self->{pagecache};
    }
    %pagecache->{$page} = $content;
    $self->{pagecache} = %pagecache;
    return;
}

# static methods

sub make_schedule_anchor {
    my $wiki = shift;
    my $name = shift;
    my $buf = "";

    $buf .= "<a href=\"".$wiki->config('script_name')
	."?page=".Util::url_encode($name);

    if ($wiki->page_exists($name)) {
	$buf .= "\">";
    } else {
	$buf .= "&preview=1"
	    ."&action=EDIT"
	    ."&content=".Util::url_encode("{{schedulecalendar $name}}\n{{scheduleedit $name}}")
	    ."\">";
    }
    $buf .= Util::escapeHTML($name)."</a>";
    return $buf;
}

sub extract_schedule {
    my $content = shift;
    my $mday = shift;
    my $buf = "";

    while ($content =~ m/(\n|^),(\s*|[^,\n]*[^1-9,\n])$mday(\s*|[^0-9,\n][^,\n]*),\s*(.+)\s*($|\n)/mg) {
	my $text = $4;
	if ($buf eq "") {
	    $buf .= Util::escapeHTML($text);
	} else {
	    $buf .= "<br>".$text;
	}
    }
    return $buf;
}

# 指定日のソースを返す
sub extract_schedule_source {
    my $content = shift;
    my $mday = shift;
    my $buf = "";

    while ($content =~ m/(\n|^)([,\*](\s*|[^,\n]*[^1-9,\n])$mday(\s*|[^0-9,\n][^,\n]*),\s*(.+)\s*($|\n))/mg) {
	my $text = $2;
	$buf .= $text."\n";
    }
    return $buf;
}

# 指定日以外のソースを返す
sub extract_schedule_othersource {
    my $content = shift;
    my $mday = shift;
    my $buf = $content;
    $buf =~ s/(\n|^)([,\*](\s*|[^,\n]*[^1-9,\n])$mday(\s*|[^0-9,\n][^,\n]*),\s*(.+)\s*($|\n))//mg;

    return $buf;
}

1;
