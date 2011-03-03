############################################################
#
# TwitterへのRetweetリストを表示する
# <pre>
# {{twitter_trackbacks}}
# </pre>
#
############################################################
package plugin::twitter::Trackbacks;

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
<script type="text/javascript">
if (typeof jQuery == "undefined") {
  var s = document.createElement("script");
  s.src = "/theme/jquery-1.5.1.min.js";
  document.body.appendChild(s);
}
</script>
<script type="text/javascript">
if (typeof jQuery == "undefined") {
  var s = document.createElement("script");
  s.src = "https://ajax.googleapis.com/ajax/libs/jquery/1.5.1/jquery.min.js";
  document.body.appendChild(s);
}
</script>
<script type="text/javascript">
\$(function() {
  \$.getJSON("http://otter.topsy.com/trackbacks.js?callback=?",
  {url: location.href},
  function(data) {
    var res = data.response;
    if (!res.list) {
      return false;
    }
    var text = "<ul>";
    for (var i = 0; i < res.list.length; i ++) {
      var item = res.list[i];
      text += "<li><a href=\\"" + item.author.url + "\\">";
      text += "<img src=\\"" + item.author.photo_url + "\\" width=\\"24\\" height=\\"24\\" />";
      text += "@" + item.author.url.replace("http://twitter.com/", "") + "</a>: ";
      text += item.content;
      text += " (<a href=\\"" + item.permalink_url + "\\">";
      text += item.date_alpha + "</a>)</li>";
    }
    if (res.total == 0) {
      text += "<li>Not yet.</li>";
    }
    text += "</ul>";
    if (res.total > 10) {
      text += "<a href=\\"" + res.topsy_trackback_url + "\\">Read all at Topsy</a>";
    }
    \$("#topsy_trackbacks").html(text);
  }
  );
});
</script>
Twitter Retweets:
<div id="topsy_trackbacks"></div>
EOD

    return $buf;
}

1;
