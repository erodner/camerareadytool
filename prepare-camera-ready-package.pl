#!/usr/bin/perl -w

# Author: Erik Rodner
# github: https://github.com/erodner

use strict;

my @keywords = qw(includegraphics input bibliography documentclass bibliographystyle);

my $extensions = { 'documentclass' => 'cls',
                   'bibliography' => 'bib',
				           'includegraphics' => '{eps,pdf,jpg,png,jpeg,ps}',
                   'bibliographystyle' => 'bst' };

my @files = @ARGV;
my $info = "prepare-camera-ready-package 1.2 by Erik Rodner\n" .
           "\nThis package outputs a list of files (images, bibtex, latex styles) that should be included in a source package.\n".
           "It also includes standard copyright pdf files (copyright*.pdf) and reference pdfs (reference*.pdf) useful for camera ready submissions.\n";

if ( !scalar(@files) )
{
    die ("$info\nusage: $0 <latex-files ...>\n");
}

# hash to avoid duplicate outputs
my %h;

for my $file (@files)
{
  next if ( exists $h{$file} );

  my $dir = `dirname $file`;
  chomp $dir;

  open ( FILE, "<$file" ) or die ("$file: $!\n");

  while (<FILE>)
  {
    chomp;

    # ignore latex comments for parsing
    /^\s*%/ && next;

    # search for each latex command keywords
    for my $k ( @keywords )
    {
      my $line = $_;
      # parse latex command also with optional [] arguments 
      while ( $line =~ /\\$k(?:\[.*?\])?\{(.+?)\}/g ) {
        # get the filename mentioned 
        my $inc = $1;

        # check for file presence 
        if ( -f $inc )
        {
          print "$inc\n";
        } else {
          # it looks like the extension was not given
          # standard case use everything
          my $ext = "*"; 
          if ( defined($extensions->{$k}) )
          {
            # only use some extensions that are most likely
            $ext = $extensions->{$k};
          }
          my @list = `ls $inc.$ext 2>/dev/null`;
          if ( scalar(@list) ) {
            for my $l (@list)
            {
              chomp $l;
              if ( ! exists $h{$l} )
              {
                print "$l\n";
                $h{$l} = 1;
              }
            }
          } else { 
            warn ( "$file: $inc is included but not found!" );
          }
        }
      }
    }
  }

  close ( FILE );

  print "$file\n";
  $h{$file} = 1;
}

# optionally include Makefile, copyright and reference statements
print `ls Makefile 2>/dev/null`;
print `ls copyright*.pdf 2>/dev/null`;
print `ls reference*.pdf 2>/dev/null`;
