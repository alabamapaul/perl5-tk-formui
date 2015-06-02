#!/usr/bin/perl -w
##----------------------------------------------------------------------------
## :mode=perl:indentSize=2:tabSize=2:noTabs=true:
##----------------------------------------------------------------------------
##        File: 
## Description: 
##----------------------------------------------------------------------------
use strict;
use warnings;
## Cannot use Find::Bin because script may be invoked as an
## argument to another script, so instead we use __FILE__
use File::Basename qw(dirname fileparse basename);
use File::Spec;
## Add script directory
use lib join '/', File::Spec->splitdir(dirname(__FILE__));
## Add script directory/lib
use lib join '/', File::Spec->splitdir(dirname(__FILE__)), 'lib';
## Add script directory/../lib
use lib join '/', File::Spec->splitdir(dirname(__FILE__)), '..', 'lib';
use Readonly;
use Tk::FormUI;
use Data::Dumper;

## List reference for choices
Readonly::Scalar my $CONTINENT_CHOICES => [
  { label => qq{Asia},            value => 0x01,  },
  { label => qq{Africa},          value => 0x02,  },
  { label => qq{North America},   value => 0x04,  },
  { label => qq{South America},   value => 0x08,  },
  { label => qq{Antarctica},      value => 0x10,  },
  { label => qq{Australia},       value => 0x20,  },
  { label => qq{Europe},          value => 0x40,  },
];

##---------------------------------------
## Hash used to initialize the form
##---------------------------------------
Readonly::Scalar my $SURVEY_FORM => {
  title  => qq{Tk::FormUI Demo},
  message => qq{\nPlease complete this form and click the Submit button\n},
  button_label => qq{&Submit},
  fields => [
    {
      type  => $Tk::FormUI::ENTRY,
      width => 40,
      label => qq{Name},
      key   => qq{name},
    },
    {
      type  => $Tk::FormUI::RADIOBUTTON,
      label => qq{Title},
      key   => qq{title},
      max_per_line => 2,    ## At most, 2 choices per line
      choices => [
        { label => qq{Dr.},   value => qq{Dr.},   },
        { label => qq{Mrs.},  value => qq{Mrs.},  },
        { label => qq{Ms.},   value => qq{Ms.},   },
        { label => qq{Mr.},   value => qq{Mr.},   },
      ],
    },
    {
      type  => $Tk::FormUI::COMBOBOX,
      label => qq{Current Continent},
      key   => qq{continent_residence},
      choices => $CONTINENT_CHOICES,
    },
    {
      type  => $Tk::FormUI::CHECKBOX,
      label => qq{Continents Visited},
      key   => qq{continent_visited},
      max_per_line => 2,    ## At most, 2 choices per line
      choices => $CONTINENT_CHOICES,
    },
  ],
};

##----------------------------------------------------------------------------
##     @fn get_valid_form($template)
##  @brief Display the given form template and repeat until valid data is
##         gathered or the operator aborts
##  @param $template - Used to initialize the form
## @return UNDEF if operator cancels, or HASH reference containing the
##         gathered data
##   @note 
##----------------------------------------------------------------------------
sub get_valid_form
{
  my $template = shift;
  
  ## Main window for possible MessageBox calls
  my $mw = MainWindow->new;
  $mw->withdraw();
  
  ## Create a new form object
  my $form = Tk::FormUI->new;
  
  ## Initialize the form using the given template
  $form->initialize($template);
  
  ## Now gather data from the user using the form
  my $data;
  while (1)
  {
    ## Display the form
    $data = $form->show;
    
    ## For demo purposes, print out the data receied
    print(
      qq{The form returned the following:\n},
      Data::Dumper->Dump([$data,], [qw( data)]),
      qq{\n},
    );
    
    ## See if we received data
    if ($data)
    {
      ##---------------------------------
      ## Validate the name field
      ##---------------------------------
      $data->{name} =~ s/^\s+//g;  ## Remove leading spaces
      $data->{name} =~ s/\s+$//g;  ## Remove trailing spaces
      ## Validate the name field
      unless ($data->{name})
      {
        $form->error_by_key(qq{name}, qq{The name field cannot be empty!});
      }
      
      ##---------------------------------
      ## Validate the title field
      ##---------------------------------
      unless (defined($data->{title}))
      {
        $form->error_by_key(qq{title}, qq{You must select a Title!});
      }
      
      ##---------------------------------
      ## Validate the continent_residence field
      ##---------------------------------
      unless (defined($data->{continent_residence}))
      {
        $data->{continent_residence} = qq{};
        $form->error_by_key(
          qq{continent_residence},
          qq{You must select your current continent of residence!},
        );
      }
      
      ## Return the data if there are no errors
      return($data) if (!$form->has_errors);

      ## If we get here then there was at least one error
      
      ## Set the form's field data
      $form->set_field_data($data);
      
      ## Display a popup
      $mw->messageBox(
        -title    => qq{ERROR},
        -message  => qq{There were errors in the provided data!},
        -type     => qq{Ok},
      );
    }
    else
    {
      ## Operator canceled the form, see if they want to abort
      my $answer = $mw->messageBox(
        -title    => qq{Tk::FormUI Demo},
        -message  => qq{\nDo you want to abort the test?\n},
        -type     => qq{YesNo},
      );
      
      ## Return undef if operator wants to cancel the form
      return if (uc($answer) eq qq{YES});
    }
    
  }
  return;
}

##----------------------------------------------------------------------------

my $data = get_valid_form($SURVEY_FORM);

print(
  qq{The following data was returned:\n},
  Data::Dumper->Dump([$data,], [qw( data)]),
  qq{\n},
  );

__END__