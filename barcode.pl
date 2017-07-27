#!/usr/bin/perl -w
use strict;
use autodie;
use Barcode::Code128;
use File::Temp qw(tempfile);

my $usb_id = 1;

my $b = Barcode::Code128->new;
$b->option(scale => 2);
$b->option(height => 64);
$b->option(border => 0);
$b->option(font => 'giant');
$b->option(font_align => 'center');
$b->option(font_margin => 0);

my @bitmaps;

while (@ARGV) {
    my ($fh, $fn) = tempfile;

    open my $pipe, "|-", qw[convert PNG:- -gravity center -extent x128
        -background white], "PBM:$fn";
    print $pipe $b->png(shift);
    close $pipe;

    push @bitmaps, $fn;
}

system "./ptouch-770-write", $usb_id, @bitmaps;

unlink @bitmaps;
