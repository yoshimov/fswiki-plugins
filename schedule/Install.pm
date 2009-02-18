################################################################################
#
# スケジュール管理用のプラグインを提供します。
# Copyright (c) 2004 y.nomura@jp.fujitsu.com
#
################################################################################
package plugin::schedule::Install;
#use strict;
sub install {
	my $wiki = shift;
	$wiki->add_paragraph_plugin("scheduletable","plugin::schedule::ScheduleTable", "HTML");
	$wiki->add_paragraph_plugin("schedulecalendar","plugin::schedule::ScheduleCalendar", "HTML");
	$wiki->add_paragraph_plugin("schedule","plugin::schedule::Schedule", "HTML");
	$wiki->add_paragraph_plugin("scheduleedit","plugin::schedule::ScheduleEdit", "HTML");
	$wiki->add_handler("SCHEDULEEDIT","plugin::schedule::ScheduleEditHandler");
	$wiki->add_handler("SCHEDULEWORKENTRY","plugin::schedule::ScheduleWorkEntryHandler");
	$wiki->add_handler("SCHEDULECOMMENT","plugin::schedule::ScheduleCommentHandler");
	$wiki->add_handler("SCHEDULECALENDAR","plugin::schedule::ScheduleCalendarHandler");
	$wiki->add_handler("SCHEDULEDAYEDIT","plugin::schedule::ScheduleDayHandler");
}

1;
