################################################################################
#
# スケジュールをカレンダ形式で表示します。
# 休日ワードを指定すると、指定された単語を含むスケジュールがある場合は、
# 休日として色分けされます。
# <pre>
# {{schedulecalendar スケジュール名,休日ワード1,休日ワード2,,}}
# </pre>
#
################################################################################
package plugin::schedule::ScheduleCalendar;
use plugin::schedule::Schedule;
use plugin::schedule::ScheduleEdit;
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
    my $name  = shift;
    my @holiday = @_;

    if($name eq ""){
	return "<font class=\"error\">スケジュール名が指定されていません。</font>";
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

    my @week = ("日","月","火","水","木","金","土");

    # ログイン中かどうか
    my $is_login = 0;
    if (defined($wiki->get_login_info())) {
	$is_login = 1;
    }

    # 指定の月に移動
    my $nowtime = time();
    my $time = get_specified_time($cyear, $cmonth);
    my ($sec, $min, $hour, $mday, $month, $year, $wday) = localtime($time);
    $year += 1900;
    $month  += 1;
    my $gearsFlag = 1;
    if (abs($time - $nowtime) > 32 * 24 * 60 * 60) {
	# 2月以上離れている場合はGearsを無効にする
	$gearsFlag = 0;
    }

    # 1日に移動
    $time = $time - (($mday - 1) * 24 * 60 * 60);
    ($sec, $min, $hour, $mday, $month, $year, $wday) = localtime($time);
    $year += 1900;
    $month  += 1;

    # 日曜まで日付を移動
    while ($wday!=0) {
	$time -= 24 * 60 * 60;
	($sec, $min, $hour, $mday, $month, $year, $wday) = localtime($time);
	$year += 1900;
	$month  += 1;
    }

    # holiday を連結
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

    # ヘッダ部出力
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
    // 初期化処理
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
	setStatus("オンライン");
	checkInterval();
	if (hasUpdate) {
	    updateScheduleServer();
	}
	//      window.clearInterval(timerId);
    } else if (store.updateStatus == 3) {
	setStatus("オフライン");
	checkInterval();
    } else {
	setStatus("同期中");
    }
  }, 1000);
	store.checkForUpdate();
  } else {
      if ($gearsFlag) {
	  setStatus('<a href=\"http://gears.google.com\">Google Gears</a>対応');
      } else {
	  setStatus("");
      }
  }
    // 今日の日付があれば色を付ける
    var nowTime = new Date();
    var borderobj = document.getElementById('day-'+(nowTime.getMonth()+1)+'-'+nowTime.getDate());
    if (borderobj) {
	borderobj.style.border = '#ff4444 4px solid';
    }
}
// オンライン状態を定期的に監視する
function checkInterval() {
    if (!store) {
	return;
    }
    var dur = (new Date().getTime())/1000 - store.lastUpdateCheckTime;
    if (dur > 120) { // ２分に１回問い合わせ
	store.checkForUpdate();
		     // TODO 更新されていたら画面をリロードする必要がある
    }
}
function setStatus(status) {
    var obj = document.getElementById("calendar-status");
    obj.innerHTML = status;
}
// DBのデータで画面を更新する
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
// DBのデータでサーバデータを更新する
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
// 作業実績の表示トグル
function exTree(tName){
    var obj = document.getElementById(tName).style;
    if(obj.display == "block"){
	obj.display = "none";
    } else {
	obj.display = "block";
    }
}
// 日付の入力
function fillEditDate(year, month, day) {
    scheduleedit.year.value = year;
    scheduleedit.month.value = month;
    scheduleedit.day.value = day;
}
// 編集リンクを表示
function day_focus(dayId){
    var obj = document.getElementById(dayId+"-edit").style;
    obj.display = "block";
}
// 編集リンクを隠す
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
// スケジュールを取り出す
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
// 編集ボックスを表示
function day_edit(year,month,day) {
    var contentId = "day-" + month + "-" + day + "-content";
    var divobj = document.getElementById(contentId);
    if (divobj.contentId) {
	// editing
    } else {
	// 編集中はcontentIdをセット
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
	buf += "<a href='javascript:day_submit("+year+","+month+","+day+")'>更新</a> / ";
	buf += "<a href='javascript:day_reload("+year+","+month+","+day+")'>キャンセル</a>\\n";
	divobj.innerHTML = buf;
    }
}
// 元に戻す
function day_reload(year,month,day) {
    var contentId = "day-" + month + "-" + day + "-content";
    var divobj = document.getElementById(contentId);
    divobj.contentId = null;
    var sourceobj = document.getElementById("day-"+month+"-"+day+"-source");
    divobj.innerHTML = extract_schedule(sourceobj.value);
}
// データ更新
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
	// Gearsの場合、DBに入れて非同期に更新
        db.execute("insert or replace into schedule_update values(?, ?, ?, ?)", [year, month, day, textobj.value]);
	hasUpdate = true;
	day_reload(year,month,day);
    } else {
	// Gearsがない場合、その場で更新
	divobj.innerHTML = "更新中..";
	day_updateContent(year,month,day,sourceobj.value);
    }
}
// サーバに更新リクエストを出す
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
    $buf .= make_month_anchor($wiki, $name, $cyear, $cmonth, 0, $holidaystr)."：".$baselink;
    $buf .= " --- >>".make_month_anchor($wiki, $name, $cyear, $cmonth, 1, $holidaystr);
    $buf .= "<br /><div style=\"text-align:center\" id=\"calendar-status\"></div>";
    $buf .= "</th></tr>";
    $buf .= "<tr>";

    my $workstyle="background-color:#ffffcc;";

    # 曜日
    foreach(@week){
	$buf.="<th>".$_."</th>";
    }
    if ($is_login) {
	$buf .= "<th style=\"$workstyle\">作業実績</th>";
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
	    # 最後の週が土曜日で終わっている場合
	    if ($cmonth != $month && $mday == 1) {
		$last_flag = 1;
		last;
	    }
	    $buf .= "<tr>";
	    $start_flag = 0;
	}
	# 内容の準備
	my $daystyle = "text-align:center;font-weight:bold;";
	my $content = "<div style=\"$daystyle\">".make_day_anchor($wiki,$name,$year,$month,$mday,$holidaystr)."</div>";
	$content .= "<div style=\"text-align:right;display:none;line-height:0;\" id=\"${dayid}-edit\">[<a href=\"javascript:day_edit($year,$month,$mday)\">編集</a>]</div><br/>";
	my $holidayname = $schedule->get_holiday_name($wiki, $year, $month, $mday);
	$content .= "<div style=\"font-size:85%;\" id=\"${dayid}-content\">";
	if (!($holidayname eq "")) {
	    $content .= $holidayname."<br>";
	}
	my $page_content = $schedule->get_page_content($wiki, $name, $year, $month);
	$content .= plugin::schedule::Schedule::extract_schedule($page_content, $mday);
	$content .= "</div>";
	# ソースを添付
	$content .= "<textarea style=\"display:none\" id=\"${dayid}-source\">";
	$content .= plugin::schedule::Schedule::extract_schedule_source($page_content, $mday);
	$content .= "</textarea>";
	# 作業実績、コメントの抽出
	@work_list = extract_work($page_content, $mday, @work_list);
	@comment_list = extract_comment($page_content, $mday, @comment_list);

	my $cellstyle = "text-align:left;";
	# 指定日に枠を付ける
#	if($mday==$cday && $month==$cmonth){
#	    $cellstyle .= "border:#ff4444 4px solid;";
#	}
	my $hflag = 0;
	if ($wday == 0 || $wday == 6 || !($holidayname eq "")) {
	    $hflag = 1;
	}
	# 休日判定
	for my $hname (@holiday) {
	    if ($content =~ m/$hname/) {
		$hflag = 1;
	    }
	}
	if ($hflag != 0) {
	    $cellstyle .= "background-color:#ffcccc;";
	}

	# 前後の月は灰色表示
	if($month!=$cmonth){
	    $cellstyle .= "background-color:#bbbbbb;";
	}
	$buf .= "<td valign=\"top\" style=\"position:relative;$cellstyle\" id=\"$dayid\"";
#	$buf .= " onclick=\"day_edit($year,$month,$mday)\"";
	$buf .= " onmouseover=\"day_focus('$dayid')\"";
	$buf .= " onmouseout=\"day_unfocus('$dayid')\">";
	$buf .= $content."</td>";

	# 土曜日処理
	if($wday == 6){
	    my $week_content = "";
	    my $sum = 0;
	    # 作業実績をプロジェクト名でソート
	    @work_list = sort {$a->{project} cmp $b->{project}} @work_list;
	    # 作業実績出力
	    my $item_content = "";
	    my $item_sum = 0;
	    my $preproject = "";
	    foreach my $item (@work_list) {
		if ($preproject ne $item->{project} && $preproject ne "") {
		    # 出力
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
		# 最終項目出力
		$week_content .= "<a href=\"javascript:exTree('$month$mday-$preproject')\">[$preproject] ".$item_sum."h</a><br>";
		$week_content .= "<div id=\"$month$mday-$preproject\" style=\"display:none\">";
		$week_content .= $item_content;
		$week_content .= "</div>";
		$week_content .= "合計: ".$sum."時間";
	    }
	    # コメント出力
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

	    # 最後の週
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
// カレンダー初期化実行
initCalendar();
// -->
</script>
EOD
    return $buf;
}

#===============================================================================
# 前月、翌月アンカのパラメータを作成
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
    $buf .= "\">$year年$month月</a>";
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

# 週の作業を抽出
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

# 週のコメントを抽出
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

# 指定の月に移動する
sub get_specified_time {
    my $cyear = shift;
    my $cmonth = shift;
    my $time = time();

    # 現在時刻
    my ($sec, $min, $hour, $mday, $month, $year, $wday) = localtime($time);
    $year += 1900;
    $month  += 1;

    # 指定の月に移動
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
