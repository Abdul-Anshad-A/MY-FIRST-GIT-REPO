#!/usr/bin/perl
require Modsecurity;
require CommonTestCase;
require Apache;
require Openssl;
require MeetRequirements;
require LogMe;
use Switch;
use Term::ANSIColor;
use JSON;

*log = LogMe::logger;


{
local $/;
open my $fh, "<", "input.json";
$json = <$fh>;
close $fh;
}




my $data = decode_json($json);
my $package=$data->{'package'};
my $path=$data->{'path'};
my $removeOld_installNew=$data->{'removeOld_installNew'};
my $version=$data->{'version'};
my $platform=$data->{'platform'};
my $arch=$data->{'arch'};
my $tomcatPath=$data->{'tomcatPath'};


#MeetRequirements::ModMain($package, $path, $removeOld_installNew, $version, $platform, $arch, $tomcatPath);


### LOGGING ###
#

printf "%s\n", colored( "\n\n############### PACKAGE DETAILS ###############\n\n", 'green' );

$log->info("\n\n\n");
$log->info("Details of the package that I'm going to test ...");
$log->info("Package is : $package");
$log->info("Version is : $version");
$log->info("Platform is : $platform");
$log->info("Architecture is : $arch");



switch ($package)
	{
		case "Mod_Security"
			{
				
				Modsecurity::ModMain($path, $package, $removeOld_installNew, $version, $platform, $arch, $tomcatPath);
			}

		case "Apache"
			{
				Apache::ModMain($path, $package, $removeOld_installNew, $version, $platform, $arch, $tomcatPath);
			}
		case "OpenSSL"
			{
				Openssl::ModMain($path, $package, $removeOld_installNew, $version, $platform, $arch, $tomcatPath);
			}
		else
			{
				print "Please check your JSON file inputs\n";
			}

	}
