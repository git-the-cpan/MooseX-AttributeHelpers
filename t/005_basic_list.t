#!/usr/bin/perl

use strict;
use warnings;

use Test::More no_plan => 1;
use Test::Exception;

BEGIN {
    use_ok('MooseX::AttributeHelpers');   
}

{
    package Stuff;
    use Moose;

    has 'options' => (
        metaclass => 'Collection::List',
        is        => 'ro',
        isa       => 'ArrayRef[Int]',
        default   => sub { [] },
        provides  => {
            'count'   => 'num_options',
            'empty'   => 'has_options',        
            'map'     => 'map_options',
            'grep'    => 'filter_options',
            'find'    => 'find_option',
        }
    );
}

my $stuff = Stuff->new(options => [ 1 .. 10 ]);
isa_ok($stuff, 'Stuff');

can_ok($stuff, $_) for qw[
    num_options
    has_options
    map_options
    filter_options
    find_option
];

is_deeply($stuff->options, [1 .. 10], '... got options');

ok($stuff->has_options, '... we have options');
is($stuff->num_options, 10, '... got 2 options');

is_deeply(
[ $stuff->filter_options(sub { $_[0] % 2 == 0 }) ],
[ 2, 4, 6, 8, 10 ],
'... got the right filtered values'
);

is_deeply(
[ $stuff->map_options(sub { $_[0] * 2 }) ],
[ 2, 4, 6, 8, 10, 12, 14, 16, 18, 20 ],
'... got the right mapped values'
);

is($stuff->find_option(sub { $_[0] % 2 == 0 }), 2, '.. found the right option');

## test the meta

my $options = $stuff->meta->get_attribute('options');
isa_ok($options, 'MooseX::AttributeHelpers::Collection::List');

is_deeply($options->provides, {
    'map'     => 'map_options',
    'grep'    => 'filter_options',
    'find'    => 'find_option',
    'count'   => 'num_options',
    'empty'   => 'has_options',    
}, '... got the right provies mapping');

is($options->container_type, 'Int', '... got the right container type');
