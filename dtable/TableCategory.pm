###############################################################################
#
# ���ꥫ�ƥ���Υڡ������顢�ơ��֥��ɽ�����ޤ���
# <pre>
# {{tablecategory ���ƥ���̾,�����1,�����2,,}}
# </pre>
# �����˻��ꤵ�줿���ܤϡ�
# <pre>
# *����: ����
# </pre>
# �Ȥ����Ԥ�������ʬ��ɽ������ޤ���
#
###############################################################################
package plugin::dtable::TableCategory;
#use strict;
#use plugin::category::CategoryHandler;
use plugin::category::CategoryCache;
#==============================================================================
# ���󥹥ȥ饯��
#==============================================================================
sub new {
	my $class = shift;
	my $self  = {};
	return bless $self,$class;
}

#�ץ饰���󵭽�
sub paragraph {
    my $self    = shift;
    my $wiki    = shift;
    my $category = shift;
    my @orgcolumns  = @_;

    if($category eq ""){
	return &Util::paragraph_error("���ƥ���̾�����ꤵ��Ƥ��ޤ���");
    }

    my $sortkey = '@page';
    my $sortup = 1;
    my @columns;
    foreach my $column (@orgcolumns) {
	if ($column =~ /^>(.*)/) {
	    $column = $1;
	    $sortkey = $column;
	    $sortup = 0;
	} elsif ($column =~ /^<(.*)/) {
	    $column = $1;
	    $sortkey = $column;
	}
	push @columns, $column;
    }

    my $buf = make_table_category(@columns, $wiki, $category, $sortkey, $sortup);
    return $buf;
}

sub do_action {
    my $self = shift;
    my $wiki = shift;
    my $cgi = $wiki->get_CGI;

    my $category   = $cgi->param("category");
    my $columnlist = $cgi->param("columnlist");
    my $sortkey    = $cgi->param("column");
    my $sortd      = $cgi->param("d");

    my @columns = split(/,/, $columnlist);
    my $sortup;
    if ($sortd eq "up") {
	$sortup = 1;
    } else {
	$sortup = 0;
    }

    my $buf = make_table_category(@columns, $wiki, $category, $sortkey, $sortup);
    return $wiki->process_wiki($buf);
}

#==============================================================================
# ����饤��᥽�å�
#==============================================================================
sub make_table_category {
    my $sortup = pop;
    my $sortkey = pop;
    my $category = pop;
    my $wiki    = pop;
    my @columns  = @_;
    my $buf = "";

    my $columnlist = "";
    foreach my $column (@columns) {
	if ($columnlist ne "") {
	    $columnlist .= "%2C";
	}
	$columnlist .= $column;
    }

    my $cachefile = $wiki->config('log_dir')."/category.cache";
    if(!(-e $cachefile)){
	&plugin::category::CategoryCache::create_cache($wiki);
    }
    my $result = &Util::load_config_hash(undef,$cachefile);
    my @pagenames = split(/\t/,$result->{$category});
    my @pages;
    foreach my $tablepage (@pagenames) {
	my $content = $wiki->get_page($tablepage);
	my $hash = {};
	$hash->{'@page'} = $tablepage;
	foreach my $column (@columns) {
	    my $columnptn = quotemeta($column);
	    if ($content =~ /\*\s*$columnptn:\s*(.*)[\r\n]/) {
		$hash->{$column} = $1;
	    }
	}
	push (@pages, $hash);
    }

    # �����ȡ����ͤ� <=> �ˤ����ۤ����ɤ���
    if ($sortup) {
	@pages = sort {$a->{$sortkey} cmp $b->{$sortkey}} @pages;
    } else {
	@pages = sort {$b->{$sortkey} cmp $a->{$sortkey}} @pages;
    }

    my $script = $wiki->config('script_name');
    $script .= "?category=".&Util::escapeHTML($category);
    $script .= "&columnlist=".&Util::escapeHTML($columnlist);
    $buf .= ",[�ڡ���̾|$script&action=TABLECATEGORY_SORT&column=".'@page';
    if ($sortkey eq '@page' && $sortup == 1) {
	$buf .= "&d=down";
    } else {
	$buf .= "&d=up";
    }
    $buf .= "]";
    $buf .= "<[�ɲ�|$script&action=TABLECATEGORY_ENTRY]>";
    foreach my $column (@columns) {
	$buf .= ",[".$column."|$script&action=TABLECATEGORY_SORT&column=".&Util::escapeHTML($column);
	if ($sortkey eq $column && $sortup == 1) {
	    $buf .= "&d=down";
	} else {
	    $buf .= "&d=up";
	}
	$buf .= "]";
    }
    $buf .= "\n";

    foreach my $tablepage (@pages) {
	$buf .= ",".$tablepage->{'@page'};
	foreach my $column (@columns) {
	    $buf .= ",".$tablepage->{$column};
	}
	$buf .= "\n";
    }
    return $buf;
}

1;
