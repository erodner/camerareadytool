#!/usr/bin/perl -w

use strict;

my @keywords = qw(includegraphics input);

my @graphicspaths;
push @graphicspaths, "img";
push @graphicspaths, ".";

my $file = shift;
if ( !defined($file) )
{
    die ("usage: $0 <latex-file>\n");
}

my $dir = `dirname $file`;
chomp $dir;

my $fignr = 0;
my $subfignr = 0;
open ( FILE, "<$file" ) or die ("$file: $!\n");

while (<FILE>)
{
    my $f;
    my $skipline = 0;

   next if ( /^ *%/ );

    if ( /\\begin\{figure.?\}/ )
    {
	$fignr++;
	$subfignr = 0;
    }

    if ( /includegraphics[^\{]*\{([^\}]+)\}/  )
    {
        $f = $1;
        my ($ext) = ($f =~ /\.([^\.\/]+)$/);
        my $ff = $f;
        if ( !defined($ext) ) {
            $ext = "pdf";
            $f = "$f.pdf";
        }
        my $subfigt = "_$subfignr";
        my $newfile = "fig$fignr$subfigt\.$ext";

        my $srcf;
        for my $p (@graphicspaths) {
            if ( -f "$dir/$p/$f" ) {
                $srcf = "$dir/$p/$f";
                last;
            }
        }
        if (!defined($srcf)) {
            die ("unable to access $dir/$f; document line: $_");
        }

		`cp $srcf $newfile`;
        s/$ff/$newfile/;
        $subfignr++;
    }

    if ( /input\{([^\}]+)\}/  )
    {
        $skipline = 1;
        my $subfn = $1;
        if ( ! -e $subfn ) {
            $subfn = "$subfn.tex";
        }
        open ( SUBFILE, "<$subfn" ) or die ("$subfn: $!");
        print <SUBFILE>;
        close ( SUBFILE );
        print "\n";
    }

    if (! $skipline ) {
        print $_;
    }
}

close ( FILE );
