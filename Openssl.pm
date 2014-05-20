package Openssl;
require CommonTestCase;
use 5.010;
use Term::ANSIColor;
use LWP::Simple;
$total_testcase=6;
state $passed_testcase=0;
@test_case_names=("Installation and tree structure","Package removal and tree structure","Package directory structure and file types","FIPS mode test", "BLAH BLAH !!");

sub ModMain
        {
                @package_path=@_;
                $path=@_[0];
                $package=@_[1];
		$remove=@_[2];
		$version=@_[3];
                $platform=@_[4];
                $arch=@_[5];
                $tomcatPath=@_[6];
                ($passed_testcase, @passed) = CommonTestCase::ModMain($path, $package, $remove, $version, $platform, $arch, $tomcatPath);
		Summary();
		
        }





sub Summary
{

        printf "%s", colored("\nTotal no.of test cases: $total_testcase\n", 'yellow');
        printf "%s", colored("Total no.of passed test cases: $passed_testcase\n", 'yellow');
        my $failed=$total_testcase - $passed_testcase;
        printf "%s", colored("Total no.of failed test cases: $failed\n", 'yellow');

        my %test_case_names=map{$_ =>1} @test_case_names;
        my %passed=map{$_=>1} @passed;
        my @failed=grep(!defined $passed{$_}, @test_case_names);
        printf "Failed test cases:\t$_\n" foreach (@failed);


}


1;
