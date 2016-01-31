package WWW::Europeana;

use warnings;
use strict;

use version; our $VERSION = qv('0.0.1');

use JSON;
use Log::Any;
use LWP::Simple;
use Moo;
use Method::Signatures;
use Try::Tiny;
use URL::Encode qw(url_encode);

has 'api_url' => ( is => 'ro', default  => 'http://www.europeana.eu/api/v2/' );
has 'wskey'   => ( is => 'ro', required => 1 );

has log => (
    is      => 'ro',
    default => sub { Log::Any->get_logger },
);

=head1 METHODS

=head2 search(query=> "Europe", profile=>'standard', rows => 12)

for further explanation of the possible parameters please refer to
<http://labs.europeana.eu/api/search>

=over 4

=item * query	

The search term(s).

=item * profile	

Profile parameter controls the format and richness of the response. See the possible values of the profile parameter.

=item * qf  

Facet filtering query.

=item * reusability  

Filter by copyright status. Possible values are open, restricted or permission.

=item * media   

Filter by records where an URL to the full media file is present in the edm:isShownBy or edm:hasView metadata and is resolvable.

=item * colourpalette 

Filter by images where one of the colours of an image matches the provided colour code. You can provide this parameter multiple times, the search will then do an 'AND' search on all the provided colours. 

=item * sort 

Sort records by certain fields, currently only timestamp_created and timestamp_update are supported. Use: field+sort_order, example: &sort=timestamp_update+desc

=item * rows 

The number of records to return. Maximum is 100. Defaults to 12. 

=item * start  

The item in the search results to start with when using cursor-based pagination. The first item is 1. Defaults to 1. 

=item * cursor 

Cursor mark from where to start the search result set when using deep pagination. Set to * to start cursor-based pagination.

=item * callback  

Name of a client side callback function.

=item * facet*	

Name of an individual facet. 

=back

=cut

method search(Str :$query, Str :$profile = "standard", Int :$rows = 12, Int :$start = 1, Str :$reusability ) {
    my $query_string = undef;
    my $json_result  = undef;
    my $result_ref   = undef;

    $query_string = sprintf( "%s%s?wskey=%s&rows=%s&query=%s&profile=%s",
        $self->api_url, "search.json", $self->wskey, $rows, url_encode($query), $profile );

    $query_string .= "&reusability=".$reusability if ($reusability);

    $self->log->infof( "Query String: %s", $query_string );

    $json_result = get($query_string);
    try {
        $result_ref = decode_json($json_result);
    }
    catch {
        $self->log->errorf( "Decoding of response '%s' failed: %s",
            $json_result, $_ );
    };

    if ($result_ref) {
        $self->log->info("Search was a success!")
          if (
               ( $result_ref->{success} )
            && ( $result_ref->{success} == 1 ));
	}
        $self->log->infof("%d item(s) of a total of %d results returned", 
			  $result_ref->{itemsCount},
			  $result_ref->{totalResults}
			 ) 
	  if (($result_ref->{itemsCount}) && ($result_ref->{totalResults}));

        return $result_ref;

 }

1;    # Magic true value required at end of module
__END__

=head1 NAME

WWW::Europeana - [One line description of module's purpose here]


=head1 VERSION

This document describes WWW::Europeana version 0.0.1


=head1 SYNOPSIS

    use WWW::Europeana;

=for author to fill in:
    Brief code example(s) here showing commonest usage(s).
    This section will be as far as many users bother reading
    so make it as educational and exeplary as possible.
  
  
=head1 DESCRIPTION

=for author to fill in:
    Write a full description of the module and its features here.
    Use subsections (=head2, =head3) as appropriate.


=head1 INTERFACE 

=for author to fill in:
    Write a separate section listing the public components of the modules
    interface. These normally consist of either subroutines that may be
    exported, or methods that may be called on objects belonging to the
    classes provided by the module.


=head1 DIAGNOSTICS

=for author to fill in:
    List every single error and warning message that the module can
    generate (even the ones that will "never happen"), with a full
    explanation of each problem, one or more likely causes, and any
    suggested remedies.

=over

=item C<< Error message here, perhaps with %s placeholders >>

[Description of error here]

=item C<< Another error message here >>

[Description of error here]

[Et cetera, et cetera]

=back


=head1 CONFIGURATION AND ENVIRONMENT

=for author to fill in:
    A full explanation of any configuration system(s) used by the
    module, including the names and locations of any configuration
    files, and the meaning of any environment variables or properties
    that can be set. These descriptions must also include details of any
    configuration language used.
  
WWW::Europeana requires no configuration files or environment variables.


=head1 DEPENDENCIES

=for author to fill in:
    A list of all the other modules that this module relies upon,
    including any restrictions on versions, and an indication whether
    the module is part of the standard Perl distribution, part of the
    module's distribution, or must be installed separately. ]

None.


=head1 INCOMPATIBILITIES

=for author to fill in:
    A list of any modules that this module cannot be used in conjunction
    with. This may be due to name conflicts in the interface, or
    competition for system or program resources, or due to internal
    limitations of Perl (for example, many modules that use source code
    filters are mutually incompatible).

None reported.


=head1 BUGS AND LIMITATIONS

=for author to fill in:
    A list of known problems with the module, together with some
    indication Whether they are likely to be fixed in an upcoming
    release. Also a list of restrictions on the features the module
    does provide: data types that cannot be handled, performance issues
    and the circumstances in which they may arise, practical
    limitations on the size of data sets, special cases that are not
    (yet) handled, etc.

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-www-europeana@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.


=head1 AUTHOR

Peter Mayr  C<< <at.peter.mayr@posteo.de> >>


=head1 LICENCE AND COPYRIGHT

Copyright (c) 2015, Peter Mayr C<< <at.peter.mayr@posteo.de> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.


=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.
