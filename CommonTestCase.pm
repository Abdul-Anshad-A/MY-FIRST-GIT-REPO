#!/usr/bin/perl
package CommonTestCase;
#use strict;
#use warnings;
require MeetRequirements;
require LogMe;
use 5.010;
use Term::ANSIColor;
use LWP::Simple;
state $passed_testcase=0;

###### LOgging ######

*log = LogMe::logger;


@openssl_orig_dir=("/apps/openssl/current","/apps/openssl/current/lib64","/apps/openssl/current/lib64/pkgconfig","/apps/openssl/current/lib64/openssl","/apps/openssl/current/lib64/openssl/engines","/apps/openssl/current/etc","/apps/openssl/current/etc/pki","/apps/openssl/current/etc/pki/CA","/apps/openssl/current/etc/pki/CA/private","/apps/openssl/current/etc/pki/tls","/apps/openssl/current/etc/pki/tls/misc","/apps/openssl/current/etc/pki/tls/private","/apps/openssl/current/etc/pki/tls/certs","/apps/openssl/current/bin","/apps/openssl/current/include","/apps/openssl/current/include/openssl","/apps/openssl/current/usr","/apps/openssl/current/usr/share","/apps/openssl/current/usr/share/doc","/apps/openssl/current/usr/share/doc/openssl-1.0.1e","/apps/openssl/current/usr/share/man","/apps/openssl/current/usr/share/man/man1","/apps/openssl/current/usr/share/man/man3","/apps/openssl/current/usr/share/man/man7","/apps/openssl/current/usr/share/man/man5");


@httpd_orig_dir=("/apps/apache/current","/apps/apache/current/lib64","/apps/apache/current/lib64/build","/apps/apache/current/lib64/dav","/apps/apache/current/modules","/apps/apache/current/error","/apps/apache/current/error/include","/apps/apache/current/conf","/apps/apache/current/bin","/apps/apache/current/icons","/apps/apache/current/icons/small","/apps/apache/current/include","/apps/apache/current/cache","/apps/apache/current/cache/mod_ssl","/apps/apache/current/cache/mod_proxy","/apps/apache/current/www","/apps/apache/current/run","/apps/apache/current/logs");


@mod_sec_orig_dir=("/apps/mod_security/current","/apps/mod_security/current/modules","/apps/mod_security/current/conf","/apps/mod_security/current/conf/rules","/apps/mod_security/current/conf/rules/slr_rules","/apps/mod_security/current/conf/rules/optional_rules","/apps/mod_security/current/conf/rules/activated_rules","/apps/mod_security/current/conf/rules/experimental_rules","/apps/mod_security/current/conf/rules/base_rules","/apps/mod_security/current/bin");



sub ModMain
	{
		@package_path=@_;
		#to remove the newline after the package path
		chomp($package_path[0]);
                $install = $package_path[0]."\/\*";
                chomp($install);
		$remove=$package_path[2];
		#print $package_path[1];
		#print @package_path;
		#print $package_path[0];
		#print "Inside mod security module";
		#print $passed_testcase;
		
		$path=$package_path[0];
		$package=$package_path[1];
		$version=$package_path[3];
		$platform=$package_path[4];
		$arch=$package_path[5];
		$tomcatPath=$package_path[6];


		PackageSize();
		InstallTree();
		#LinkTest();
		#RemoveTree();
		FileStructType();
		#DynamicLib();
		#Common test case for OpenSSl and Apache

		if($package_path[1]=~ /^(Apache|OpenSSL)$/)
			{

				FipsTest();
				TlsTest();
			}

		#print "\n\n\nIm here $package_size $list_directory\n\n\n";
		return ($passed_testcase, $package_install, $tree1, $tree, $file_types, $package_struct, $package_size, $list_directory, $directory, $link, @passed);
	}

=pod
To test the installation and
tree structure
=cut

sub InstallTree
	{

		state $flag=0;
		$installed=1;

		
		#print "package path inside function InstallTree $package_path[0]";
		#$log->info("Just checking the log4perl module !! , It works ");
		printf "%s\n", colored( "\n\nTEST CASE: Installation and Tree structure\n\n", 'green' );
		
		$log->info("Searching for pre-installed packages ...");

		if($package_path[1]=~/Mod_Security/)
			{
				$returncode=system("rpm -q mod_security >/dev/null");
				#print "querying for mod_security installation\n";
				#print $returncode."\n";
			}
		if($package_path[1]=~/Apache/)
			{
				$returncode=system("rpm -q httpd httpd-devel httpd-tools httpd-debuginfo mod_ssl >/dev/null");
				#print "Apache\n";
			}
		if($package_path[1]=~/OpenSSL/)
			{
				$returncode=system("rpm -q openssl openssl-devel openssl-static openssl-debuginfo openssl-perl >/dev/null");
				#print "openssl\n";
			}

		#print $returncode."\n";


		if($returncode!=0)
			{
				print "\n";
				#print "Insalling Mod_security . . . . \n";
				#printf "%s\n", colored( "Installing $package_path[1] . . . \n", 'red' );
				$log->info("No pre-installed packages found.");
				$log->info("Installing $package_path[1] ...");
				$package_install=`rpm -ivh $install`;
				#print "$package, $path, $remove, $version, $platform, $arch, $tomcatPath\n";
				MeetRequirements::ModMain($package, $path, $remove, $version, $platform, $arch, $tomcatPath);
				
			}


		elsif($returncode==0)
			{
				$log->info("Package is already installed.");
				#printf "%s", colored("Package is already installed !!\n\n", 'red');
				#printf "%s", colored("Do you want to remove the existing package and install the new one?\n1. YES\n2. NO\n\n", 'magenta');
				my $yesno=$remove;
				if($yesno==1)
					{

						

						#To set a label for removal_install tree test case
						Removal:

						#printf "%s", colored( "\nRemoving the package $package_path[1] . . .\n", 'red');
						$log->info("Removing package $package_path[1] ...");
						if($package_path[1]=~/Mod_Security/)
							{
                                				system("rpm -e mod_security --nodeps >/dev/null");
							}
						if($package_path[1]=~/Apache/)
							{
								system("rpm -e httpd httpd-devel httpd-tools httpd-debuginfo mod_ssl --nodeps >/dev/null");
                                
							}
						if($package_path[1]=~/OpenSSL/)
							{
								system("rpm -e openssl openssl-devel openssl-static openssl-debuginfo openssl-perl --nodeps >/dev/null");
                                
							}	


						if($flag==1) {

								goto RemoveTree;
							}

						#printf "%s\n", colored( "\nInstalling $package_path[1] . . . \n", 'red' );
						$log->info("Installing $package_path[1] ...");
						$package_install=`rpm -ivh $install`;
						MeetRequirements::ModMain($package, $path, $remove, $version, $platform, $arch, $tomcatPath);
						
					}
				else
					{
						exit 1;
					}
			}


		

		RemoveTree:
		#printf "%s\n", colored( "Directory structure\n", 'red' );
		#$log->info("Checking the directory structure ...");


		$directory=($package_path[1]=~/Mod_Security/) ? "/apps/mod_security/current" : (($package_path[1]=~/Apache/) ? "/apps/apache/current" : "/apps/openssl/current");
		$tree=`tree -d $directory`;

		##### To get the install tree in print me ############
		state $tmp=0;
		if($tmp==0)
			{

				$tree1=$tree;
				$tmp++;
			}
		

		#To verify the test case
		#printf "%s\n", colored( "\nIs the directory structure appropriate ?\n1. YES\n2. NO\n", 'magenta' );
		#$checkchoice=<STDIN>;




		#To automate directory structure testing


						if($package_path[1]=~/Mod_Security/)
                                                        {
								if($installed==1)
                                                                         {
										$log->info("Checking the directory structure in /apps/mod_security/current");
                                                                                @mod_sec_dir=`perl Directory.pl /apps/mod_security/current`;
                                                                                chomp(@mod_sec_dir);
                                                                                my %mod_sec_orig_dir=map{$_ =>1} @mod_sec_orig_dir;
                                                                                my %mod_sec_dir=map{$_=>1} @mod_sec_dir;
                                                                                my @failed=grep(!defined $mod_sec_dir{$_}, @mod_sec_orig_dir);
                                                                                if(@failed)
                                                                                        {
												$log->error("Directory strucutre does not match the predefined one !!");
												printf "\nFailed directory structures are :\t$_\n" foreach (@failed);
                                                                                        }
                                                                                else
                                                                                        {
                                                                                                $checkchoice=1;
                                                                                                #printf "%s", colored("\nDirectory structure matches :)\n", 'red');
												$log->info("Directory structure matches.");
                                                                                        }
                                                                        }
                                                                elsif($install==0)
                                                                        {
                                                                                if( -f "/apps/mod_security/current")
                                                                                        {
                                                                                                #printf "%s", colored("Link is not removed\n", 'yellow');
												$log->error("/apps/mod_security/current Link is not removed.");
                                                                                        }
                                                                                else
                                                                                        {
                                                                                                #printf "%s", colored("\nLink is removed\n", 'red');
												$log->info("/apps/mod_security/current Link is removed.");
                                                                                        }
                                                                        }

                                                        }
                                                if($package_path[1]=~/Apache/)
                                                        {
								if($installed==1)
                                                                         {
										$log->info("Checking the directory structure in /apps/apache/current");
                                                                                @httpd_dir=`perl Directory.pl /apps/apache/current`;
                                                                                chomp(@httpd_dir);
                                                                                my %httpd_orig_dir=map{$_ =>1} @httpd_orig_dir;
                                                                                my %httpd_dir=map{$_=>1} @httpd_dir;
                                                                                my @failed=grep(!defined $httpd_dir{$_}, @httpd_orig_dir);
                                                                                if(@failed)
                                                                                        {
												$log->error("Directory strucutre does not match the predefined one !!");
                                                                                                printf "\nFailed directory structures are :\t$_\n" foreach (@failed);
                                                                                        }
                                                                                else
                                                                                        {
                                                                                                $checkchoice=1;
                                                                                                #printf "%s", colored("\nDirectory structure matches :)\n", 'red');
                                                                                                $log->info("Directory structure matches.");
                                                                                        }
                                                                        }
                                                                elsif($install==0)
                                                                        {
                                                                                if( -f "/apps/apache/current")
                                                                                        {
                                                                                                #printf "%s", colored("Link is not removed\n", 'yellow');
                                                                                                $log->error("/apps/apache/current Link is not removed.");
                                                                                        }
                                                                                else
                                                                                        {
                                                                                                #printf "%s", colored("\nLink is removed\n", 'red');
                                                                                                $log->info("/apps/apache/current Link is removed.");
                                                                                        }
                                                                        }


                                                        }
                                                if($package_path[1]=~/OpenSSL/)
                                                        {
								if($installed==1)
									 {
										$log->info("Checking the directory structure in /apps/openssl/current");
										@openssl_dir=`perl Directory.pl /apps/openssl/current`;
										chomp(@openssl_dir);
									        my %openssl_orig_dir=map{$_ =>1} @openssl_orig_dir;
									        my %openssl_dir=map{$_=>1} @openssl_dir;
									        my @failed=grep(!defined $openssl_dir{$_}, @openssl_orig_dir);
										if(@failed)
											{
												$log->error("Directory strucutre does not match the predefined one !!");
								        			printf "\nFailed directory structures are :\t$_\n" foreach (@failed);	
											}
										else
											{
												$checkchoice=1;
												#printf "%s", colored("\nDirectory structure matches :)\n", 'red');
												$log->info("Directory structure matches.");
											}
									}
								elsif($install==0)
									{
										if( -f "/apps/openssl/current")
											{
												#printf "%s", colored("Link is not removed\n", 'yellow');
												$log->error("/apps/openssl/current Link is not removed.");
											}
										else
											{
												#printf "%s", colored("\nLink is removed\n", 'red');
												$log->info("/apps/openssl/current Link is removed.");
											}
									}
							}	









		if($checkchoice==1)
			{
				$passed_testcase++;
				#print $passed_testcase;
				state $temp123=0;
				if($temp123==0)
					{
						$log->info("TEST CASE PASSED : Installation and tree structure");
						$temp123++;
					}
				push(@passed,"Installation and tree structure");
				if($flag==1)
					{
						$log->info("TEST CASE PASSED : Package removal and tree structure");
						push(@passed,"Package removal and tree structure");
					}

			}


	$flag++;
	if($flag==1)
		{

			printf "%s\n", colored( "\n\nTEST CASE: Package Removal  and Tree structure\n\n", 'green' );
			$installed=0;
			goto Removal;

			
		}
		
	



	}




#To test the file types of the installed package

sub FileStructType
	{	

		printf "%s\n", colored( "\n\nTEST CASE: Package directory structure and File types\n\n", 'green' );	
		#to install the package again
		#printf "%s\n", colored( "\nInstalling $package_path[1] . . . \n", 'red' );
		$log->info("Installing the package $package_path[1] ...");
               	my $temp23=`rpm -ivh $install`;
		LinkTest();

			

		
						$errordir=1;
						$log->info("Searching for files which are not under directory /apps ...");
						$log->info("Searching for ELF files ...");
						if($package_path[1]=~/Mod_Security/)
                                                      	{
								$errordir=system("rpm -ql mod_security | grep -v ^/app >/dev/null");
								#printf "%s", colored("File Types . . . \n\n", 'red');
								$file_types=`rpm -ql mod_security | xargs file | egrep 'ELF'`;
                                                        }
                                                if($package_path[1]=~/Apache/)
                                                        {
                                                                $errordir=system("rpm -ql httpd httpd-devel httpd-tools mod_ssl | grep -v ^/app >/dev/null");
								#printf "%s", colored("File Types . . . \n\n", 'red');
								$file_types=`rpm -ql httpd httpd-devel httpd-tools mod_ssl | xargs file | egrep 'ELF'`;

                                                        }
                                                if($package_path[1]=~/OpenSSL/)
                                                        {
                                                                @files=`rpm -ql openssl openssl-devel openssl-static openssl-perl | grep -v ^/app`;
								#push(@files,"/apps/openssl/current/bin/openssl");
								#print "Im here; openssl path pusshed to the array\n";
								#
								#To detect files outised /apps directory which are not symlinks
								
								foreach $list (@files)
									{
										if(-f $list)
											{		
												$log->error("Some files are not withing /apps directory");
												printf "%s", colored("$list\n\n", 'yellow');
												$errordir=0;
											}
									}


								#printf "%s", colored("File Types . . . \n\n", 'red');
								$file_types=`rpm -ql openssl openssl-devel openssl-static openssl-perl | xargs file | egrep 'ELF'`;

                                                        }


		


		#$errordir=system("rpm -ql mod_security | grep -v ^/app >/dev/null");
		#print $errordir;
		if($errordir==0)
			{
				#printf "%s", colored("\n\nPackage directory structure is not valid !!\n", 'yellow');
				$log->error("Package directory structure is not valid.");
				$package_struct=0;
				#my $errordir=system("rpm -ql mod_security | grep -v ^/app");
			}
		else
			{
				#printf "%s", colored("\n\nPackage directory structure is valid : All files are within /apps directory.\n", 'red');
				$log->info("Package directory structure is valid : All files are within /apps directory.");
				$package_struct=1;
			}
		#printf "%s", colored( "Package File Types\n\n", 'red');
		#system("rpm -ql mod_security | xargs file | egrep 'bit|link'");
		


		#printf "%s\n", colored( "\nAre the File Types correct?\n1. YES\n2. NO\n", 'magenta' );
                my $checkchoice=1;
                if($checkchoice==1)
                        {
                                $passed_testcase++;
				$log->info("PASSED TEST CASE : Package directory structure and file types");
				push(@passed,"Package directory structure and file types");
                        }


	}


#To determine the size of the package		 
sub PackageSize
	{
		#$log->info("Checking package size ...");
		#printf "%s\n", colored( "\nSize of the package is :\n", 'red');
		$package_size=`du -sch $install`;
		$list_directory=`ls -l $package_path[0]`;
		
	}






#FIPS test for Apache and Openssl not for Mod_security




sub FipsTest
	{
		printf "%s", colored( "\n\nTEST CASE: FIPS mode test for Apache and OpenSSL\n\n", 'green' );

		$fipsstatus=system("grep 'SSLFIPS ON' /apps/apache/current/conf/ssl.conf >/dev/null");
                if($fipsstatus!=0)
                        {
				#printf "%s", colored("Editing ssl.conf for FIPS mode . . .\n", 'red');
				$log->info("Editing ssl.conf to operate in FIPS mode ...");
				system("sed -i '/Listen/a SSLFIPS ON' /apps/apache/current/conf/ssl.conf");
                        }
		#printf "%s", colored("Creating Certificates and Keys to operate in FIPS mode. . .\n\n", 'red');
		#system("openssl genrsa -out my_key.key 2048");
		#system("openssl pkcs8 -v1 PBE-SHA1-3DES -topk8 -in my_key.key -out localhost.key");
		#system("openssl req -new -key localhost.key -out localhost.csr");
		#system("openssl x509 -req -days 3650 -in localhost.csr -signkey localhost.key -out localhost.crt");
		#printf "%s", colored("Copying Certificates and Keys to operate in FIPS mode . . .\n\n", 'red');
		$log->info("Copying Certificates and Keys ...");
		system("cp -f localhost.crt /etc/pki/tls/certs/localhost.crt");
		system("cp -f localhost.key /etc/pki/tls/private/localhost.key");

		#to include ssl.conf in httpd.conf file
		$status12=system("grep /apps/apache/current/conf/ssl.conf /apps/apache/current/conf/httpd.conf >/dev/null");
                if($status12!=0)
                        {
                                my $filename = '/apps/apache/current/conf/httpd.conf';
                                open(my $fh, '>>', $filename) or die "Could not open file '$filename' $!";
                                say $fh "Include /apps/apache/current/conf/ssl.conf";
                                #printf "%s", colored("Editing httpd.conf to include ssl.conf . . \n", 'red');
				$log->info("Editing httpd.conf to include ssl.conf ...");
                                close $fh;
                        }

		
		#To restart httpd server
		#printf "%s", colored("\nRestarting httpd server\n", 'red');
		$log->info("Restarting httpd server");
                #system("/apps/apache/current/bin/httpd.init restart");
                
		#experimenting with the expect script for pass phrase
		#
		$log->info("Using expect scripts for PASSPHRASE");
		system("./httpd_expect restart 91vis91");

                sleep(4);
                my $temp=`/apps/apache/current/bin/httpd.init status`;
                print "\n\n$temp\n\n";
                if($temp=~ /running/)
                        {


                        }
                else
                        {
                                #printf "%s", colored("Httpd server is not started, please check it\n", 'yellow');
				$log->error("Httpd server is not started, please check it");
                                exit 1;
                        }
		
		sleep(4);
		$stat=system("tail -2 /apps/apache/current/logs/error_log | grep 'Operating in SSL FIPS mode' >/dev/null");
		if($stat!=0)
			{
				#printf "%s", colored("\nHttpd is not operating in FIPS mode\n", 'yellow');
				$log->error("Httpd is not operating in FIPS mode");
			}
		elsif($stat==0)
			{
				#printf "%s", colored("\nHttpd is operating in FIPS mode\n", 'red');
				$log->info("Httpd is operating in FIPS mode");
				$passed_testcase++;
				$log->info("PASSED TEST CASE : Fips mode test");
				push(@passed,"FIPS mode test");
			}
			

		
	}


sub TlsTest
	{
		printf "%s", colored( "\n\nTEST CASE: TLSv1.1 and TLSv1.2 test for Apache and OpenSSL\n\n", 'green' );
		system("touch temp");
		$log->info("Establishing connection with localhost to check TLSV1.1");
		system("nohup openssl s_client -connect localhost:443 -tls1_1 &>temp");
		$tls1=system("grep TLSv1.1 temp >/dev/null");
		if($tls1==0)
			{
				#printf "%s", colored("TLSv1.1 is working\n", 'red');
				$log->info("TLSv1.1 is working");
				system("echo '' > temp");
			}
		else
			{
				#printf "%s", colored("TLSv1.1 is not working\n", 'red');
				$log->error("TLSv1.1 is not working");
			}
		$log->info("Establishing connection with localhost to check TLSV1.2");
		system("nohup openssl s_client -connect localhost:443 -tls1_2 &>temp");
		$tls1=system("grep TLSv1.2 temp >/dev/null");
                if($tls1==0)
                        {
                                #printf "%s", colored("TLSv1.2 is working\n", 'red');
                                $log->info("TLSv1.2 is working");
                                system("echo '' > temp");
                        }
                else
                        {
                                #printf "%s", colored("TLSv1.2 is not working\n", 'red');
				$log->error("TLSv1.2 is not working");
                        }
		system("rm -f temp");
	}
		 


sub LinkTest
	{
		$log->info("Testing whether the current link is pointing to packge version");	
		if( -l $directory)
			{
				$rel=readlink($directory);
				if(uc($rel)==uc("/apps/$package/$version"))
					{
						#print "Current link is point to $rel\n";
						$log->info("Current link is point to $rel");
						$link=`ls -l $directory`;
					}
				else
					{
						#print "\nCurrent link does not matches the version of Package\n";
						$log->error("Current link does not matches the version of Package");
						exit 1;
					}
			}
						
	
	}		
		
1; 
