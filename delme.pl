#!/usr/bin/perl



@orig=();


@array=`perl Directory.pl /apps/apache/current`;
chomp(@array);

        my %orig=map{$_ =>1} @orig;
        my %array=map{$_=>1} @array;
        my @failed=grep(!defined $array{$_}, @orig);
        printf "Failed test cases:\t$_\n" foreach (@failed);
