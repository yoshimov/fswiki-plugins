############################################################
#
# <p>ź�դ���FreeMind�ե������Flash��ɽ�����ޤ���</p>
# <p>���������礭������ꤹ�뤳�Ȥ�Ǥ��ޤ���</p>
# <pre>
# {{ref_mm �ե�����̾[,�ĥ�����,�ޤ���ߥ�٥�]}}
# </pre>
#
############################################################
package plugin::freemind::RefFreeMindFlash;
use strict;
#===========================================================
# ���󥹥ȥ饯��
#===========================================================
sub new {
	my $class = shift;
	my $self = {};
	$self->{count} = 0;
	return bless $self,$class;
}

#===========================================================
# �ѥ饰��ե᥽�å�
#===========================================================
sub paragraph {
	my $self = shift;
	my $wiki = shift;
	my $file = shift;
	my $height = shift;
	my $level = shift;
	my $page = "";

	$self->{count} ++;

	if($file eq ""){
		return &Util::paragraph_error("�ե����뤬���ꤵ��Ƥ��ޤ���","WIKI");
	}
	if($page eq ""){
		$page = $wiki->get_CGI()->param("page");
	}
	if ($height eq "") {
	    $height = 500;
	}
	if ($level eq "") {
	    $level = 10;
	}
	unless($wiki->can_show($page)){
		return &Util::paragraph_error("�ڡ����λ��ȸ��¤�����ޤ���","WIKI");
	}
	
	my $filename = $wiki->config('attach_dir')."/".&Util::url_encode($page).".".&Util::url_encode($file);
	unless(-e $filename){
		return &Util::paragraph_error("�ե����뤬¸�ߤ��ޤ���","WIKI");
	}
	
	my $mmurl = $wiki->config('script_name')."?action=ATTACH&amp;page=".
	    &Util::url_encode($page)."&amp;file=".&Util::url_encode($file);
	$height .= "px";
	my $buf = <<"EOB";
	<div id="freemindflash$self->{count}" style="width:100%;height:$height;"></div>
	<script type="text/javascript" src="/wiki/theme/flashobject.js"></script>
	<script type="text/javascript">
		// <![CDATA[
		var fo = new FlashObject("/wiki/theme/visorFreemind.swf", "visorFreeMind", "100%", "100%", 6, "#9999ff");
		fo.addParam("quality", "high");
		fo.addParam("bgcolor", "#ffffe0");
		fo.addVariable("openUrl", "_blank");
		fo.addVariable("initLoadFile", "$mmurl");
		fo.addVariable("startCollapsedToLevel","$level");
		fo.addVariable("mainNodeShape","rectangle");
		fo.write("freemindflash$self->{count}");
		// ]]>
	</script>
EOB
	return $buf;
}

1;
