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
  my $count = shift;
  my $buf = "";

  if ($count eq "") {
    $count = "none";
  }
  
    $buf .= <<"EOD";
<a href="http://twitter.com/share"
  class="twitter-share-button"
  data-count="$count"
  data-via="$id">Tweet</a>
<script type="text/javascript" src="http://platform.twitter.com/widgets.js"></script>
EOD

    return $buf;
}

1;
