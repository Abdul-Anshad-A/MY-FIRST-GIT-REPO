#!/usr/bin/perl
use strict;
use warnings;
use 5.010;
     
my $dirpath = shift || '.';
     
traverse($dirpath);
     
sub traverse 
	{
		my ($thing) = @_;
		return if not -d $thing;
		if( -d $thing)
			{
				say $thing;
			}
		opendir my $dh, $thing or die;
		while (my $sub = readdir $dh)
			{
				next if $sub eq '.' or $sub eq '..';
     
				traverse("$thing/$sub");
			}
		close $dh;
		return;
	}
