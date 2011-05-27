############################################################
# 
# Bookmark�ץ饰����Υ��������ϥ�ɥ顣
# 
############################################################
package plugin::bookmark::BookmarkHandler;
use strict;
use Jcode;
#===========================================================
# ���󥹥ȥ饯��
#===========================================================
sub new {
	my $class = shift;
	my $self = {};
	return bless $self,$class;
}

#===========================================================
# �����Ȥν񤭹���
#===========================================================
sub do_action {
	my $self = shift;
	my $wiki = shift;
	my $cgi  = $wiki->get_CGI;
	
	my $name    = $cgi->param("name");
	my $message = $cgi->param("message");
	my $page    = $cgi->param("page");
	my $url     = $cgi->param("url");
	my $title   = $cgi->param("title");
	my $save    = $cgi->param("save");
	my $close   = $cgi->param("close");
	my $enc     = $cgi->param("enc");
	my $linkcontent = "";
	
	if ($enc ne "") {
	    $name = Jcode->new($name, $enc)->euc;
	    $message = Jcode->new($message, $enc)->euc;
	    $page = Jcode->new($page, $enc)->euc;
	    $title = Jcode->new($title, $enc)->euc;
	}

	if($name eq ""){
#	    unless($wiki->use_cache($page)){
		$name = $cgi->cookie(-name=>'post_name');
		if($name eq ''){
		    my $login = $wiki->get_login_info();
		    if(defined($login)){
			$name = $login->{id};
		    }
		}
#	    } else {
#		$name = "̵̾������";
#	    }
	}

	if ($title ne "" && $url ne "") {
	    $linkcontent = "![$title|$url]\n";
	    if ($message ne "") {
		$linkcontent .= "$message\n";
	    }
	    $linkcontent .= "- $name (".Util::format_date(time()).")\n";
	}

	if($save ne "" && $page ne "" && $url ne "" && $title ne ""){
		# ��󥯤���¸
		my $content = $wiki->get_page($page);
		$content .= $linkcontent;
		$wiki->save_page($page,$content);
		if ($close eq "true") {
		    # ������ɥ����Ĥ���
		    $content =<<"EOC";
<h2>������ɥ����Ĥ��Ƥ��ޤ���</h2>
<script type="text/javascript">
    window.close();
</script>
EOC
                    return $content;
		}
		# ���Υڡ����˥�����쥯��
		$wiki->redirect($page);
		return;
	}
	# �ץ�ӥ塼�����ϲ���ɽ��

	# �ڡ���̾�ꥹ�Ȥ����
	my @pagelist = $wiki->get_page_list({-sort=> 'name'});
	my $words = "";
	foreach my $pname (@pagelist) {
	    unless ($pname =~ /([0-9]+\-|\/)[0-9]+$/m) {
		$words .= "\t".$pname."\t";
	    }
	}

	# HTML escape
	my $script = $wiki->config('script_name');
	$title = &Util::escapeHTML($title);
	$url = &Util::escapeHTML($url);
	$page = &Util::escapeHTML($page);
	$message = &Util::escapeHTML($message);
	$name = &Util::escapeHTML($name);

	my $content = <<"EOC";
<h2>��󥯾������Ͽ����</h2>
<form action="$script" method="POST" name="addlink">
<input type="hidden" name="action" value="BOOKMARK"/>
<input type="hidden" name="close" value="$close"/>
<table border="0">
<tr>
<th>�����ȥ�:</th>
<td><input type="text" name="title" size="60" value="$title"/></td>
</tr>
<tr>
<th>URL:</th>
<td><input type="text" name="url" size="60" value="$url"/></td>
</tr>
<tr>
<th>��Ͽ��Wiki�ڡ���̾:</th>
<td><input type="text" name="page" size="40" value="$page" autocomplete="off" />
</td>
</tr>
<tr>
<th>����:</th>
<td><textarea name="message" rows="5" cols="40">$message</textarea></td>
</tr>
<tr>
<th>�桼��̾:</th>
<td><input type="text" name="name" value="$name"/></td>
</tr>
</table>
<input type="submit" name="save" value="��Ͽ"/>
<input type="submit" name="preview" value="�ץ�ӥ塼"/>
</form>
�ڡ���̾���䡧<div id="pageSuggest">
</div>
<script language="JavaScript">
    <!--
    var words = "$words";
	var firstSuggest = "";
	function escRegExp(str) {
	    return str.replace(/[\\\\\$\*+?()=!|,{}\\[\\]\\.^]/g,'\\\\\$\&')
	}
	function trim(str) {
	    return str.replace(/^\\s+|\\s+\$/g,'');
	}
	function handler(e) {var event=(e||window.event); // for IE
	    if (event.keyCode == 9 && event.type=='keydown') {
		// tab
		    if (firstSuggest.length > 0) {
			document.forms.addlink.page.value = firstSuggest;
			if (event.preventDefault) {
			    event.preventDefault();
			}
			updateSuggest();
		    }
	    }
	    if (event.type == 'keyup') {
		updateSuggest();
	    }
	}
	function complete(str) {
	    document.forms.addlink.page.value = str;
	    updateSuggest();
	}
	function updateSuggest() {
	    var txt = document.forms.addlink.page.value;
	    if (txt == null || txt.length < 1) {
		firstSuggest = "";
		var suggestDiv = document.getElementById("pageSuggest");
		suggestDiv.innerHTML = "";
		return;
	    }
	    txt = escRegExp(txt);
	    var wordList = words.match(new RegExp("\\\\t("+txt+"[^\\\\t]+)\\\\t", "gi"));
	    var content = "";
	    firstSuggest = "";
	    if (wordList != null) {
		for (i = 0; i < (wordList.length>10?10:wordList.length); i ++) {
		    if (i == 0) {
			firstSuggest = trim(wordList[i]);
		    }
		    content += " [<a href=\\"javascript:complete('"+trim(wordList[i])+"');\\">"+trim(wordList[i])+"</a>]";
		}
	    }
	    var suggestDiv = document.getElementById("pageSuggest");
	    suggestDiv.innerHTML = content;
	    suggestDiv.style.visibility = "visible";
	}
	document.forms.addlink.page.onkeyup = handler;
	document.forms.addlink.page.onkeydown = handler;
// -->
</script>
<hr/>
<h2>�ץ�ӥ塼</h2>
EOC
        $content .= $wiki->process_wiki($linkcontent);
	return $content;
}

1;
