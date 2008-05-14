#!/usr/bin/perl

use strict;
use warnings;
use FindBin;

use Test::More no_plan => 1;
use Test::Exception;

BEGIN {
    use_ok('Path::Class::Versioned');
}

my $SCRATCH_DIR = Path::Class::Dir->new($FindBin::Bin, 'scratch');

my $v = Path::Class::Versioned->new(
    version_format => '%04d',
    name_pattern   => [ 'Bar-2008-05-14-v', undef, '.txt' ],
    parent         => $SCRATCH_DIR
);
isa_ok($v, 'Path::Class::Versioned');

foreach my $i (4 .. 10) {
    is($v->next_name, ('Bar-2008-05-14-v' . (sprintf "%04d" => $i) . '.txt'), '... got the right next filename');
    my $f = $v->next_file;
    isa_ok($f, 'Path::Class::File');
    $f->touch;
}

$SCRATCH_DIR->file(('Bar-2008-05-14-v' . (sprintf "%04d" => $_) . '.txt'))->remove foreach (4 .. 10);