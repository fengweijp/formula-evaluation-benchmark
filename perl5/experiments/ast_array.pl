use strict;
use warnings;
use Time::HiRes qw/gettimeofday tv_interval/;

use constant {
    ADD       => 0,
    SUBSTRACT => 1,
    MULTIPLY  => 2,
    DIVIDE    => 3,
    SUM       => 4
};

my @functions;

$functions[ADD] = sub {
    my $args = shift;
    return $args->[0] + $args->[1];
};

$functions[SUBSTRACT] = sub {
    my $args = shift;
    return $args->[0] - $args->[1];
};

$functions[MULTIPLY] = sub {
    my $args = shift;
    return $args->[0] * $args->[1];
};

$functions[DIVIDE] = sub {
    my $args = shift;
    return $args->[0] / $args->[1];
};

$functions[SUM] = sub {
    my $args = shift;
    my $sum = 0;

    foreach my $arg (@$args) {
        $sum += $arg;
    }

    return $sum;
};

sub evaluate_ast {
    my $ast = shift;

    my $oper = $ast->[0];
    my $func = $functions[$oper];

    my @evaluated_args;

    for ( my $i = 1; $i < @$ast; $i++ ) {
        if ( ref $ast->[$i] eq 'ARRAY' ) {
            push @evaluated_args, evaluate_ast( $ast->[$i] );
        } else {
            push @evaluated_args, $ast->[$i];
        }
    }

    return $func->(\@evaluated_args);
}

sub time_ast {
    my $ast = shift;
    my $t0 = [gettimeofday];

    my $iterations = 100_000;
    my $sum = 0;

    for (1..$iterations) {
        $sum += evaluate_ast($ast);
    }

    my $compute_time = tv_interval($t0);

    print "COMPUTED [$iterations] ITERATIONS IN [$compute_time] SECONDS\n";

    die "WRONG SUM $sum" if abs( $sum - 3900000) > 0.001; # ensure that code was executed
}

my $ast = [SUM,
    [ SUBSTRACT,[ADD,[DIVIDE,[MULTIPLY,10,20],30],40],50],
    [ SUBSTRACT,[ADD,[DIVIDE,[MULTIPLY,20,30],40],50],60],
    [ SUBSTRACT,[ADD,[DIVIDE,[MULTIPLY,30,40],50],60],70],
    [ SUBSTRACT,[ADD,[DIVIDE,[MULTIPLY,40,50],60],70],80]
];

time_ast($ast);
