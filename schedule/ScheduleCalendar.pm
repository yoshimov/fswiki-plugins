################################################################################
#
# �������塼��򥫥���������ɽ�����ޤ���
# ������ɤ���ꤹ��ȡ����ꤵ�줿ñ���ޤॹ�����塼�뤬������ϡ�
# �����Ȥ��ƿ�ʬ������ޤ���
# <pre>
# {{schedulecalendar �������塼��̾,�������1,�������2,,}}
# </pre>
#
################################################################################
package plugin::schedule::ScheduleCalendar;
use plugin::schedule::Schedule;
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
# ����饤��᥽�å�
#===============================================================================
sub paragraph {
    my $self  = shift;
    my $wiki  = shift;
    my $name  = shift;
    my @holiday = @_;

    if($name eq ""){
	return "<font class=\"error\">�������塼��̾�����ꤵ��Ƥ��ޤ���</font>";
    }

    my $time = time();
    my ($sec, $min, $hour, $mday, $month, $year, $wday) = localtime($time);
    $year += 1900;
    $month  += 1;

    my $buf = make_calendar($wiki, $year, $month, $mday, $name, @holiday);
    $buf .= plugin::schedule::ScheduleEdit::make_edit_form($wiki, $name, $year, $month, $mday);
    return $buf;
}

sub make_calendar {
    my $wiki  = shift;
    my $cyear = shift;
    my $cmonth = shift;
    my $cday  = shift;
    my $name  = shift;
    my @holiday = @_;
    my $buf = "";

    my @week = ("��","��","��","��","��","��","��");

    # �������椫�ɤ���
    my $is_login = 0;
    if (defined($wiki->get_login_info())) {
	$is_login = 1;
    }

    # ����η�˰�ư
    my $nowtime = time();
    my $time = get_specified_time($cyear, $cmonth);
    my ($sec, $min, $hour, $mday, $month, $year, $wday) = localtime($time);
    $year += 1900;
    $month  += 1;
    my $gearsFlag = 1;
    if (abs($time - $nowtime) > 32 * 24 * 60 * 60) {
	# 2��ʾ�Υ��Ƥ������Gears��̵���ˤ���
	$gearsFlag = 0;
    }

    # 1���˰�ư
    $time = $time - (($mday - 1) * 24 * 60 * 60);
    ($sec, $min, $hour, $mday, $month, $year, $wday) = localtime($time);
    $year += 1900;
    $month  += 1;

    # ���ˤޤ����դ��ư
    while ($wday!=0) {
	$time -= 24 * 60 * 60;
	($sec, $min, $hour, $mday, $month, $year, $wday) = localtime($time);
	$year += 1900;
	$month  += 1;
    }

    # holiday ��Ϣ��
    my $first = 1;
    my $holidaystr = "";
    for my $tmp (@holiday) {
	if ($first != 1) {
	    $holidaystr .= ",";
	} else {
	    $first = 0;
	}
	$holidaystr .= $tmp;
    }

    my $schedule = new plugin::schedule::Schedule;

    # �إå�������
    my $script_name = $wiki->config('script_name');
    my $nameenc = Util::url_encode($name);
    $buf .= << "EOD";
<script language="JavaScript" src="./theme/gears_init.js">
</script>
<script language="JavaScript">
<!--
var STORE_NAME="fswiki-schedule-store-$nameenc";
var localServer, db, store;
var hasUpdate = false;
var isMSIE = !(document.getSelection);
function initCalendar() {
    // ���������
    if (window.google && google.gears && $gearsFlag) {
	localServer = google.gears.factory.create('beta.localserver', '1.0');
	db = google.gears.factory.create('beta.database', '1.0');
	db.open(STORE_NAME);
	db.execute("create table if not exists schedule_update " +
	    "(year int, month int, day int, content text, " +
	    "primary key (year, month, day))");
	updateScheduleSource();
	store = localServer.createManagedStore(STORE_NAME);
	store.manifestUrl = "$script_name?action=SCHEDULEDAYEDIT&type=manifest&name=$nameenc";
  var timerId = window.setInterval(function() {
    // When the currentVersion property has a value, all of the resources
    // listed in the manifest file for that version are captured. There is
    // an open bug to surface this state change as an event.
    if (store.updateStatus == 0) {
	setStatus("����饤��");
	checkInterval();
	if (hasUpdate) {
	    updateScheduleServer();
	}
	//      window.clearInterval(timerId);
    } else if (store.updateStatus == 3) {
	setStatus("���ե饤��");
	checkInterval();
    } else {
	setStatus("Ʊ����");
    }
  }, 1000);
	store.checkForUpdate();
  } else {
      if ($gearsFlag) {
	  setStatus('<a href=\"http://gears.google.com\">Google Gears</a>�б�');
      } else {
	  setStatus("");
      }
  }
    // ���������դ�����п����դ���
    var nowTime = new Date();
    var borderobj = document.getElementById('day-'+(nowTime.getMonth()+1)+'-'+nowTime.getDate());
    if (borderobj) {
	borderobj.style.border = '#ff4444 4px solid';
    }
}
// ����饤����֤����Ū�˴ƻ뤹��
function checkInterval() {
    if (!store) {
	return;
    }
    var dur = (new Date().getTime())/1000 - store.lastUpdateCheckTime;
    if (dur > 120) { // ��ʬ�ˣ����䤤��碌
	store.checkForUpdate();
		     // TODO ��������Ƥ�������̤����ɤ���ɬ�פ�����
    }
}
function setStatus(status) {
    var obj = document.getElementById("calendar-status");
    obj.innerHTML = status;
}
// DB�Υǡ����ǲ��̤򹹿�����
function updateScheduleSource() {
    if (!db) {
	return;
    }
    var rs = db.execute("select * from schedule_update");
    while (rs.isValidRow()) {
	hasUpdate = true;
	var sourceobj = document.getElementById("day-"+rs.field(1)+"-"+rs.field(2)+"-source");
	if (sourceobj) {
	    sourceobj.value = rs.field(3);
	    day_reload(rs.field(0),rs.field(1),rs.field(2));
	}
	rs.next();
    }
}
// DB�Υǡ����ǥ����Хǡ����򹹿�����
function updateScheduleServer() {
    if (!db || !hasUpdate) {
	return;
    }
    hasUpdate = false;
    var rs = db.execute("select * from schedule_update");
    while (rs.isValidRow()) {
	day_updateContent(rs.field(0),rs.field(1),rs.field(2),rs.field(3));
	rs.next();
    }
}
// ��ȼ��Ӥ�ɽ���ȥ���
function exTree(tName){
    var obj = document.getElementById(tName).style;
    if(obj.display == "block"){
	obj.display = "none";
    } else {
	obj.display = "block";
    }
}
// ���դ�����
function fillEditDate(year, month, day) {
    scheduleedit.year.value = year;
    scheduleedit.month.value = month;
    scheduleedit.day.value = day;
}
// �Խ���󥯤�ɽ��
function day_focus(dayId){
    var obj = document.getElementById(dayId+"-edit").style;
    obj.display = "block";
}
// �Խ���󥯤򱣤�
function day_unfocus(dayId){
    var obj = document.getElementById(dayId+"-edit").style;
    obj.display = "none";
}
function createHttpRequest() {
  if (window.XMLHttpRequest) {
    return new XMLHttpRequest();
  } else if(window.ActiveXObject) {
    try {
      return new ActiveXObject("Microsoft.XMLHTTP");
    } catch(e) {
      return new ActiveXObject("Msxml2.XMLHTTP");
    }
  }
  return null;
}
// �������塼�����Ф�
function extract_schedule(source) {
    var buf = "";
    var list = source.split('\\n');
    for (i in list) {
	if (list[i].match(/^,\\d+,/)) {
	    buf += list[i].substring(list[i].indexOf(',',1) + 1);
	    buf += "<br />";
	} else if (!list[i].match(/^\\*\\d+,/)) {
	    buf += list[i];
	    buf += "<br />";
	}
    }
    return buf;
}
// �Խ��ܥå�����ɽ��
function day_edit(year,month,day) {
    var contentId = "day-" + month + "-" + day + "-content";
    var divobj = document.getElementById(contentId);
    if (divobj.contentId) {
	// editing
    } else {
	// �Խ����contentId�򥻥å�
	divobj.contentId = contentId;
        var sourceobj = document.getElementById("day-"+month+"-"+day+"-source");
        var buf = "<textarea cols='20' rows='4' id='day-"+month+"-"+day+"-text'>";
//	if (isMSIE) {
//	    var codestr = "";
//	    for (var i = 0; i < 20 && i < sourceobj.innerHTML.length; i ++) {
//		codestr += "," + sourceobj.innerHTML.charCodeAt(i);
//	    }
//	    alert(codestr);
//	    buf += sourceobj.innerHTML;
//	} else {
	    buf += sourceobj.value;
//	}
	buf += "</textarea><br />";
	buf += "<a href='javascript:day_submit("+year+","+month+","+day+")'>����</a> / ";
	buf += "<a href='javascript:day_reload("+year+","+month+","+day+")'>����󥻥�</a>\\n";
	divobj.innerHTML = buf;
    }
}
// �����᤹
function day_reload(year,month,day) {
    var contentId = "day-" + month + "-" + day + "-content";
    var divobj = document.getElementById(contentId);
    divobj.contentId = null;
    var sourceobj = document.getElementById("day-"+month+"-"+day+"-source");
    divobj.innerHTML = extract_schedule(sourceobj.value);
}
// �ǡ�������
function day_submit(year,month,day) {
    var textId = "day-" + month + "-" + day + "-text";
    var contentId = "day-" + month + "-" + day + "-content";
    var textobj = document.getElementById(textId);
    if (!textobj) {
	// nop
	return;
    }
    var divobj = document.getElementById(contentId);
    divobj.contentId = null;
    var sourceobj = document.getElementById("day-"+month+"-"+day+"-source");
    sourceobj.value = textobj.value;
    if (db) {
	// Gears�ξ�硢DB���������Ʊ���˹���
        db.execute("insert or replace into schedule_update values(?, ?, ?, ?)", [year, month, day, textobj.value]);
	hasUpdate = true;
	day_reload(year,month,day);
    } else {
	// Gears���ʤ���硢���ξ�ǹ���
	divobj.innerHTML = "������..";
	day_updateContent(year,month,day,sourceobj.value);
    }
}
// �����Ф˹����ꥯ�����Ȥ�Ф�
function day_updateContent(year,month,day,content) {
    var request = createHttpRequest();
    request.onreadystatechange = function() {
	if (request.readyState == 4) {
	    try {
	    if (request.status == 200) {
		if (db) {
		    db.execute("delete from schedule_update where year=? and month=? and day=?", [year,month,day]);
		}
		if (store) {
		    store.checkForUpdate();
		}
	    } else {
		hasUpdate = true;
	    }
	    } catch (ex) {
		hasUpdate = true;
	    }
	    day_reload(year,month,day);
	    request.abort();
	}
    }
    request.open("GET", "$script_name?action=SCHEDULEDAYEDIT&type=submit&name=$nameenc&year="+year+"&month="+month+"&mday="+day+"&text="+encodeURIComponent(content), true);
    request.setRequestHeader("If-Modified-Since", 0);
    request.send("");
}
//-->
</script>
EOD
    $buf .= "<table class=\"calendar\">";
    $buf .= "<tr><th colspan=\"8\">";
    my $baselink = plugin::schedule::Schedule::make_schedule_anchor($wiki, $name);
    $buf .= make_month_anchor($wiki, $name, $cyear, $cmonth, -1, $holidaystr)."<< --- ";
    $buf .= make_month_anchor($wiki, $name, $cyear, $cmonth, 0, $holidaystr)."��".$baselink;
    $buf .= " --- >>".make_month_anchor($wiki, $name, $cyear, $cmonth, 1, $holidaystr);
    $buf .= "<br /><div style=\"text-align:center\" id=\"calendar-status\"></div>";
    $buf .= "</th></tr>";
    $buf .= "<tr>";

    my $workstyle="background-color:#ffffcc;";

    # ����
    foreach(@week){
	$buf.="<th>".$_."</th>";
    }
    if ($is_login) {
	$buf .= "<th style=\"$workstyle\">��ȼ���</th>";
    }
    $buf .= "</tr>\n";

    my $start_flag = 1;
    my $last_flag = 0;
    my @work_list = ();
    my @comment_list = ();
    while ($last_flag == 0){
	($sec, $min, $hour, $mday, $month, $year, $wday) = localtime($time);
	$year += 1900;
	$month  += 1;

	my $dayid = "day-".$month."-".$mday;
	if($start_flag){
	    # �Ǹ�ν����������ǽ���äƤ�����
	    if ($cmonth != $month && $mday == 1) {
		$last_flag = 1;
		last;
	    }
	    $buf .= "<tr>";
	    $start_flag = 0;
	}
	# ���Ƥν���
	my $daystyle = "text-align:center;font-weight:bold;";
	my $content = "<div style=\"$daystyle\">".make_day_anchor($wiki,$name,$year,$month,$mday,$holidaystr)."</div>";
	$content .= "<div style=\"text-align:right;display:none;line-height:0;\" id=\"${dayid}-edit\">[<a href=\"javascript:day_edit($year,$month,$mday)\">�Խ�</a>]</div><br/>";
	my $holidayname = $schedule->get_holiday_name($wiki, $year, $month, $mday);
	$content .= "<div style=\"font-size:85%;\" id=\"${dayid}-content\">";
	if (!($holidayname eq "")) {
	    $content .= $holidayname."<br>";
	}
	my $page_content = $schedule->get_page_content($wiki, $name, $year, $month);
	$content .= plugin::schedule::Schedule::extract_schedule($page_content, $mday);
	$content .= "</div>";
	# ��������ź��
	$content .= "<textarea style=\"display:none\" id=\"${dayid}-source\">";
	$content .= plugin::schedule::Schedule::extract_schedule_source($page_content, $mday);
	$content .= "</textarea>";
	# ��ȼ��ӡ������Ȥ����
	@work_list = extract_work($page_content, $mday, @work_list);
	@comment_list = extract_comment($page_content, $mday, @comment_list);

	my $cellstyle = "text-align:left;";
	# ���������Ȥ��դ���
#	if($mday==$cday && $month==$cmonth){
#	    $cellstyle .= "border:#ff4444 4px solid;";
#	}
	my $hflag = 0;
	if ($wday == 0 || $wday == 6 || !($holidayname eq "")) {
	    $hflag = 1;
	}
	# ����Ƚ��
	for my $hname (@holiday) {
	    if ($content =~ m/$hname/) {
		$hflag = 1;
	    }
	}
	if ($hflag != 0) {
	    $cellstyle .= "background-color:#ffcccc;";
	}

	# ����η�ϳ���ɽ��
	if($month!=$cmonth){
	    $cellstyle .= "background-color:#bbbbbb;";
	}
	$buf .= "<td valign=\"top\" style=\"position:relative;$cellstyle\" id=\"$dayid\"";
#	$buf .= " onclick=\"day_edit($year,$month,$mday)\"";
	$buf .= " onmouseover=\"day_focus('$dayid')\"";
	$buf .= " onmouseout=\"day_unfocus('$dayid')\">";
	$buf .= $content."</td>";

	# ����������
	if($wday == 6){
	    my $week_content = "";
	    my $sum = 0;
	    # ��ȼ��Ӥ�ץ�������̾�ǥ�����
	    @work_list = sort {$a->{project} cmp $b->{project}} @work_list;
	    # ��ȼ��ӽ���
	    my $item_content = "";
	    my $item_sum = 0;
	    my $preproject = "";
	    foreach my $item (@work_list) {
		if ($preproject ne $item->{project} && $preproject ne "") {
		    # ����
		    $week_content .= "<a href=\"javascript:exTree('$month$mday-$preproject')\">[$preproject] ".$item_sum."h</a><br>";
		    $week_content .= "<div id=\"$month$mday-$preproject\" style=\"display:none\">";
		    $week_content .= $item_content;
		    $week_content .= "</div>";
		    $item_content = "";
		    $item_sum = 0;
		}
		$preproject = $item->{project};

		$item_content .= "<li>".$item->{duration}." ".$item->{memo}."<br>";
		if ($item->{duration} =~ /([\d]+)[dD]/) {
		    # day
		    $sum = $sum + $1 * 8;
		    $item_sum = $item_sum + $1 * 8;
		} elsif ($item->{duration} =~ /([\d]+)[hH]/) {
		    # hour
		    $sum = $sum + $1;
		    $item_sum = $item_sum + $1;
		}
	    }

	    if ($#work_list >= 0) {
		# �ǽ����ܽ���
		$week_content .= "<a href=\"javascript:exTree('$month$mday-$preproject')\">[$preproject] ".$item_sum."h</a><br>";
		$week_content .= "<div id=\"$month$mday-$preproject\" style=\"display:none\">";
		$week_content .= $item_content;
		$week_content .= "</div>";
		$week_content .= "���: ".$sum."����";
	    }
	    # �����Ƚ���
	    if ($#comment_list >= 0) {
		$week_content .= "<br>";
		foreach my $item (@comment_list) {
		    $week_content .= $item->{name}.": ".$item->{memo}."<br>";
		}
	    }
	    if ($is_login) {
		$buf .= "<td style=\"text-align:left;font-size:85%;$workstyle\">".$week_content."</td>";
	    }
	    @work_list = ();
	    @comment_list = ();
	    $buf .= "</tr>\n";
	    $start_flag = 1;

	    # �Ǹ�ν�
	    if ($month!=$cmonth) {
		$last_flag = 1;
	    }
	}
	$time += 24 * 60 * 60;
    }

    $buf .= "</tr>\n";
    $buf .= "</table>";
    $buf .= << "EOD";
<script language="JavaScript">
<!--
// ��������������¹�
initCalendar();
// -->
</script>
EOD
    return $buf;
}

#===============================================================================
# ������󥫤Υѥ�᡼�������
#===============================================================================
sub make_month_anchor {
    my $wiki = shift;
    my $name  = shift;
    my $year  = shift;
    my $month = shift;
    my $plus  = shift;
    my $holiday = shift;
    my $buf = "";
    
    $month += $plus;
    if($month==13){
	$year += 1;
	$month = 1;
    } elsif($month==0){
	$year -= 1;
	$month = 12;
    }
    
    $buf .= "<a href=\"".$wiki->config('script_name')
	."?action=SCHEDULECALENDAR";

    $buf .= "&amp;year=".$year
	."&amp;month=".$month
	."&amp;name=".Util::url_encode($name);
#	."&amp;holiday=".Util::url_encode($holiday);
    $buf .= "\">$yearǯ$month��</a>";
    return $buf;
}

sub make_day_anchor {
    my $wiki = shift;
    my $name = shift;
    my $year = shift;
    my $month = shift;
    my $mday = shift;
    my $holiday = shift;
    my $buf = "";

#    $buf .= "<a href=\"".$wiki->config('script_name')
#	."?action=SCHEDULECALENDAR";
#    $buf .= "&amp;edit=1";
#    $buf .= "&amp;year=".$year
#	."&amp;month=".$month
#	    ."&amp;mday=".$mday
#		."&amp;name=".Util::url_encode($name)
#		    ."&amp;holiday=".Util::url_encode($holiday);
    $buf .= "<a href=\"javascript:fillEditDate($year,$month,$mday);";
    $buf .= "\">$mday</a>";

    return $buf;
}

# ���κ�Ȥ����
sub extract_work {
    my $content = shift;
    my $mday = shift;
    my @work = @_;

    my $buf = "";

    while ($content =~ m/(\n|^)[\*,]\s*s?$mday\s*,?\s*\[([^\n\[\],]+)\]\s*(\d+[hHdD])\s*,\s*([^\n,]*,)*([^\n,]*)($|\n)/mg) {
	my $item;
	$item->{project} = $2;
	$item->{duration} = $3;
	$item->{memo} = $5;
	push(@work, $item);
    }
    return @work;
}

# ���Υ����Ȥ����
sub extract_comment {
    my $content = shift;
    my $mday = shift;
    my @comment = @_;

    my $buf = "";

    while ($content =~ m/(\n|^)\*\s*$mday\s*,\s*([^\n\-]*)\s*\-\s*([^\n\(\)]+)\s*\(([^\n\(\)]*)\)\s*($|\n)/mg) {
	my $item;
	$item->{memo} = $2;
	$item->{name} = $3;
	$item->{time} = $4;
	push(@comment, $item);
    }
    return @comment;
}

# ����η�˰�ư����
sub get_specified_time {
    my $cyear = shift;
    my $cmonth = shift;
    my $time = time();

    # ���߻���
    my ($sec, $min, $hour, $mday, $month, $year, $wday) = localtime($time);
    $year += 1900;
    $month  += 1;

    # ����η�˰�ư
    my $o_yearmon = sprintf("%04d%02d",$cyear,$cmonth);
    while($year!=$cyear || $month!=$cmonth){
	my $yearmon = sprintf("%04d%02d",$year,$month);
	if($o_yearmon > $yearmon){
	    $time += 24 * 60 * 60;
	} else {
	    $time -= 24 * 60 * 60;
	}
	($sec, $min, $hour, $mday, $month, $year, $wday) = localtime($time);
	$year += 1900;
	$month  += 1;
    }
    return $time;
}

1;
