LogToCSV Perl Script
By Bryan Tsai


NAME
    
    LogToCSV - Convert a Log to a CSV format

SYNOPSIS
    
    LogToCSV.pl [FORMAT] [FILE]...

DESCRIPTION
    
    Convert each FILE according to the format given in the FORMAT file
    assuming that each line in FILE maps to each row in the resulting CSV.
    FORMAT files must be formatted as a CSV wherein the first row provides
    a list of column names, and the second row provides regular expressions
    that capture input to be placed under each corresponding column.
    Any uncaptured or unmatching input will be placed under an extra column 
    so no loss of information occurs.

EXAMPLE
    
    LogToCSV.pl format log

    format:
    ****
    timestamp, pid, type, message
    [0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}, [0-9]{4}, \[\w*\], .*$
    ****

    log:
    ****
    2017-10-09 23:22:16 3443 [Note] /rdsdbbin/mysql/bin/mysqld: ready for connections.
    ****

    yields log.csv:
    ****
    timestamp, pid, type, message, unmatched
    2017-10-09 23:22:16,3443,[Note],/rdsdbbin/mysql/bin/mysqld: ready for connections.,
    ****

UNCAUGHT EDGE CASES AND NOTES
    
    May not handle regexes in the format file that contain ,'s (commas) properly.
    
    Not CSV RFC4180 compliant. May not handle FORMAT file CSV whose elements
    contain commans, double quotes, CRLF properly.
