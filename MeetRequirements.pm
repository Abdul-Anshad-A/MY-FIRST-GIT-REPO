package MeetRequirements;
use 5.010;
use Term::ANSIColor;
use LWP::Simple;

sub ModMain
        {
		$package=shift;
		$path=shift;
		$removeOld_installNew=shift;
		$version=shift;
		$platform=shift;
		$arch=shift;
		$tomcatPath=shift;

		
		#print " Just testing $package $path $removeOld_installNew $version $platform $arch $tomcatPath \n";
		#exit 1;
        }



1;
