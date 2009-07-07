############################################################
#
# Twitterの最新のメッセージを表示する
# <pre>
# {{twitter_text Twitter ID,[num]}}
# </pre>
#
############################################################
package plugin::twitter::Text;

sub new {
	my $class = shift;
	my $self  = {};
	return bless $self,$class;
}

sub inline {
    my $self  = shift;
    my $wiki  = shift;
    my $id = shift;
    my $num = shift;
    my $buf = "";
    my $userid = &Util::escapeHTML($id);
    if ($num eq "") {
	$num = "1";
    }

    $buf .= <<"EOD";
<div id="twitter_div">
<ul id="twitter_update_list"></ul></div>
<script type="text/javascript" src="http://twitter.com/javascripts/blogger.js"></script>
<script text="text/javascript" src="http://twitter.com/statuses/user_timeline/${userid}.json?callback=twitterCallback2&count=$num"></script>
EOD

    return $buf;
}

1;
