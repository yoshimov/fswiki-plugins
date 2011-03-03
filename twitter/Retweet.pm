############################################################
#
# TwitterへのRetweetボタンを表示する
# <pre>
# {{retweet Twitter ID}}
# </pre>
#
############################################################
package plugin::twitter::Retweet;

sub new {
	my $class = shift;
	my $self  = {};
	return bless $self,$class;
}

sub inline {
    my $self  = shift;
    my $wiki  = shift;
    my $id = shift;
    my $buf = "";
    my $userid = &Util::escapeHTML($id);

    $buf .= <<"EOD";
<script src="http://cdn.topsy.com/topsy.js?init=topsyWidgetCreator" type="text/javascript"></script>
<div class="topsy_widget_data"><!--
  {
    "url": location.href,
    "title": encodeURIComponent(document.title),
    "style": "big",
    "nick": "$id"
  }
--></div>
EOD

    return $buf;
}

1;
