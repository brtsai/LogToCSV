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

print "format_file_name == $format_file_name\n";

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

foreach my $r (@regexes) {
    print "regex ", $r, " added to the regex array.\n"; 
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
                print $1, " matched with regex /^", $r, "/\n";
                push @matches, $1;
                print "remainder is now ", $2, "\n";
                $line = $2;
                chomp $line;
            } else { 
                # if a match is missed, consider fomat broken, fast forward
                # to the last regex that captures the remaining input into
                # the "unmatched" column.
                print $line, " did not match with regex /^", $r, "/\n";
                print "fast forwarding to unmatch'd column.\n";
                for (my $j = $i; $j < @regexes - 1; ++$j) {
                    push @matches, "";
                }
                $i = @regexes - 2;
            }
        }
        my $row_to_write = join(",", @matches);
        print "new row to be inserted is: \'", $row_to_write, "\'\n";
        push @lines_to_write, $row_to_write;
    }

    close $log_file_handle;
} else {
    die "Error: Could not open file $log_file_name\n";
}

####################
# Write to LOG.csv #
####################

print "Now printing rows to be written to ", $format_file_name, ".csv\n";
print "\n";

foreach my $l (@lines_to_write) {
    print $l, "\n";
}








