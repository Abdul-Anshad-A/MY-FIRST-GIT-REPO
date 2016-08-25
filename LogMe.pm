#!/usr/bin/perl
package LogMe;
use Log::Log4perl qw(get_logger);

#### Log4perl conf variable ####
my $conf = q(
                    log4perl.logger                    = DEBUG, FileApp, ScreenApp

    log4perl.appender.FileApp          = Log::Log4perl::Appender::File
    log4perl.appender.FileApp.filename = TEST_CASE.log
    log4perl.appender.FileApp.layout   = PatternLayout
    log4perl.appender.FileApp.layout.ConversionPattern = [ %d ] [ %F{1}:%L - %M ] [ %p ] %m%n

    log4perl.appender.ScreenApp          = Log::Log4perl::Appender::Screen
    log4perl.appender.ScreenApp.stderr   = 0
    log4perl.appender.ScreenApp.layout   = PatternLayout
    log4perl.appender.ScreenApp.layout.ConversionPattern = [ %d ] [ %F{1}:%L - %M ] [ %p ] %m%n
    );

Log::Log4perl->init( \$conf );

## Declared logger as globlal to use it in other modules ###

our $logger = get_logger("Bar::Twix");

#### Basic Usages #####
   # $logger->error("Oh my, a dreadful error!");
   # $logger->warn("Oh my, a dreadful warning!");
   # $logger->info("Just some info!");


1;
