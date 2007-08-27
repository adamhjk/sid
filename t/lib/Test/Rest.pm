#
# Rest.pm
# Created by: Adam Jacob, Marchex, <adam@marchex.com>
# Created on: 10/16/2006 11:11:25 AM PDT
#
# $Id: $

package Test::Rest;

use strict;
use warnings;

use LWP::UserAgent;
use URI;
use Params::Validate qw(:all);
use YAML::Syck;
$YAML::Syck::ImplicitTyping = 1;

sub new {
    my $self = shift;
    my %p = validate(@_,
        {
            content_type => { type => SCALAR },
        },
    );
    my $ref = { 
        'ua' => LWP::UserAgent->new,
        'content_type' => $p{'content_type'},
    };
    bless $ref, $self;
}

sub load {
    my $self = shift;
    my $data = shift;
    return Load($data);
}

sub get {
    my $self = shift;
    my %p = validate(@_,
        {
            url => { type => SCALAR },
            params => { type => ARRAYREF, optional => 1 },
        },
    );

    my $url = URI->new($p{'url'});
    if (defined($p{'params'})) {
        $url->query_form($p{'params'});
    }
    my $req = HTTP::Request->new('GET' => $url);
    $req->content_type($self->{'content_type'});
    return $req;
}

sub delete {
    my $self = shift;
    my %p = validate(@_,
        {
            url => { type => SCALAR },
        },
    );
    my $req = HTTP::Request->new('DELETE' => $p{'url'});
    $req->content_type($self->{'content_type'});
    return $req;
}

sub put {
    my $self = shift;
    my %p = validate(@_,
        {
            url => { type => SCALAR },
            data => 1,
        },
    );
    my $data = Dump($p{'data'});
    my $req = HTTP::Request->new('PUT' => $p{'url'});
    $req->content_type($self->{'content_type'});
    $req->content_length(do { use bytes; length($data) });
    $req->content($data);
    return $req;
}

sub post {
    my $self = shift;
    my %p = validate(@_,
        {
            url => { type => SCALAR },
            data => { required => 1 },
        },
    );
    my $data = Dump($p{'data'});
    my $req = HTTP::Request->new('POST' => $p{'url'});
    $req->content_type($self->{'content_type'});
    $req->content_length(do { use bytes; length($data) });
    $req->content($data);
    return $req;
}


1;

