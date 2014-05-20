#!/usr/bin/perl
package PrintMe;
use RTF::Writer;



sub ModMain
	{
		$package_install=shift;
		$tree1=shift;
		$tree=shift;
		$file_types=shift;
		$package_struct=shift;
		$package_size = shift;
		$list_directory = shift;
		$directory=shift;
		$link=shift;
		$modso=shift;
		$fileso=shift;
		$libpcrestat=shift;
		$ldd_modssl=shift;
		$ldd_mlogc=shift;
		$link1=shift;
		$link2=shift;
		$active_rules=shift;
		$httpd_stat=shift;
		$load_mod=shift;
		$error_log=shift;
		$htpd_stat2=shift;
		$patch_audit_log=shift;
		$patch_error_log=shift;
		$path=shift;
		$package=shift;
		$remove=shift;
		$version=shift;
		$platform=shift;
		$arch=shift;
		$tomcatPath=shift;
		@mlogc_ver=@_;
		Rtf();
	}



sub Rtf
	{
		

		########  Creating a new rtf file ##########

		my $rtf = RTF::Writer->new_to_file("$package-$version-$platform.rtf");
		$rtf->prolog( 'title' => "TEST DOCUMENT" );
		$rtf->number_pages;
		$rtf->paragraph(\'\cf1\qc\f0\fs40\b',"$package-$version-$platform");

		########### HEADERS ######################
		Headers();

		########## SUB FUNCTIONS ########

		###########  COMMON TEST CASES ##########

		CommonTestCase();

	
		sub CommonTestCase
			{
	
				Heading("Installation and Tree structure");
				Command("rpm -ivh $path");
				Content("$package_install");
		
				$directory=($package=~/Mod_Security/) ? "/apps/mod_security/current" : (($package_path[1]=~/Apache/) ? "/apps/apache/current" : "/apps/openssl/current");

				Command("tree -d $directory");
				Content("$tree1");

		
				############ Removal and tree structure #############

				Heading("Removal and Tree structure");

				if($package=~/Mod_Security/)
					{
						Command("rpm -e mod_security");
					}
				if($package=~/Apache/)
					{
						Command("rpm -e httpd httpd-devel httpd-tools httpd-debuginfo mod_ssl --nodeps");
					}
				if($package=~/OpenSSL/)
					{
						Command("rpm -e openssl openssl-devel openssl-static openssl-debuginfo openssl-perl --nodeps");
					}
		
				Command("tree -d $directory");
				Content("$tree");

		
				########### File Structure ##############
		
				Heading("File Structure");
				if($package_struct==1)
					{
						Command("ls -l $directory");
						Content("$link");
						if($package=~/Mod_Security/)
							{
								Command("file `rpm -ql mod_security`|grep -v ^/apps");
								Command("rpm -ql mod_security | xargs file | egrep 'ELF'");
								Content("$file_types");
							}
						if($package=~/Apache/)
							{
								Command("for i in httpd httpd-tools httpd-devel mod_ssl; do rpm -ql \$i|grep -v ^/apps; done");
								Command("rpm -ql httpd httpd-devel httpd-tools mod_ssl | xargs file | egrep 'ELF'");
								Content("$file_types");
							}
						if($package=~/OpenSSL/)
							{
								Command("rpm -ql openssl openssl-devel openssl-static openssl-perl | xargs file | egrep 'ELF'");
								Content("$file_types");
							}
					}
				


				############# PACKAGE SIZE ###################
		
				Heading("Package Size");
				Command("du -sch $path");
				Content("$package_size");
				Command("ls -l $path");
				Content("$list_directory");
		
	
				##########   PACKAGE SPECIFIC TEST CASES #######	
		
				if($package=~/Mod_Security/)
					{
						Mod_security();
					}
				if($package=~/Apache/)
					{
						Apache();
					}
				if($package=~/OpenSSL/)
					{
						Openssl();
					}
		
				}
	


			sub Headers
				{
			                $rtf->print(\'\fs24\b',"\nPLATFORM :", \'\b0'," $platform\n");
			                $rtf->print(\'\fs24\b',"\nSOFTWARE :", \'\b0'," $package $version\n");
        			        $rtf->print(\'\fs24\b',"\nARCH :", \'\b0'," $arch\n");
			                $rtf->print(\'\fs24\b',"\nPATH :", \'\b0'," $path\n");	
				}

			sub Heading
				{
					$rtf->paragraph(\'\cf2\fs32\b',"\n@_\n");
				}

			sub Command
				{
					$rtf->print(\'\fs24\b',"\n[root @ rhel6]# @_\n", \'\b0');
				}

			sub Content
				{
					$rtf->print("@_\n");
				}




			############ PACKAGE SPECIFIC FUNCTIONS ##########

			sub Mod_security
				{
					##### MODSSL TEST ####
					Heading("MOD_SSL TEST");
	                                Command("ls -l /apps/apache/current/modules/mod_security2.so");
        	                        Content("$modso");

					###### PCRE TEST ########
					Heading("PCRE TEST");
					Command("ldd /apps/apache/current/modules/mod_security2.so | grep -i pcre");
					Content("$libpcrestat");

					###### SHARED OBJECTS ######
					Heading("SHARED OBJECTS");
	                                Command("ls -l /apps/apache/current/modules/mod_security2.so");
        	                        Content("$modso");
                	                Command("file /apps/apache/current/modules/mod_security2.so");
                        	        Content("$fileso");

					####### DYNAMIC LIBRARIES ########
					Heading("DYNAMIC LIBRARIES");
	                                Command("ldd /apps/apache/current/modules/mod_security2.so");
					Content("$ldd_modssl");
					Command("ldd /apps/mod_security/current/bin/mlogc");
					Content("$ldd_mlogc");
					Command("ls -l /usr/lib64/libcrypto.so.10");
					Content("$link1");
					Command("ls -l /usr/lib64/libssl.so.10");
					Content("$link2");
					
					######### FUNCTIONAL TEST ##########
					Heading("FUNCTIONAL TESTING");
					Content("Add following entry in apache configuration file:
LoadModule security2_module modules/mod_security2.so

<IfModule security2_module>
            Include /apps/mod_security/current/conf/modsecurity_crs_10_config.conf
            Include /apps/mod_security/current/conf/rules/activated_rules/*.conf
</IfModule>");
					$rtf->print(\'\fs24\b',"\nCreate links for activated rules", \'\b0');
					Command("for f in `ls /apps/mod_security/current/conf/rules/base_rules/` ; do ln -s /apps/mod_security/current/conf/rules/base_rules/$f /apps/mod_security/current/conf/rules/activated_rules/$f ; done");
					Command("ls -l /apps/mod_security/current/conf/rules/activated_rules/");
					@array=split(/\n/,$active_rules);
					@slice1=@array[1..5];
					@slice2=@array[18..23];
					$temp1=join("\n",@slice1);
					$temp2=join("\n",@slice2);
					Content("$temp1");
					Content(".\n.\n.\n.");
					Content("$temp2");
					
					if($httpd_stat==1)
						{
							Command("/apps/apache/current/bin/httpd.init restart");
							Content("Stopping httpd:                                            [  OK  ]
Starting httpd:                                            [  OK  ]
");						}
					Command("/apps/apache/current/bin/httpd -M | grep sec");
					Content("$load_mod");
					
					Heading("APACHE LOG CHECK");
					Command("tail /apps/apache/current/logs/error_log");
					Content("$error_log");
				
					Command("/apps/mod_security/current/bin/mlogc -v");
					Content("@mlogc_ver");
					#print "Im here @mlogc_ver";

					### Apache no logs check ##
					Heading("APACHE NO LOGS CHECK");
					Command("cp /root/raj/mod_security/modsecurity_crs_10_config.conf /apps/mod_security/current/conf/");
					if($htpd_stat2==1)
						{
							Command("/apps/apache/current/bin/httpd.init restart");
                                                        Content("Stopping httpd:                                            [  OK  ]
Starting httpd:                                            [  OK  ]
");                                             }
						

					Content("Access the below url to check if details are NOT logged in apache error_log and logged in ONLY audit log");
					Content("\n\nhttp://localhost/?abc=../../\n");
					Command("tail -f /var/log/modsec_audit.log");
					Content("$patch_audit_log");
					Command("tail -f /apps/apache/current/logs/error_log");
					Content("$patch_error_log");
					

						
					
				}

			sub Apache
				{

				}

			sub Openssl
				{

				}

	##### Close RTF object
	$rtf->close;
}

1;
