package Path::Class::Versioned;
use Moose;
use MooseX::Types::Path::Class;
use MooseX::Params::Validate;

use List::Util 'max';

our $VERSION   = '0.01';
our $AUTHORITY = 'cpan:STEVAN';

has 'name_pattern'   => (is => 'ro', isa => 'ArrayRef[Str | Undef]', required => 1);
has 'version_format' => (is => 'ro', isa => 'Str', default => sub { '%d' });

has '_compiled_name_pattern' => (
    is      => 'ro',
    isa     => 'Regexp',   
    lazy    => 1,
    default => sub {
        my $self = shift;
        my $name_pattern = join "" => (map { defined $_ ? $_ : '(\d+)' } @{ $self->name_pattern });
        qr/$name_pattern/;
    },
);

has 'parent' => (
    is      => 'ro',
    isa     => 'Path::Class::Dir',
    coerce  => 1,
    default => sub { Path::Class::Dir->new }
);

sub next_file {
    my $self = shift;
    $self->parent->file($self->next_name(file => 1));
}

sub next_dir {
    my $self = shift;
    $self->parent->subdir($self->next_name(dir => 1));
}

sub next_name {
    my ($self, $is_dir, $is_file) = validatep(\@_, 
        dir  => { isa => 'Bool', optional => 1 },
        file => { isa => 'Bool', optional => 1, default => 1 }        
    );
    
    my $name_extractor = $is_dir
        ? sub { (shift)->relative($self->parent)->stringify }
        : sub { (shift)->basename };
    
    my $name_pattern = $self->_compiled_name_pattern;
    my $max_version  = max(
        map { 
            ($name_extractor->($_) =~ /$name_pattern/) 
        } grep { 
            ($is_dir ? (-d $_) : (-f $_)) 
        } $self->parent->children
    );
    
    $max_version = 0 unless defined $max_version;
    
    my $next_version = sprintf $self->version_format, ($max_version + 1);
    
    join "" => (map { defined $_ ? $_ : $next_version } @{ $self->name_pattern });
}

no Moose; 1;

__END__

=pod

=head1 NAME

Path::Class::Versioned - A Moosey solution to this problem

=head1 SYNOPSIS

  use Path::Class::Versioned;

=head1 DESCRIPTION

Cmon, you know you have done this too, so why bother writing it over
and over again, just use this module.

=head1 METHODS 

=over 4

=item B<>

=back

=head1 BUGS

All complex software has bugs lurking in it, and this module is no 
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=head1 AUTHOR

Stevan Little E<lt>stevan.little@iinteractive.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2008 Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
