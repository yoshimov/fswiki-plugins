############################################################
# 
# <p>FreeStyleWiki上でGraphvizのDOT形式を表示します。</p>
# <pre>
# {{graphviz
# digraph G {
#        this -> that;
#        that -> theother;
#        theother -> this;
#    }
# }}
# </pre>
#
############################################################
package plugin::graphviz::Graphviz;

use strict;
#===========================================================
# コンストラクタ
#===========================================================
sub new {
	my $class = shift;
	my $self = {};
	return bless $self,$class;
}

#===========================================================
# Graphviz dot表示
#===========================================================
sub block {
  my $self        = shift;
  my $wiki        = shift;
  my $dot_source = shift;
  my $content = <<"EOF";
<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.5.1/jquery.min.js"></script>
<script type="text/javascript" src="http://gviz.oodavid.com/gviz.js"></script>
<script type="gviz" data-layout="dot"><![CDATA[
EOF

  $content .= $dot_source;
  $content .= <<"EOF";
]]></script>
EOF

  return $content;
}

1;
