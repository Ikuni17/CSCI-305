######################################### 	
#    CSCI 305 - Programming Lab #1		
#										
#  Bradley White			
#  white.brad17@gmail.com			
#										
#########################################

# I completed this lab individually
my $name = "Bradley White";
print "CSCI 305 Lab 1 submitted by $name.\n\n";

# Checks for the argument, fail if none given
if($#ARGV != 0) {
   print STDERR "You must specify the file name as the argument.\n";
   exit 4;
}

# Opens the file and assign it to handle INFILE
open(INFILE, $ARGV[0]) or die "Cannot open $ARGV[0]: $!.\n";

# Array to hold stop words, which is mapped to a hash for faster searching
@stopWords = ("a", "an", "and", "by", "for", "from", "in", "of", "on", "or", "out", "the", "to", "with");
%stopHash = map {$_ => 1} @stopWords;

# This loops through each line of the file and cleans up the line to place in the array
while($line = <INFILE>) {
    # Finds the right most <SEP>
    $i=rindex($line, "<SEP>");
    # Remove the string beginning with the rightmost <SEP>
    $title=substr($line,$i);
    # Remove the beginning <SEP> from the line
    $title=substr($title,5);
    # Remove the string after any brackets, symbols, and "feat." 
    $title =~ s/[([{\\\/_\-:`+=*""].*//;
    $title =~ s/"feat.".*//;
    # Remove punctuation from the string
    $title =~ s/[\?¿!¡\.;\&\$\@\%\|#]//g;
    # Make the string lower case
    $title = lc($title);
    # Push the string onto the array unless it contains non ASCII characters
    push(@titles, $title) unless $title =~ /[^[:ascii:]]/;     
}
# Close the file handle
close INFILE; 

# Splits each title into seperate words and pushes onto a new array
foreach $titles (@titles){
    push(@words, split(/\s+/, $titles));
}

# Create a new array of bigrams with each word and the following word, seperated by a space
for ($i = 0; $i < $#words; $i++){
    $bigrams[$i] = $words[$i] . " " . $words[$i + 1];
}

# Create a new array of bigrams with the stop words filtered out
for ($i = 0; $i < $#bigrams; $i++){
    @stopSplit = split(" ", $bigrams[$i]);
    # Make sure we have a bigram split correctly
    if($#stopSplit > 0){
        # Check if either word is a stop word, if not then push onto the new array
        if(!exists($stopHash{$stopSplit[0]}) && !exists($stopHash{$stopSplit[1]})){
            push(@cleanBigrams, $bigrams[$i]);
        }
    }
}

# Iterate through all the bigrams and put them into a hash table as the key and their frequency as the value
for ($i = 0; $i < $#cleanBigrams; $i++){
    # Check if the key already exists
    if(!exists($frequency_bigrams{$cleanBigrams[$i]})){
        $frequency_bigrams{$cleanBigrams[$i]} = 1;
    } else {
        $frequency_bigrams{$cleanBigrams[$i]}++;
    }
}
print "File parsed. Bigram model built.\n\n";

# Subroutine to search for bigrams that begin with a certain word and return the one with the highest frequency
sub mcw{
    # Store the input passed to the subroutine
    $item = "@_";
    # Store the highest frequency for checking
    $freq = 0;
    # Stores the most frrequent bigram
    $answer = "";
    # Search the hash table for keys beginning with the input
    for (grep /^\b$item\b/, keys %frequency_bigrams){
        # Check if the frequency is higher for bigrams with the same starting word, if so keep it
        if (($frequency_bigrams{$_}) > $freq){
            $freq = ($frequency_bigrams{$_});
            $answer = "$_";
        }
        # If two bigrams have the same frequency, use rand to break it and keep one
        elsif(($frequency_bigrams{$_}) == $freq){
            $check = int(rand(2));
            if($check == 1){
                $freq = ($frequency_bigrams{$_});
                $answer = "$_";
            }
        }        
    }
    # Return the matching bigram with the highest frequency
    return $answer;
}

# Create a song title based on a user defined word, uses sub mcw to find the most frequent word to follow
sub makeString{
    # Store the user input
    $query = "@_";
    # Keep track of the amount of words in the song title
    $count = 0;
    
    # Check that a bigram exists that starts with the input word, grep returns the amount of matches in this context
    $checkExists = grep {/^$query/} keys %frequency_bigrams;
    if ($checkExists != 0){
        # Call mcw to get the most frequent bigram for the input
        $bigram = &mcw($query);
        # Add the words to an output in seperate indices
        @output = split(" ", $bigram);
        $count = 2;
        # Seperate the words
        @splitBigram = split(" ", $bigram);
        $checkExists = grep {/^$splitBigram[1]/} keys %frequency_bigrams;
    }

    # Loop until the song title is 20 words or a word is not in the hash
    while(($count < 20) && ($checkExists != 0)){
        # Get the most frequent bigram using the second word from the previous bigram
        $bigram = &mcw($splitBigram[1]);
        # Split the new bigram and push the second word onto the output
        @splitBigram = split(" ", $bigram);
        # Check if we are looping bigrams, if so break the loop
        last if ($splitBigram[1] eq $output[($count - 2)]);
        push(@output, $splitBigram[1]);
        # Update the logic for the while loop
        $count++;
        $checkExists = grep {/^$splitBigram[1]/} keys %frequency_bigrams;
    }
    
    # Iterate through the output and print each word with a trailing space
    print "Probabilistic song title created:\n";
    for ($i = 0; $i <= $#output; $i++){
        print $output[$i], " ";
    }
    print "\n";
}

# User control loop
print "Enter a word [Enter 'q' to quit]: ";
$input = <STDIN>;
chomp($input);
print "\n";	
while ($input ne "q"){
    # Call subroutine passing the user input
    &makeString($input);
    print "\nEnter a word [Enter 'q' to quit]: ";
    $input = <STDIN>;
    chomp($input);
    print "\n";
}