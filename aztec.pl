#!/usr/bin/perl -w
use strict;
use autodie;
use Barcode::Code128;
use File::Temp qw(tempfile);

my $usb_id = 0;

my @bitmaps;

while (@ARGV) {
    my ($fh, $fn) = tempfile;

    my $data = shift;

    # "--ver 4" makes for 27x27 compact aztec, --scale 2 makes that a 108x108 bitmap
    open my $pipe_zint, "-|", qw[zint --barcode 92 --ver 4 --scale 2 --directpng --data], $data;

    # "-size x20" is because there are 128 - 108 = 20 pixels left for text, and
    # "-pointsize 16" turns out to be 20 pixels high; auto scaling with "-size
    # x20" results in smaller text.
    open my $pipe_convert, "|-", qw[convert -gravity center PNG:- +antialias -font DejaVu-Sans-Mono-Bold -pointsize 16], "label:$data", qw[-append], "PBM:$fn";
    local $/ = \8192;
    print $pipe_convert $_ while defined($_ = readline $pipe_zint);
    close $pipe_convert;

    push @bitmaps, $fn;
}

#system file => @bitmaps;
#system qiv => @bitmaps;
system "./ptouch-770-write", $usb_id, @bitmaps;

unlink @bitmaps;
