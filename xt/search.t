use Test::More;
use Data::Dumper;
use Log::Any::Adapter;
use Log::Any::Adapter::Screen;

Log::Any::Adapter->set('Screen',
     min_level => 'debug', 
     stderr    => 0, # print to STDOUT instead of the default STDERR
    
);

plan skip_all => "environment variable \$WSKEY not set!" unless ($ENV{WSKEY});


use_ok( 'WWW::Europeana' );



diag( "Testing WWW::Europeana $WWW::Europeana::VERSION" );



my $Europeana = WWW::Europeana->new(wskey=>$ENV{WSKEY});

my $result = $Europeana->search(query=>"Österreich", rows=>1, profile=>"minimal", reusability=>"open");

is($result->{success},1,"Search successful");
is($result->{itemsCount},1,"Correct number of rows returned");

print Dumper($result);

done_testing;
