#!/usr/bin/perl

use strict;
use warnings;

my $argc = @ARGV;
my $format_file_name;
my $log_file_name;
my @columns;
my @regexes;
my @lines_to_write;

if ($argc < 2) {
    die("Error: argc ==  $argc < 2\n")
}


###########################
# Process the FORMAT file #
###########################

$format_file_name = $ARGV[0];

if (open(my $format_file_handle, "<" . $format_file_name)) {
    # Read the first line of column headers and add "unmatched"
    my $line = <$format_file_handle>;
    chomp($line);
    @columns = split(/\s*\,\s*/, $line);
    chomp(@columns);
    push @lines_to_write, join(",", @columns) . ",unmatched";
    # Read the second line of regexes for each column header
    # and add unmatched's catchall regex
    $line = <$format_file_handle>;
    chomp($line);
    @regexes = split(/\s*\,\s*/, $line);
    push @regexes, ".*";
    close $format_file_handle;
} else {
    die "Error: Could not open file $format_file_name\n";
}


########################
# Process the LOG file #
########################

$log_file_name = $ARGV[1];

if (open(my $log_file_handle, "<" . $log_file_name)) {
    my $timestamp_regex = "[0-9]{4}-[0-9]{2}-[0-9]{2}";

    while(<$log_file_handle>) {
        my $line = $_;
        my @matches;
        chomp($line);
        
        for (my $i = 0; $i < @regexes; ++$i) {
            my $r = $regexes[$i];
            if ($line =~ /($r)(.*)/) {
                push @matches, $1;
                $line = $2;
                chomp $line;
            } else { 
                # if a match is missed, consider fomat broken, fast forward
                # to the last regex that captures the remaining input into
                # the "unmatched" column.
                warn "Warning: \"", $line, "\" did not match with regex /^", $r, 
                     ". Placing remaining line in \"unmatched\"/\n";
                for (my $j = $i; $j < @regexes - 1; ++$j) {
                    push @matches, "";
                }
                $i = @regexes - 2;
            }
        }
        my $row_to_write = join(",", @matches);
        push @lines_to_write, $row_to_write;
    }

    close $log_file_handle;
} else {
    die "Error: Could not open file $log_file_name\n";
}

####################
# Write to LOG.csv #
####################

if (open(my $csv_file_handle, ">" . $log_file_name . ".csv" )) {
    foreach my $l (@lines_to_write) {
        print $csv_file_handle $l . "\n";
    }

    close $csv_file_handle;
} else {
    die "Error: Could not write to $log_file_name.csv.\n";
}






