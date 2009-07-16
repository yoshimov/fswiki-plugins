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
<div id="twitter_div"><p>Now loading Twitter messages..</p></div>
<script src="http://twitterjs.googlecode.com/files/twitter-1.12.2.min.js" type="text/javascript" charset="utf-8"></script>
<script type="text/javascript" charset="utf-8">
getTwitters('twitter_div', { 
  id: '${userid}', 
  count: $num, 
  enableLinks: true, 
  ignoreReplies: true, 
  clearContents: true,
  template: '"%text%" <a href="http://twitter.com/%user_screen_name%/statuses/%id%/">%time%</a>'
});
</script>
EOD

    return $buf;
}

1;
