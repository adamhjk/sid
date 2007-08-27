package Sid::Web::View::TT;

use strict;
use base 'Catalyst::View::TT';

__PACKAGE__->config({
    CATALYST_VAR => 'Catalyst',
    INCLUDE_PATH => [
        Sid::Web->path_to( 'root', 'src' ),
        Sid::Web->path_to( 'root', 'lib' )
    ],
    PRE_PROCESS  => 'config/main',
    WRAPPER      => 'site/wrapper',
    ERROR        => 'error.tt2',
    TIMER        => 0
});

=head1 NAME

Sid::Web::View::TT - Catalyst TTSite View

=head1 SYNOPSIS

See L<Sid::Web>

=head1 DESCRIPTION

Catalyst TTSite View.

=head1 AUTHOR

Adam Jacob

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

