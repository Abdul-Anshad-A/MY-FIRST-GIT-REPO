#!/usr/bin/perl
package Modsecurity;
require CommonTestCase;
require LogMe;
#use strict;
#use warnings;
use 5.010;
use Term::ANSIColor;
use LWP::Simple;

### LOGGING ####
*log = LogMe::logger;

#### To capture standard errof for mlogc ####
use IPC::Open3;
use File::Spec;
use Symbol qw(gensym);


$total_testcase=6;
state $passed_testcase=0;
@test_case_names=("Installation and tree structure","Package removal and tree structure","Package directory structure and file types","Dynamic libraries","Functional test","Apache no log check");
@passed;

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
                ($passed_testcase, $package_install, $tree1, $tree, $file_types, $package_struct, $package_size, $list_directory, $directory, $link, @passed) = CommonTestCase::ModMain($path, $package, $remove, $version, $platform, $arch, $tomcatPath);
		DynamicLib();
		FuncTest();
		ApacheNoLog();
		Summary();
		PrintMe::ModMain($package_install, $tree1, $tree, $file_types, $package_struct, $package_size, $list_directory, $directory, $link, $modso, $fileso, $libpcrestat, $ldd_modssl, $ldd_mlogc, $link1, $link2, $active_rules, $httpd_stat, $load_mod, $error_log, $htpd_stat2, $patch_audit_log, $patch_error_log, $path, $package, $remove, $version, $platform, $arch, $tomcatPath, @mlogc_ver);
	}

sub DynamicLib
	{
		state $dyntestcase=0;
		printf "%s\n", colored( "\n\nTEST CASE: Dynamic Libraries\n\n", 'green' );
		#print "\n\n";
		#print "Dynamic Libraries";
		#system("ldd /apps/apache/current/modules/mod_security2.so");
		$log->info("Checking for dynamic library files in mod_security2.so and mlogc ...");
		$ldd_modssl=`ldd /apps/apache/current/modules/mod_security2.so`;
		system("ldd /apps/apache/current/modules/mod_security2.so | grep -i not");
                my $retcode1=system("ldd /apps/apache/current/modules/mod_security2.so | grep -i not");
		#system("ldd  ldd /apps/mod_security/current/bin/mlogc");
		$ldd_mlogc=`ldd /apps/mod_security/current/bin/mlogc`;
		system("ldd /apps/mod_security/current/bin/mlogc | grep -i not");
                my $retcode2=system("ldd /apps/mod_security/current/bin/mlogc | grep -i not");

		if(($retcode1 && $retcode2) !=0)
			{
				#printf "%s", colored( "All Dynamic Library files are loaded\n", 'red');
				$log->info("All Dynamic Library files are loaded.");
				$dyntestcase++;
			}
		
		#To check wether libpcre is loaded
		$log->info("Checking wether libpcre is loaded ...");
		$libpcrestat=`ldd /apps/apache/current/modules/mod_security2.so | grep -i pcre`;
		my $libpcre=system("ldd /apps/apache/current/modules/mod_security2.so | grep -i pcre >/dev/null");
		if($libpcre!=0)
			{
				#printf "%s", colored("\nlibpcre is not loaded, please check it\n", 'yellow');
				$log->error("libpcre is not loaded, please check it");
			}
		else
			{
				#printf "%s", colored("libpcre is loaded\n", 'red');
				$log->info("libpcre is loaded");
				$dyntestcase++;
			}	

		
		$log->info("Checking the symlinks of libssl and libcrypto");
		$link1=`ls -l /usr/lib64/libcrypto.so.10`;
		$link2=`ls -l /usr/lib64/libssl.so.10`;
		#print $link;
		
		if(($link1 =~ /apps/) && ($link2 =~ /apps/ ) )
			{
				#printf "%s", colored( "Symlinks for libcrypto and libssl are correct\n", 'red');
				$log->info("Symlinks for libcrypto and libssl are correct");
				$dyntestcase++;
			}
		else
			{
				#printf "%s", colored( "\nSymlink for libcypto and libssl are incorrect, please check it\n", 'yellow');
				$log->error("Symlink for libcypto and libssl are incorrect, please check it.");
				system("ls -l /usr/lib64/libcrypto.so.10");
				system("ls -l /usr/lib64/libssl.so.10");
			}
		#printf "%s\n", colored( '0123456789', 'magenta' );

		$log->info("Checking wether mod_security2.so exists or not.");
		if(!(-e "/apps/apache/current/modules/mod_security2.so"))
			{
				#printf "%s", colored( "\nmod_security modules does not exits, please check it.\n", 'yellow');
				$log->error("mod_security modules does not exits, please check it.");
			}
		else
			{
				#printf "%s", colored("Mod_security module is present\n", 'red');
				$log->info("Mod_security module is present.");
				$modso=`ls -l /apps/apache/current/modules/mod_security2.so`;
				$fileso=`file /apps/apache/current/modules/mod_security2.so`;	
				$dyntestcase++;
			}



		#To check if all the sub test cased is passed or not
		if($dyntestcase==4)
			{
				$passed_testcase++;
				#print "\n".$passed_testcase;
				$log->info("PASSED TEST CASE : Dynamic libraries");
				push(@passed,"Dynamic libraries");
			}
	}



=pod
Basic functional testing when security module is loaded and httpd server is restarted.
=cut


sub FuncTest
	{

		#state $functestcase=0;
		printf "%s\n", colored( "\n\nTEST CASE: Functional Test\n\n", 'green' );

		#To add Include path of mod_auto_test.conf to httpd.conf
		$log->info("Checking wether Mod_Security config files are loaded in httpd.conf...");	
		$status12=system("grep /apps/apache/current/conf/mod_auto_test.conf /apps/apache/current/conf/httpd.conf >/dev/null");
		#printf "your are here : $status12\n";
		if($status12!=0)
			{	
				$log->info("Loading Mod_security config files ...");
				my $filename = '/apps/apache/current/conf/httpd.conf';
				open(my $fh, '>>', $filename) or die "Could not open file '$filename' $!";
				say $fh "Include /apps/apache/current/conf/mod_auto_test.conf";
				printf "%s", colored("Editing httpd.conf to load mod_security module . . \n", 'red');
				close $fh;
			}
		
		#To create the mod_auto_test.conf file

		my $mod_conf='/apps/apache/current/conf/mod_auto_test.conf';
		if( -e $mod_conf)
			{
				#print "/apps/apache/current/conf/mod_auto_test.conf file exists\n";
				$log->info("Mod_security Config file already exits.");
			}
		else
			{
				$log->info("Creating Mod_security config files");
				 my $filename2 = '/apps/apache/current/conf/mod_auto_test.conf';
		                 open(my $fh2, '>>', $filename2) or die "Could not open file '$filename2' $!";
				say $fh2 "LoadModule security2_module modules/mod_security2.so
LoadModule unique_id_module modules/mod_unique_id.so
<IfModule security2_module>
            Include /apps/mod_security/current/conf/modsecurity_crs_10_config.conf
            Include /apps/mod_security/current/conf/rules/activated_rules/*.conf
</IfModule>";
				#printf "%s", colored("Editing httpd.conf to include mod_security configuration files . . \n", 'red');
				$log->info("Editing httpd.conf to include mod_security configuration files ...");
               			 close $fh2;

				
			}
		

		#To create symlinks from base rules to activated rules
		#printf "%s", colored("Creating symlinks for activated_rules\n", 'red');
		$log->info("Creating symlinks for activated_rules");
		@list=`ls /apps/mod_security/current/conf/rules/base_rules/`;
		chomp(@list);
		foreach my $index (@list)
			 {	
				
				if(!( -e "/apps/mod_security/current/conf/rules/activated_rules/$index"))
					{
               					#symlink("/apps/mod_security/current/conf/rules/base_rules/$index", "/apps/mod_security/current/conf/rules/activated_rules/$index");
               					system("ln -s /apps/mod_security/current/conf/rules/base_rules/$index /apps/mod_security/current/conf/rules/activated_rules/$index");
					}
        		 }

		
		$active_rules=`ls -l /apps/mod_security/current/conf/rules/activated_rules/`;

		


		#To restart the httpd server
		$log->info("Functionality set up is all done !!");
		#printf "%s", colored( "\nRestarting httpd server\n", 'red');
		$log->info("Restarting httpd server ...");
		#system("/apps/apache/current/bin/httpd.init restart");

		$log->info("Using expect script for PASSPHRASE");
		system("./httpd_expect restart 91vis91");

		#Just checking wether the server is started or not
		$log->info("Checking Apache httpd server status");
		sleep(4);
		my $temp=`/apps/apache/current/bin/httpd.init status`;
		print "\n\n$temp\n\n";
		if($temp=~ /running/)
			{
				#Do nothing :-P
				#print "Httpd Server is started\n";
				$log->info("Httpd server started");
				$httpd_stat=1;
			}
		else
			{
				printf "%s", colored( "Httpd server is not started, please check it\n", 'yellow');
				$log->error("Httpd server is not started, please check it.");
				exit 1;
			} 

			
		#To check wether the mod_security module is loaded
		$log->info("Checking wether Mod_Security module is loaded or not.");
		my $modloadstat=system("/apps/apache/current/bin/httpd -M | grep sec");
		if($modloadstat !=0)
			{
				#printf "%s", colored( "Security Module is not loaded, Please check the httpd config file\n", 'yellow');
				$log->error("Security Module is not loaded, Please check the httpd config file.");
				exit 1;
			}
		else
			{
				#printf "%s", colored( "\nSecurity module is loaded\n", 'red');
				$log->info("Security module is loaded.");
				$load_mod=`/apps/apache/current/bin/httpd -M | grep sec`;
				$passed_testcase++;
				$log->info("PASSED TEST CASE : Functional test");
				push(@passed,"Functional test");
			} 
		#### APCHE ERROR LOG ###
		$error_log=`tail /apps/apache/current/logs/error_log`;
		open(NULL, ">", File::Spec->devnull);
		my $pid = open3(gensym, ">&STDERR", \*PH, "/apps/mod_security/current/bin/mlogc -v");
		while( <PH> ) {
        	@mlogc_ver=<PH>; }
    		waitpid($pid, 0);
		#print @mlogc_ver;

	}



=pod
mandatory test apache no log

mod security error log should only be logged on modsecurity logs and not in
apache error logs
=cut


sub ApacheNoLog
	{
	


		printf "%s\n", colored( "\n\nTEST CASE: Apache No Log Check\n\n", 'green' );		
		#copy("modsecurity_crs_10_config.conf", "/apps/mod_security/current/conf/");
		printf "%s", colored("\nCopying the new configuration file to test the Apache no log patch. . . .\n", 'red');
		system("cp -f modsecurity_crs_10_config.conf  /apps/mod_security/current/conf/");

		
		#To restart httpd server
		printf "%s", colored("\nRestarting httpd server\n", 'red');
		#system("/apps/apache/current/bin/httpd.init restart");
		
		system("./httpd_expect restart 91vis91");	
		sleep(4);
		my $temp=`/apps/apache/current/bin/httpd.init status`;
		print "\n\n$temp\n\n";
		if($temp=~ /running/)
			{
				
				$htpd_stat2=1;

			}		
		else
			{  
				printf "%s", colored("Httpd server is not started, please check it\n", 'yellow');
				exit 1;
			}

	
		#To Ensure log entry is made only in mod_error log and not in apache_error log.

		my $httpd_error_log="/apps/apache/current/logs/error_log";
                my $mod_error_log="/var/log/modsec_audit.log";
                my $size_httpd= -s "$httpd_error_log";
                my $size_mod= -s "$mod_error_log";

		#print "\n\n Access the link from browser and then press enter \n\n";
		#$enter=<STDIN>;
		#
		#
		#
		my $url = 'http://localhost/?abc=../../';
		printf "%s", colored("Accessing the URL http://localhost/?abc=../../ \n", 'red');
		my $content = get $url;
		#die "Couldn't get $url" unless defined $content;
		
		sleep(5);
		if((-s "/apps/apache/current/logs/error_log")!=$size_httpd)
			{
				printf "%s", colored( "\nApache log has changed, No log pactch doesn't seem to be working !!\n", 'yellow');
				
			}
		if((-s "/var/log/modsec_audit.log")==$size_mod)
			{
				printf "%s", colored( "\nMod_security is not logging any stuffs\n", 'yellow');
			}
		else
			{
				printf "%s", colored( "\nApache No Log Patch is working fine !!\n", 'red');
				$patch_audit_log=`tail /var/log/modsec_audit.log`;
				$patch_error_log=`tail /apps/apache/current/logs/error_log`;
				$passed_testcase++;
				push(@passed,"Apache no log check");
			}

	}





#To determine the no.of test cases passed !!

sub Summary
{

	printf "%s", colored("\nTotal no.of test cases: $total_testcase\n", 'yellow');
	printf "%s", colored("Total no.of passed test cases: $passed_testcase\n", 'yellow');
	my $failed=$total_testcase - $passed_testcase;
	printf "%s", colored("Total no.of failed test cases: $failed\n", 'yellow');
	#print @passed;
	

	#To find the failed test case names
	my %test_case_names=map{$_ =>1} @test_case_names;
	my %passed=map{$_=>1} @passed;
	my @failed=grep(!defined $passed{$_}, @test_case_names);
	#print @failed;
	printf "Failed test cases:\t$_\n" foreach (@failed);


}

		
1; 
