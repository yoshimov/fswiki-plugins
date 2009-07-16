################################################################################
#
# �Х��ȥ�å��ץ饰����Υ��������ϥ�ɥ顣
# 
################################################################################
package plugin::bugtrack::BugTrackHandler;
#use strict;
#===============================================================================
# ���󥹥ȥ饯��
#===============================================================================
sub new {
	my $class = shift;
	my $self = {};
	return bless $self,$class;
}

#==============================================================================
# ���������ϥ�ɥ�
#==============================================================================
sub do_action {
	my $self = shift;
	my $wiki = shift;
	my $cgi = $wiki->get_CGI;
	
	my $project  = $cgi->param("project");
	my $name     = $cgi->param("name");
	my $category = $cgi->param("category");
	my $priority = $cgi->param("priority");
	my $status   = $cgi->param("status");
	my $content  = $cgi->param("content");
	my $subject  = $cgi->param("subject");
	my $time     = time();
	
	if($name eq ""){
		return $wiki->error("̾�������Ϥ���Ƥ��ޤ���");
	} elsif($subject eq ""){
		return $wiki->error("���ޥ꤬���Ϥ���Ƥ��ޤ���");
	} elsif($content eq ""){
		return $wiki->error("�Х����Ƥ����Ϥ���Ƥ��ޤ���");
	}
	
	# post_name�Ȥ��������ǥ��å����򥻥åȤ���
	my $cookie = $cgi->cookie(-name=>'post_name',-value=>$name,-expires=>'+1M');
	print "Set-Cookie: ",$cookie->as_string,"\n";
	
	my $page = $self->make_pagename($wiki,$project);
	
	$content = "!!!$subject\n".
	           "*��Ƽԡ� $name\n".
	           "*���ƥ��ꡧ $category\n".
	           "*ͥ���١� $priority\n".
	           "*���֡� $status\n".
	           "*������ ".Util::format_date($time)."\n".
	           "{{bugstate}}\n".
	           "!!����\n".$content."\n".
	           "!!������\n{{comment}}";
	
	$wiki->save_page($page,$content);
	$wiki->redirect($page);
}

#==============================================================================
# �Х���ݡ��ȤΥڡ���̾�����
#==============================================================================
sub make_pagename {
	my $self = shift;
	my $wiki = shift;
	my $project = shift;
	
	my @list = $wiki->get_page_list;
	my $count = 0;
	foreach(@list){
		if($_ =~ /^BugTrack-$project\/([0-9]+)$/){
			if($count < $1){
				$count = $1;
			}
		}
	}
	$count++;
	return "BugTrack-$project/$count";
}

1;
