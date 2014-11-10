#!/usr/bin/perl -w
#
use strict;

for my $file ( @ARGV )
{
    if ( $file =~ /tex$/ )
    {
        `cp $file $file.withComments`;
        my @a = `cat $file`;
        open ( FILE, ">$file" ) or die ("$file: $!\n");
        for my $l (@a)
        {   
            if ( $l !~ /^\s*%/ )
            {
                $l =~ s/[\w\s]%[\w\s]+$//g;
                print FILE $l;
            }
        }
        close ( FILE );

        print `diff -uBw $file.withComments $file`;
    }
}
