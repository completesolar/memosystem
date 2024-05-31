#!/usr/bin/perl
use strict;
use warnings;
# Debug
#use Data::Dump qw(dump);

# 0 Set ENV + check if the action can be done.
$ENV{actionWorkspacePath} = '/app/memos';
#$ENV{actionWorkspacePath} = '/Users/local/Solar/memosystem/memos' || '/app';

my $workingPath = '/app'; #$ENV{APP} || $ENV{actionWorkspacePath};


#print STDOUT $workingPath;

#die;
#print($workingPath);
# Uncomment to add validation for missing dir of current name
die "Error: Directory missing." if ( !-d "$workingPath/memos/static/memos/" . $ARGV[0]);
#die();
# Step 1: Create the string based on variables for the sql
my $current_username = $ARGV[0];
my $new_username     = $ARGV[1];

if (not defined $current_username or not defined $new_username) {
    die "Usage: $0 <current_username> <new_username>\n";
}
# String...
my $sql_string = <<END;
-- Declare variables
SET \@old_username = '$current_username';
SET \@new_username = '$new_username';
END

# Step 2: Read the SQL template and replace the placeholder
my $template_filename = "$workingPath/actions/script.sql";

open my $fh, '<', $template_filename or die "Could not open file '$template_filename': $!";
my $content = do { local $/; <$fh> };
close $fh;

$content =~ s/\[users\]/$sql_string/g;

# Step 3: Run the SQL using CLI
my $cmd    = "echo \"$content\" | mysql --defaults-extra-file='$workingPath/actions/config.cnf' memos";
my $sqlRun = `$cmd`;

# Validate cli message
die "Failed to run SQL command: $!" if ($? != 0);

# Step 4: Run the Shell using CLI
my $shRun = `sh $workingPath/actions/script.sh $current_username $new_username`;

# Validate cli message
die "Failed to run shell script: $!" if ($? != 0);

# Wrap results text
my $sqlResult = !$sqlRun ? "Complete." : "Failed !";
my $shResult  = !$shRun  ? "Complete." : "Failed !";

# Print / return
print("SQL Update: $sqlResult | Workspace Update: $shResult");