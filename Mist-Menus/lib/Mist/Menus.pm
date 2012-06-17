package Mist::Menus;

use strict;
use diagnostics;					# for debugging
use warnings FATAL => qw(numeric uninitialized);	# dies if these occure

BEGIN {
  use Exporter;
  our($VERSION, @ISA, @EXPORT, @EXPORT_OK, %EXPORT_TAGS);
  $VERSION     = 1.00;
  @ISA         = qw(Exporter);
  @EXPORT      = qw(

	      SDL_MENUS_LOCKED_ALIGN_LEFT
	      SDL_MENUS_LOCKED_ALIGN_CENTER
	      SDL_MENUS_LOCKED_ALIGN_RIGHT
	      SDL_MENUS_ALIGN_LEFT
	      SDL_MENUS_ALIGN_CENTER
	      SDL_MENUS_ALIGN_RIGHT
	      SDL_MENUS_ALIGN_TOP
	      SDL_MENUS_ALIGN_MIDDLE
	      SDL_MENUS_ALIGN_BOTTOM
	      SDL_MENUS_LOCKED_ALIGN
	      SDL_MENUS_ALIGN_NONE
	      SDL_MENUS_SELECTOR_BAR_NONE
	      SDL_MENUS_SELECTOR_BAR_FULL
	      SDL_MENUS_SELECTOR_BAR_PARTIAL
	      SDL_MENUS_DO_TOGGLE
	      SDL_MENUS_DO_ENTER
	      SDL_MENUS_DO_CONFIG
	      SDL_MENUS_GET_TEXT
	      SDL_MENUS_CS2_SET1
	      SDL_MENUS_CS2_SET2
	      SDL_MENUS_CS2_SET3
	      SDL_MENUS_CS2_SET4
	      SDL_MENUS_CS2_SAT
	      SDL_MENUS_CS2_DARK
	      SDL_MENUS_CS2_PALE
	      SDL_MENUS_CS2_LIGHT
	      SDL_MENUS_ITEMS

	      SDL_MENUS_TTF_STYLE_NORMAL
	      SDL_MENUS_TTF_STYLE_BOLD
	      SDL_MENUS_TTF_STYLE_ITALIC
	      SDL_MENUS_TTF_STYLE_UNDERLINE
	      SDL_MENUS_TTF_STYLE_STRIKETHROUGH

	      SDL_MENUS_TTF_HINTING_NORMAL
	      SDL_MENUS_TTF_HINTING_LIGHT
	      SDL_MENUS_TTF_HINTING_MONO
	      SDL_MENUS_TTF_HINTING_NONE
  );
  @EXPORT_OK   = qw(

);  
  %EXPORT_TAGS = ( 'all' => [ @EXPORT, @EXPORT_OK ], 'none' => [ @EXPORT_OK ] ); 

}

our @EXPORT_OK;

use SDL;
use SDL::TTF;
use SDL::Color;
use SDL::Rect;
use SDL::Event;
use SDL::Video;
use SDL::GFX::Primitives;
use bytes;
use base qw(Class::Accessor::Fast);
use Color::Scheme;
use Text::Wrap;

use constant {

	SDL_MENUS_ALIGN_LEFT		=> 0x0,
	SDL_MENUS_ALIGN_CENTER		=> 0x1,
	SDL_MENUS_ALIGN_RIGHT		=> 0x2,

	SDL_MENUS_ALIGN_TOP		=> 0x0,		# Help text vertical alignment
	SDL_MENUS_ALIGN_MIDDLE		=> 0x1,		# Help text vertical alignment
	SDL_MENUS_ALIGN_BOTTOM		=> 0x2,		# Help text vertical alignment

	SDL_MENUS_LOCKED_ALIGN 		=> 0x80,	# high bit
	SDL_MENUS_LOCKED_ALIGN_LEFT	=> 0x80,	# cannot be adjusted
	SDL_MENUS_LOCKED_ALIGN_CENTER	=> 0x81,	# cannot be adjusted
	SDL_MENUS_LOCKED_ALIGN_RIGHT	=> 0x82,	# cannot be adjusted

	# for use with menu_align only
	SDL_MENUS_ALIGN_NONE		=> 0xff,	

	SDL_MENUS_SELECTOR_BAR_NONE	=> 0,
	SDL_MENUS_SELECTOR_BAR_FULL	=> 1,
	SDL_MENUS_SELECTOR_BAR_PARTIAL	=> 2,

	SDL_MENUS_DO_TOGGLE		=>	0,
	SDL_MENUS_DO_ENTER		=>	1,
	SDL_MENUS_DO_CONFIG		=>	2,
	SDL_MENUS_GET_TEXT		=>	3,

	SDL_MENUS_ITEMS			=>	1,

  # ==============================================================
  # For each scheme, we must set the appropriate index to each
  # menu attribute
  #
  # The first is usually the most saturated color, 
  # The second a darkened version, 
  # The third a pale version 
  # And fourth a less-pale version.
  #
  # To understand the colour scheme in more detail
  # please see: http://search.cpan.org/~ian/Color-Scheme-1.02/
  # and http://colorschemedesigner.com/
  # ==============================================================

      SDL_MENUS_CS2_SET1 		=> 0,
      SDL_MENUS_CS2_SET2 		=> 1,
      SDL_MENUS_CS2_SET3 		=> 2,
      SDL_MENUS_CS2_SET4 		=> 3,

      SDL_MENUS_CS2_SAT	 		=> 0,
      SDL_MENUS_CS2_DARK 	 	=> 1,
      SDL_MENUS_CS2_PALE	 	=> 2,
      SDL_MENUS_CS2_LIGHT	 	=> 3,

  # ==============================================================
  # We include TTF_STYLE_ so that the client
  # does not need to use SDL::TTF
  # ==============================================================

      SDL_MENUS_TTF_STYLE_NORMAL 	=> TTF_STYLE_NORMAL,
      SDL_MENUS_TTF_STYLE_BOLD		=> TTF_STYLE_BOLD,
      SDL_MENUS_TTF_STYLE_ITALIC	=> TTF_STYLE_ITALIC,
      SDL_MENUS_TTF_STYLE_UNDERLINE	=> TTF_STYLE_UNDERLINE,
      SDL_MENUS_TTF_STYLE_STRIKETHROUGH	=> TTF_STYLE_STRIKETHROUGH,

      SDL_MENUS_TTF_HINTING_NORMAL	=> TTF_HINTING_NORMAL,
      SDL_MENUS_TTF_HINTING_LIGHT	=> TTF_HINTING_LIGHT,
      SDL_MENUS_TTF_HINTING_MONO	=> TTF_HINTING_MONO,
      SDL_MENUS_TTF_HINTING_NONE	=> TTF_HINTING_NONE,
};


__PACKAGE__->mk_accessors(
    qw(
    w
    h
    x
    y
    menu_w
    menu_h
    font
    hotkeys_color
    show_hotkeys
    font_color 
    font_style
    font_hinting
    select_color
    select_background_color
    selector_bar
    background_color
    trigger
    mydata
    color_scheme
    color_scheme_settings
    color_scheme_disable
    active_text
    font_size
    current
    outline
    align
    menu_align
    _menu_name


    center_spacing
    center_spacing_enable

    horizontal_spacing
    vertical_spacing

    separator
    separator_color
    separator_enable

    border
    border_color
    border_padding
    border_padding_color

    help_color
    help_align
    help_valign
    help_show
    help_enable
    help_lines
    help_lines_format
    help_background_color

    title_enable
    title_lines
    title_color
    title_background_color
    title_height
    title_align
    title_valign
    title_font_style
    title_font_hinting

    _mouse_menu
    _mouse_state
    _mouse_wheel
    _mouse_get

    _active_menu
    _menus
    _menus_order
    _items
    _font
    _font_thin_width
    _font_width
    _font_height
    _max_width
    _max_height
    _max_state_width
    _max_state_height
    _max_lines
    _x
    _y
    _screen
    _border_width
    _border_height
    _border_padding_width
    _border_padding_height
    _title_font
    _hotkeys
    ),
);

# ==============================================================
# The following settings map the Colour Scheme to our menu
# attributes, you can pass your own in $MenuControl to override
# these values
# ==============================================================
my $ColourSchemeSettings={

      # can only use SDL_MENUS_CS2_SET1
      'monochromatic' => {

    title_color			=>[SDL_MENUS_CS2_SET1,SDL_MENUS_CS2_SAT],
    title_background_color	=>[SDL_MENUS_CS2_SET1,SDL_MENUS_CS2_DARK],

	font_color		=>[SDL_MENUS_CS2_SET1,SDL_MENUS_CS2_LIGHT],
    hotkeys_color		=>[SDL_MENUS_CS2_SET1,SDL_MENUS_CS2_PALE],

	  state_color		=>[SDL_MENUS_CS2_SET1,SDL_MENUS_CS2_PALE],
  	  help_color		=>[SDL_MENUS_CS2_SET1,SDL_MENUS_CS2_PALE],
	  select_color		=>[SDL_MENUS_CS2_SET1,SDL_MENUS_CS2_PALE],
  select_background_color	=>[SDL_MENUS_CS2_SET1,SDL_MENUS_CS2_LIGHT],

	background_color	=>[SDL_MENUS_CS2_SET1,SDL_MENUS_CS2_DARK],
   help_background_color	=>[SDL_MENUS_CS2_SET1,SDL_MENUS_CS2_LIGHT],
  state_background_color	=>[SDL_MENUS_CS2_SET1,SDL_MENUS_CS2_DARK],

	border_color		=>[SDL_MENUS_CS2_SET1,SDL_MENUS_CS2_PALE],
	border_padding_color	=>[SDL_MENUS_CS2_SET1,SDL_MENUS_CS2_SAT],
	separator_color		=>[SDL_MENUS_CS2_SET1,SDL_MENUS_CS2_LIGHT],

      },
      # can only use SDL_MENUS_CS2_SET1 & 2
      'contrast' => {

    title_color			=>[SDL_MENUS_CS2_SET1,SDL_MENUS_CS2_SAT],
    title_background_color	=>[SDL_MENUS_CS2_SET2,SDL_MENUS_CS2_DARK],

	font_color		=>[SDL_MENUS_CS2_SET1,SDL_MENUS_CS2_LIGHT],
    hotkeys_color		=>[SDL_MENUS_CS2_SET1,SDL_MENUS_CS2_PALE],

	  state_color		=>[SDL_MENUS_CS2_SET2,SDL_MENUS_CS2_PALE],
  	  help_color		=>[SDL_MENUS_CS2_SET2,SDL_MENUS_CS2_PALE],
	  select_color		=>[SDL_MENUS_CS2_SET2,SDL_MENUS_CS2_PALE],
  select_background_color	=>[SDL_MENUS_CS2_SET1,SDL_MENUS_CS2_LIGHT],

	background_color	=>[SDL_MENUS_CS2_SET2,SDL_MENUS_CS2_DARK],
   help_background_color	=>[SDL_MENUS_CS2_SET2,SDL_MENUS_CS2_SAT],
  state_background_color	=>[SDL_MENUS_CS2_SET2,SDL_MENUS_CS2_DARK],

	border_color		=>[SDL_MENUS_CS2_SET1,SDL_MENUS_CS2_PALE],
	border_padding_color	=>[SDL_MENUS_CS2_SET1,SDL_MENUS_CS2_SAT],
	separator_color		=>[SDL_MENUS_CS2_SET2,SDL_MENUS_CS2_LIGHT],
      },

      # can only use SDL_MENUS_CS2_SET1,2 & 3
      'triade' => {
    title_color			=>[SDL_MENUS_CS2_SET1,SDL_MENUS_CS2_SAT],
    title_background_color	=>[SDL_MENUS_CS2_SET3,SDL_MENUS_CS2_DARK],

	font_color		=>[SDL_MENUS_CS2_SET1,SDL_MENUS_CS2_LIGHT],
    hotkeys_color		=>[SDL_MENUS_CS2_SET1,SDL_MENUS_CS2_PALE],

	  state_color		=>[SDL_MENUS_CS2_SET3,SDL_MENUS_CS2_PALE],
  	  help_color		=>[SDL_MENUS_CS2_SET3,SDL_MENUS_CS2_PALE],
	  select_color		=>[SDL_MENUS_CS2_SET3,SDL_MENUS_CS2_PALE],
  select_background_color	=>[SDL_MENUS_CS2_SET1,SDL_MENUS_CS2_LIGHT],

	background_color	=>[SDL_MENUS_CS2_SET2,SDL_MENUS_CS2_DARK],
   help_background_color	=>[SDL_MENUS_CS2_SET2,SDL_MENUS_CS2_SAT],
  state_background_color	=>[SDL_MENUS_CS2_SET2,SDL_MENUS_CS2_DARK],

	border_color		=>[SDL_MENUS_CS2_SET2,SDL_MENUS_CS2_LIGHT],
	border_padding_color	=>[SDL_MENUS_CS2_SET3,SDL_MENUS_CS2_SAT],
	separator_color		=>[SDL_MENUS_CS2_SET2,SDL_MENUS_CS2_LIGHT],
      },

      # can use all SDL_MENUS_CS2_SET1,2,3,4
      'tetrade' => {

    title_color			=>[SDL_MENUS_CS2_SET1,SDL_MENUS_CS2_SAT],
    title_background_color	=>[SDL_MENUS_CS2_SET4,SDL_MENUS_CS2_DARK],

	font_color		=>[SDL_MENUS_CS2_SET1,SDL_MENUS_CS2_LIGHT],
    hotkeys_color		=>[SDL_MENUS_CS2_SET1,SDL_MENUS_CS2_PALE],

	  state_color		=>[SDL_MENUS_CS2_SET3,SDL_MENUS_CS2_PALE],
  	  help_color		=>[SDL_MENUS_CS2_SET3,SDL_MENUS_CS2_PALE],
	  select_color		=>[SDL_MENUS_CS2_SET3,SDL_MENUS_CS2_PALE],

  select_background_color	=>[SDL_MENUS_CS2_SET1,SDL_MENUS_CS2_LIGHT],

	background_color	=>[SDL_MENUS_CS2_SET2,SDL_MENUS_CS2_DARK],
   help_background_color	=>[SDL_MENUS_CS2_SET2,SDL_MENUS_CS2_SAT],
  state_background_color	=>[SDL_MENUS_CS2_SET2,SDL_MENUS_CS2_DARK],

	border_color		=>[SDL_MENUS_CS2_SET1,SDL_MENUS_CS2_SAT],
	border_padding_color	=>[SDL_MENUS_CS2_SET3,SDL_MENUS_CS2_SAT],
	separator_color		=>[SDL_MENUS_CS2_SET4,SDL_MENUS_CS2_LIGHT],

      },

      # can only use SDL_MENUS_CS2_SET1,2 & 3
      'analogic' => {

    title_color			=>[SDL_MENUS_CS2_SET1,SDL_MENUS_CS2_SAT],
    title_background_color	=>[SDL_MENUS_CS2_SET1,SDL_MENUS_CS2_DARK],

	font_color		=>[SDL_MENUS_CS2_SET1,SDL_MENUS_CS2_LIGHT],
    hotkeys_color		=>[SDL_MENUS_CS2_SET1,SDL_MENUS_CS2_PALE],

	  state_color		=>[SDL_MENUS_CS2_SET2,SDL_MENUS_CS2_PALE],
  	  help_color		=>[SDL_MENUS_CS2_SET2,SDL_MENUS_CS2_PALE],
	  select_color		=>[SDL_MENUS_CS2_SET2,SDL_MENUS_CS2_PALE],

  select_background_color	=>[SDL_MENUS_CS2_SET1,SDL_MENUS_CS2_LIGHT],

	background_color	=>[SDL_MENUS_CS2_SET2,SDL_MENUS_CS2_DARK],
   help_background_color	=>[SDL_MENUS_CS2_SET2,SDL_MENUS_CS2_SAT],
  state_background_color	=>[SDL_MENUS_CS2_SET2,SDL_MENUS_CS2_DARK],

	border_color		=>[SDL_MENUS_CS2_SET3,SDL_MENUS_CS2_PALE],
	border_padding_color	=>[SDL_MENUS_CS2_SET3,SDL_MENUS_CS2_SAT],
	separator_color		=>[SDL_MENUS_CS2_SET2,SDL_MENUS_CS2_LIGHT],
      },

      # can use all SDL_MENUS_CS2_SET1,2,3,4
      'analogic_comp' => {

    title_color			=>[SDL_MENUS_CS2_SET1,SDL_MENUS_CS2_SAT],
    title_background_color	=>[SDL_MENUS_CS2_SET1,SDL_MENUS_CS2_DARK],

	font_color		=>[SDL_MENUS_CS2_SET1,SDL_MENUS_CS2_LIGHT],
    hotkeys_color		=>[SDL_MENUS_CS2_SET1,SDL_MENUS_CS2_PALE],

	  state_color		=>[SDL_MENUS_CS2_SET2,SDL_MENUS_CS2_PALE],
	  select_color		=>[SDL_MENUS_CS2_SET2,SDL_MENUS_CS2_PALE],
   	  help_color		=>[SDL_MENUS_CS2_SET2,SDL_MENUS_CS2_PALE],

  select_background_color	=>[SDL_MENUS_CS2_SET1,SDL_MENUS_CS2_LIGHT],

	background_color	=>[SDL_MENUS_CS2_SET4,SDL_MENUS_CS2_DARK],
   help_background_color	=>[SDL_MENUS_CS2_SET2,SDL_MENUS_CS2_SAT],
  state_background_color	=>[SDL_MENUS_CS2_SET4,SDL_MENUS_CS2_DARK],

	border_color		=>[SDL_MENUS_CS2_SET3,SDL_MENUS_CS2_PALE],
	border_padding_color	=>[SDL_MENUS_CS2_SET3,SDL_MENUS_CS2_SAT],
	separator_color		=>[SDL_MENUS_CS2_SET2,SDL_MENUS_CS2_LIGHT],
      },

};
# ==============================================================
# if no $ColourSchemeDefaults is passwd we use this one
# ==============================================================
my $ColourSchemeDefaults={
      scheme=>'monochromatic', 
      from_hue=>220,
      distance=>0,
      variation=>'hard',
      web_safe=>1,
      add_complement=>0,
      fine_tune=>0,
};
# ==============================================================
sub new {

  eval(' SDL::TTF::init' );
  if($@) { Carp::croak "Cannot initialize ttf, please ensure Alien::SDL is installed with SDL_ttf supported " }

  my $this=shift;

  my $MenuControl=shift;
  
  # use default color settings if none specified
  $MenuControl->{'color_scheme_settings'}=$ColourSchemeSettings unless ($MenuControl->{'color_scheme_settings'});

  # use default color settings if none specified
  $MenuControl->{'color_scheme'}=$ColourSchemeDefaults unless ($MenuControl->{'color_scheme'});

  my $self = $this->Class::Accessor::Fast::new($MenuControl);
  $self->{_menus}={};

  # we need to first de-construct the menus
  # and remove the menu name, and create a hash
  # that includes all menus

  my @menus=@_;
  # create an empty array of hashes of all menus
  my $HOM={};

  # we maintain the original order here
  my @menus_order;

  for my $menu (@menus) {
    my $index=shift @{$menu};
    push (@menus_order,$index);			# we must reserve menu order
    $HOM->{$index}=shift;
  }
  $self->{_menus_order}=[@menus_order];		# save order

  # our hash is stored here

  $self->_menus($HOM);

  @menus=();				# sap the users menus

  for (@{$self->_menus_order}) {
    push (@menus,$HOM->{$_});		# push entire menu into array
  }

  # NOTE: Setup color defaults if not set,
  # we only create empty arrays, the 
  # _update_color_scheme function (below)
  # fills in the correct colour
  # based on the default/selected colour scheme

  $self->{font_color}||=[];
  $self->{select_background_color}||=[];
  $self->{select_color}||=[];
  $self->{border_color}||=[];
  $self->{border_padding_color}||=[];
  $self->{separator_color}||=[];
  $self->{background_color}||=[];
  $self->{help_color}||=[];
  $self->{help_background_color}||=[];
  $self->{title_color}||=[];
  $self->{title_background_color}||=[];
  $self->{hotkeys_color}||=[];

  $self->{show_hotkeys}||=1 if (!defined $self->{show_hotkeys});		# default enable
  $self->{help_align}=SDL_MENUS_ALIGN_LEFT if (! defined $self->{help_align});
  $self->{help_valign}=SDL_MENUS_ALIGN_TOP if (! defined $self->{help_valign});
  $self->{title_align}=SDL_MENUS_ALIGN_LEFT if (! defined $self->{title_align});
  $self->{title_valign}=SDL_MENUS_ALIGN_TOP if (! defined $self->{title_valign});
  $self->{selector_bar}=SDL_MENUS_SELECTOR_BAR_NONE if (! defined $self->{selector_bar});

  $self->{help_show}||=0;
  $self->{help_enable}=1 if (! defined $self->{help_enable});	# enable help by default
  $self->{help_lines}=0 unless ($self->help_enable);		# say no lines if disabled
  $self->{help_lines_format}=1 if (! defined $self->{help_lines_format});

  $self->{title_enable}=1 if (! defined $self->{title_enable});	# 0=disable
  $self->{title_lines}=2 if (! defined $self->{title_lines});

  $self->{title_lines}=0 unless ($self->title_enable);		# 0=disable

  $self->{title_height}=$self->{title_lines} if (! defined $self->{title_height} || $self->{title_height} > $self->{title_lines});

  $self->{font_style}||=SDL_MENUS_TTF_STYLE_NORMAL;
  $self->{font_hinting}||=SDL_MENUS_TTF_HINTING_NORMAL;

  $self->{title_font_style}||=SDL_MENUS_TTF_STYLE_NORMAL;
  $self->{title_font_hinting}||=SDL_MENUS_TTF_HINTING_NORMAL;

  $self->{_hotkeys}={};

  $self->{x}||=0;
  $self->{y}||=0;

  $self->{separator_enable}||=0;

  $self->{center_spacing}||=0;
  $self->{center_spacing_enable}||=0;
  $self->{horizontal_spacing}||=0;
  $self->{vertical_spacing}||=0;

  $self->{_border_width}=0;
  $self->{_border_height}=0;
  $self->{_border_padding_width}=0;
  $self->{_border_padding_height}=0;

  $self->{border}||=0;
  $self->{border_padding}||=0;

  $self->{menu_w}||=0;

  $self->current(0);

  $self->mydata({});					# user can put stuff here!

  $self->_calc_max_lines(@menus);
  $self->_calc_font_height;
  $self->_calc_menu_sizes(@menus);
  $self->_calc_font_width(@menus) if ($self->menu_w !=0);

  $self->{menu_align}=SDL_MENUS_ALIGN_LEFT if (! defined $self->{menu_align});
  $self->set_menu_align($self->menu_align) unless ($self->menu_align == SDL_MENUS_ALIGN_NONE);

  # configure all menu items

  $self->_do_config_menu(@menus_order);		# do config in this order

  # set the default color scheme
  $self->_update_color_scheme if (! $self->color_scheme_disable);

  bless($self, $this);				# ready for business
}
# ==============================================================
sub _calc_max_lines {

    my $self=shift;
    my @menus = @_;
    $self->_max_lines(0);
    for (@menus) {
    my @items=@{$_};
      my $lines=0;
      my $help=0;
      while( my ($name, $val) = splice @items, 0, 2 ) {
	$lines++;
	if (defined $val->{help}) {
	$val->{help_off}=0;				# set help to first line
	$help++;
	}
      }

      $lines+=$self->help_lines if ($help && $self->help_enable);	# add extra line for help
      $lines+=$self->vertical_spacing;
      $lines+=$self->title_lines;
      $self->_max_lines($lines) if ($lines > $self->_max_lines);

    }
}
# ==============================================================
sub ShowFontType {

  my $self=shift;
  my $font=shift;

  my $style = SDL::TTF::get_font_style( $font );
  print("normal\n")        if $style == TTF_STYLE_NORMAL;
  print("bold\n")          if $style  & TTF_STYLE_BOLD;
  print("italic\n")        if $style  & TTF_STYLE_ITALIC;
  print("underline\n")     if $style  & TTF_STYLE_UNDERLINE;
  print("strikethrough\n") if $style  & TTF_STYLE_STRIKETHROUGH;
}
# ==============================================================
sub _SetFont {

    my $self=shift;
    my $font_size=shift;

    return if ($font_size <1);

      my $font=SDL::TTF::open_font( $self->font, $font_size );

      Carp::croak 'Error opening font: ' . SDL::get_error () unless ($font);

       if ($font) {
 	$self->{_font}=$font;
 	SDL::TTF::set_font_hinting( $self->_font, $self->font_hinting) if ($self->font_hinting);
 	SDL::TTF::set_font_style( $self->_font, $self->font_style) if ($self->font_style);
       }

    # We assume W is the widest char, and 'i' is the thinest charm there is probably a better way
    # to find these valuesbut this works quiet well for ASCII

    ($self->{_font_thin_width}, $self->{_font_height}) = @{ SDL::TTF::size_text( $self->_font, "i") };
    ($self->{_font_width}, $self->{_font_height}) = @{ SDL::TTF::size_text( $self->_font, "W") };

    if ($self->title_enable && $self->title_lines) {
      my $font_height=$self->{_font_height};
      my $font_width =$self->{_font_width};
      my $max_height=($self->title_height * $font_height);
  
	$self->{_title_font}=SDL::TTF::open_font( $self->font, $font_size );
	SDL::TTF::set_font_hinting( $self->_title_font, $self->title_font_hinting) if ($self->title_font_hinting);
	SDL::TTF::set_font_style( $self->_title_font, $self->title_font_style) if ($self->title_font_style);
	($font_width, $font_height) = @{ SDL::TTF::size_text( $self->_font, "W") };

      if ($font_height < $max_height) {
	  while ($font_height < $max_height) {
	    $font_size++;
	    $self->{_title_font}=SDL::TTF::open_font( $self->font, $font_size );
	    SDL::TTF::set_font_hinting( $self->_title_font, $self->title_font_hinting) if ($self->title_font_hinting);
	    SDL::TTF::set_font_style( $self->_title_font, $self->title_font_style) if ($self->title_font_style);
	    ($font_width, $font_height) = @{ SDL::TTF::size_text( $self->_title_font, "W") };
	  }
      }

      if ($font_height > $max_height) {
	  while ($font_height > $max_height) {
	    $font_size--;
	    $self->{_title_font}=SDL::TTF::open_font( $self->font, $font_size );
	    SDL::TTF::set_font_hinting( $self->_title_font, $self->title_font_hinting) if ($self->title_font_hinting);
	    SDL::TTF::set_font_style( $self->_title_font, $self->title_font_style) if ($self->title_font_style);
	    ($font_width, $font_height) = @{ SDL::TTF::size_text( $self->_title_font, "W") };
	  }
      }
    #$self->ShowFontType ($self->_title_font);
    }
}
# ==============================================================
sub _calc_font_width {

    my $self=shift;
    my @menus = @_;

    my $w=$self->menu_w;

    while (1) {

      my $maxwidth=$self->_max_width + ($self->center_spacing * $self->_font_width) + ($self->horizontal_spacing * $self->_font_width) +  $self->_max_state_width;

      if ($maxwidth > $w) {

	$self->{font_size}--;				# make it smaller
#	$self->_calc_font_height;

	$self->_SetFont($self->font_size);
	$self->_calc_menu_sizes(@menus);

      } else {

      $self->{menu_h}=$self->h;
#      $self->{menu_w}=$self->w;

	$self->_calc_font_height;
	$self->_calc_menu_sizes(@menus);

      last;
      }
    }

#     $self->{_border_width} =int $self->{_font_width}  * $self->{border};
#     $self->{_border_height}=int $self->{_font_height} * $self->{border};
#     $self->{_border_padding_width}=int $self->{_font_width} * $self->{border_padding};
#     $self->{_border_padding_height}=int $self->{_font_height} * $self->{border_padding};
#     $self->{_x}=int $self->{_border_width}  + $self->{_border_padding_width};
#     $self->{_y}=int $self->{_border_height} + $self->{_border_padding_height}

# make square
    $self->{_border_width} =int $self->{_font_width}  * $self->{border};
    $self->{_border_height}=int $self->{_font_width} * $self->{border};
    $self->{_border_padding_width}=int $self->{_font_width} * $self->{border_padding};
    $self->{_border_padding_height}=int $self->{_font_width} * $self->{border_padding};
    $self->{_x}=int $self->{_border_width}  + $self->{_border_padding_width};
    $self->{_y}=int $self->{_border_height} + $self->{_border_padding_height}

}
# ==============================================================
sub _calc_font_height {

    my $self = shift;

    my $h=$self->menu_h;
    my $count=$self->_max_lines;

    my $font_size=int ($h/$count);		# This would be the largest possible size
    while (1) {
    $self->_SetFont($font_size);
    last if ($font_size == 1);

      if ($self->{_font_height} > int ($h/$count)) {
	$font_size--;				# make it smaller
      } else {
      last;
      }
    }

    $self->{font_size}=$font_size;


#     $self->{_border_width} =int $self->{_font_width}  * $self->{border};
#     $self->{_border_height}=int $self->{_font_height} * $self->{border};
#     $self->{_border_padding_width}=int $self->{_font_width} * $self->{border_padding};
#     $self->{_border_padding_height}=int $self->{_font_height} * $self->{border_padding};
#     $self->{_x}=int $self->{_border_width}  + $self->{_border_padding_width};
#     $self->{_y}=int $self->{_border_height} + $self->{_border_padding_height}

# make square
    $self->{_border_width} =int $self->{_font_width}  * $self->{border};
    $self->{_border_height}=int $self->{_font_width} * $self->{border};
    $self->{_border_padding_width}=int $self->{_font_width} * $self->{border_padding};
    $self->{_border_padding_height}=int $self->{_font_width} * $self->{border_padding};
    $self->{_x}=int $self->{_border_width}  + $self->{_border_padding_width};
    $self->{_y}=int $self->{_border_height} + $self->{_border_padding_height}

#    $self->{menu_h}-=$self->{border} * 2 ;
#    $self->{border_padding}=$self->border - $self->border_padding;

}
# ==============================================================
sub _calc_menu_sizes {

    my $self=shift;
    my @menus = @_;

    $self->_items([]);
    $self->_max_width(0);
    $self->_max_height(0);
    $self->_max_state_width(0);
    $self->_max_state_height(0);
    $self->{current}=(0);

    my $separator=$self->separator;
    $separator||='';

    for (@menus) {

    my @items=@{$_};

      while( my ($name, $val) = splice @items, 0, 2 ) {
	bless ($val);

	my ($width, $height) = @{ SDL::TTF::size_text( $self->_font, $name)};
	$self->_max_width($width) if ($width > $self->_max_width);
	$self->_max_height($height) if ($height > $self->_max_height);

	if (defined $val->{active_text}) {
	  ($width, $height) = @{ SDL::TTF::size_text( $self->_font, $val->{active_text})};
	  $self->_max_width($width) if ($width > $self->_max_width);
	  $self->_max_height($height) if ($height > $self->_max_height);
	}

	if (defined $val->{state}) {
	  $val->{current}||=0;
	  my @state = @{$val->{state}};
	  for my $state (@state) {
	    ($width, $height) = @{ SDL::TTF::size_text( $self->_font, "$state$separator")};
	    $self->_max_state_width($width) if ($width > $self->_max_state_width);
	    $self->_max_state_height($height) if ($height > $self->_max_state_height);
	  }
	}
      }
    }

$self->w(($self->_max_width + $self->_max_state_width ) + ($self->_font_width * ($self->center_spacing + $self->horizontal_spacing)) + (($self->_border_width + $self->_border_padding_width) * 2) );
$self->h(($self->_max_height * $self->_max_lines) + (($self->_border_height + $self->_border_padding_height) * 2));
}
# ==============================================================
# Here we cycle thru all menu items (in the order we received)
# calling the callback function with the SDL_MENUS_DO_CONFIG message
# Usually, the callback should simply return, but it can do
# whatever it likes, for example, setup custom private colors
# ==============================================================
sub _do_config_menu {

  my $self=shift;
  my @menus_order = @_;
  my $HOM=$self->_menus;

  for my $menu_name (@menus_order) {
    my @items=@{$HOM->{$menu_name}};
    my $count=0;
    while( my ($menu_item, $item) = splice @items, 0, 2 ) {
	next unless (ref $item->{'trigger'} eq 'CODE');
	$item->{'action'}=SDL_MENUS_DO_CONFIG;
	my $selected=$item->{'state'}[$item->{'current'}] if (defined $item->{'state'});
	$item->{trigger}->($self,$selected,$item,$menu_name,$menu_item);
    }
  }

}
# ==============================================================
# Sets the menu to use and reset its position!
# ==============================================================
sub set_menu {

    my ($self,$menu_name,$x,$y) = @_;
    # set selected menu
    return unless (defined $self->_menus->{$menu_name});
    $self->{_menu_name}=$menu_name;

    $self->_items($self->_menus->{$menu_name});		# switch to the new menu (the magic line)
 
    if (defined $x) {
	$self->x($x);
	$self->_x($x+$self->_border_width + $self->_border_padding_width);
    }
    if (defined $y) {
	$self->y($y);
	$self->_y($y+$self->_border_height + $self->_border_padding_height + ($self->title_lines * $self->_font_height));
    }

   # get the Hot keys for this menu
    my $maxitems=($#{$self->_items}-1)/2;
     for ( 0 .. $maxitems ) {
      my $count=$_;
      my $ref=$self->_items->[$count * 2 + SDL_MENUS_ITEMS];
      if (defined $ref->{'hotkeys'}) {
	my @keys=@{$ref->{'hotkeys'}};
	for (@keys) {
	  $self->_hotkeys->{$_}=$count;
	}
      }
     }
 
    # FIXME: need to save pos and restore it!
    $self->{current}=(0);				# start at the top of this menu
    # reset mouse cords
    $self->_reset_mouse_area;

}
# ==============================================================
sub _reset_mouse_area {

  my $self=shift;
  $self->{_mouse_menu}=[];
  $self->{_mouse_state}=[];
  $self->{_mouse_wheel}=[];
  $self->{_mouse_get}=0;				# 0 = update mouse cords

}
# ==============================================================
sub ColorBorder {
  my ($self,$screen) = @_;

  # border
  my @pos=(
    $self->x,
    $self->y, 
    $self->x + $self->w,
    $self->y + $self->h
    );
  SDL::GFX::Primitives::box_RGBA(  $screen, @pos,@{$self->border_color}, 255) if ($self->border);

  # border padding
  @pos=(
  $self->x + ($self->_border_width),
  $self->y + ($self->_border_height), 
  $self->x + $self->w - ($self->_border_width),
  $self->y + $self->h - ($self->_border_height),
  );
 SDL::GFX::Primitives::box_RGBA(  $screen, @pos,@{$self->border_padding_color}, 255) if ($self->border_padding);

}
# ==============================================================
# Sets the menu to use
# ==============================================================
sub set_menu_color {

    my ($self,$obj,@color) = @_;

      return if ($obj =~/^_/);			# cannot change these values

      # check MenuControl first
      if (defined $self->{$obj} && ref $self->{$obj} eq 'ARRAY') {
	    $self->{$obj}=[@color];
      } else {

      # do all other menus
	for my $menu (values %{$self->_menus}) {
	    my %menu=(@{$menu});
	    for my $hash (values %menu) {
		if (defined $hash->{$obj}) {
		  if (ref $hash->{$obj} eq 'ARRAY') {
		    $hash->{$obj}=[@color];
		  }
		} else {
		# doesn't exist, create it
		  $hash->{$obj}=[@color];
		}
	    }
	}

      }
}
# ==============================================================
# Sets the menu to use
# ==============================================================
sub set_menu_align {

  my ($self,$align) = @_;

  # Set all menu items to an alignment
  # unless the SDL_MENUS_LOCKED_ALIGN bit is set

  for my $menu (values %{$self->_menus}) {
      my %menu=(@{$menu});
      for my $hash (values %menu) {
	  if (defined $hash->{'align'}) {
	    if (! ($hash->{'align'} & SDL_MENUS_LOCKED_ALIGN)) {
	      $hash->{'align'}=$align;
	    }
	  } else {
	  # doesn't exist, create it
	    $hash->{'align'}=$align;
	  }
      }
  }

}
# ==============================================================
sub set_help_align {
  my ($self,$align) = @_;
  $self->{help_align}=$align;
}
# ==============================================================
sub set_help_valign {
  my ($self,$align) = @_;
  $self->{help_valign}=$align;
}
# ==============================================================
sub set_help_format {
  my ($self,$format) = @_;
  $self->{help_text_format}=$format;
}
# ==============================================================
sub DoCallback {

  my $self=shift;
  my $event=shift;
  my $ref=$self->_items->[$self->current * 2 + SDL_MENUS_ITEMS];
#  my $selected;
  my $selected=$ref->{'state'}[$ref->{'current'}] if (defined $ref->{'state'});
  return unless (ref $self->_items->[$self->current * 2 + SDL_MENUS_ITEMS]{trigger} eq 'CODE');
  $self->_items->[$self->current * 2 + SDL_MENUS_ITEMS]{trigger}->($self,$selected,bless ($self->_items->[$self->current * 2 + SDL_MENUS_ITEMS]),$self->_menu_name,$self->_items->[$self->current * 2],$event);
  $self->_reset_mouse_area;

}
# ==============================================================
sub _doReturn {

  my $self=shift;
  my $event=shift;

  my $ref=$self->_items->[$self->current * 2 + SDL_MENUS_ITEMS];
  if ($ref->{toggle}) {
    $ref->{'action'}=SDL_MENUS_DO_ENTER;	
    $self->DoCallback ($event);
 #   $ref->{'action'}=SDL_MENUS_DO_TOGGLE;	

  } else {
    $ref->{'action'}=SDL_MENUS_DO_TOGGLE;	
    $self->DoCallback ($event);
  }
}
# ==============================================================
sub toggle_left {

  my $self=shift;
  my $ref=$self->_items->[$self->current * 2 + SDL_MENUS_ITEMS];
  if ($ref->{toggle} && defined $ref->{current}) {
    $ref->current( ($ref->current - 1) % scalar @{$ref->{state}});
  }
$ref->{state}[$ref->{'current'}];
}
# ==============================================================
sub toggle_right {

  my $self=shift;
  my $ref=$self->_items->[$self->current * 2 + SDL_MENUS_ITEMS];
  if ($ref->{toggle} && defined $ref->{current}) {
    $ref->current( ($ref->current + 1) % scalar @{$ref->{state}});
  }

$ref->{state}[$ref->{'current'}];
}
# ==============================================================
sub _doToggle_left {

  my $self=shift;
  my $event=shift;
  my $ref=$self->_items->[$self->current * 2 + SDL_MENUS_ITEMS];
  if ($ref->{toggle} && defined $ref->{current}) {
    $ref->current( ($ref->current - 1) % scalar @{$ref->{state}});
    $ref->{'action'}=SDL_MENUS_DO_TOGGLE;	
    $self->DoCallback ($event);
  } else {
    $ref->{'action'}=SDL_MENUS_DO_TOGGLE;	
    $self->DoCallback ($event);
  }

}
# ==============================================================
sub _doToggle_right {

  my $self=shift;
  my $event=shift;

  my $ref=$self->_items->[$self->current * 2 + SDL_MENUS_ITEMS];
  if ($ref->{toggle} && defined $ref->{current}) {
    $ref->current( ($ref->current + 1) % scalar @{$ref->{state}});
    $ref->{'action'}=SDL_MENUS_DO_TOGGLE;
    $self->DoCallback ($event);
  } else {
    $ref->{'action'}=SDL_MENUS_DO_TOGGLE;
    $self->DoCallback ($event);
  }
}
# ==============================================================
sub _doUp {
  my $self=shift;
  $self->current( ($self->current - 1) % ((scalar @{$self->_items})/2) );
}
# ==============================================================
sub _doDown {
  my $self=shift;
  $self->current( ($self->current + 1) % ((scalar @{$self->_items})/2) );
}
# ==============================================================
sub _doEnd {
  my $self=shift;
  $self->current(((scalar @{$self->_items})/2)-1);
}
# ==============================================================
sub _doHome {
  my $self=shift;
  $self->current(0);
}
# ==============================================================
sub event_hook {

    my ($self, $event) = @_;
    my $type=$event->type;
    my $retval=0;
    my $count=0;
    my $done=0;

      if ($type == SDL_MOUSEMOTION || $type == SDL_MOUSEBUTTONDOWN) {
	    if ($type == SDL_MOUSEMOTION) {
	    # not used yet
	    # ($event->motion_x,$event->motion_y);
	    } else {

	    my $x=$event->button_x;
	    my $y=$event->button_y;
	    my $button=$event->button_button;

	    # is Mouse Wheel
	    if ( $button == SDL_BUTTON_WHEELUP || $button == SDL_BUTTON_WHEELDOWN) {
	      my @wheelpos=@{$self->_mouse_wheel};
	      while( my ($x1, $y1, $x2, $y2) = splice @wheelpos, 0, 4 ) {
		if ($x >=$x1 && $x <=$x2 && $y >=$y1 && $y <=$y2) {
		  $done++;
		  # if we're not already on this item
		  # select it only, else do enter
		  if ($button == SDL_BUTTON_WHEELUP) {
		  $self->_doUp;
		  }
		  else {
		  $self->_doDown;
		  }
		  last;
		}
		$count++;
	      }
	    }
	    return 1 if ($done);

	    # check menus
	    my @menupos=@{$self->_mouse_menu};
	    $count=0;
	    while( my ($x1, $y1, $x2, $y2) = splice @menupos, 0, 4 ) {
	      if ($x >=$x1 && $x <=$x2 && $y >=$y1 && $y <=$y2) {
		  $done++;
		# if we're not already on this item
		# select it only, else do enter
		if ($self->current == $count) {
		  $self->_doReturn ($event);
		} else {
		  $self->current($count);
		}
		last;
	      }
	      $count++;
	    }
	    return 1 if ($done);

	    my @statepos=@{$self->_mouse_state};
	    $count=0;
	    # check states
	    while( my ($x1, $y1, $x2, $y2) = splice @statepos, 0, 4 ) {
	      if ($x >=$x1 && $x <=$x2 && $y >=$y1 && $y <=$y2) {
		$done++;
		# if we're not already on this item
		# select it only, else do a toggle
		if ($self->current == $count) {

		   # here we cycle thru the options
		   # left or right
		  if ($button == SDL_BUTTON_RIGHT || $button == SDL_BUTTON_WHEELDOWN) {
		      $self->_doToggle_right ($event);
		  }
		  elsif ($button == SDL_BUTTON_LEFT  || $button == SDL_BUTTON_WHEELUP) {
		      $self->_doToggle_left ($event);
		  }

		} else {
		  $self->current($count);
		}
		last;
	      }
	      $count++;
	    }
	    return 1 if ($done);
	    } 
	  }

    if ( $type == SDL_KEYDOWN ) {
        my $key = $event->key_sym;
        if ($key == SDLK_DOWN) {
	  $self->_doDown;
        }
        elsif ($key == SDLK_HOME) {
	  $self->_doHome;
	}
        elsif ($key == SDLK_END) {
	  $self->_doEnd;
        }
        elsif ($key == SDLK_UP) {
	  $self->_doUp;
        }
        elsif ($key == SDLK_RIGHT) {
	  $self->_doToggle_right ($event);
        }
        elsif ($key == SDLK_LEFT) {
	  $self->_doToggle_left ($event);
        }
        elsif ($key == SDLK_RETURN or $key == SDLK_KP_ENTER ) {
	  $self->_doReturn ($event);
        } else {

	# We have a list of SDLK keys in $self->_hotkeys for 
	# for this menu.
 
	    my $keypos=$self->_hotkeys->{$key};		# get the value
 	    if (defined $keypos) {				# does it exist
	      if ($self->{current} == $keypos) {	 	# are we already here?
 		$self->_doToggle_right ($event);		# Toggle if we are already here
	      } else {
		$self->current($keypos);		 	# move there
		if ($key eq SDLK_ESCAPE) {
		  $self->_doToggle_right ($event);		# if the selected item is escape don't wait, do it
		}
	      }
		return 1;				# changes
	     }
	}
	return 1;		# changes
    }

return 0;		# no changes
}
# ==============================================================
sub _GetCS2RGBColor {
    my $scheme=shift;
    my $colorset=shift;
    my $color=shift;
    map {hex($_) } unpack 'a2a2a2', ($scheme->colorset->[$colorset][$color]);
}
# ==============================================================
sub scheme_set_item {

  my ($self,$param,$selected)=@_;
  $self->color_scheme->{$param}=$selected;
  $self->_update_color_scheme;

}
# ==============================================================
sub _update_color_scheme {

  my $self=shift;
  my $scheme = Color::Scheme->new;
  my $name='';
  my $comp='';

  for my $key (qw(scheme from_hue distance variation web_safe add_complement)) {

    my $value = $self->color_scheme->{$key};

    if ($value =~ /^yes$/i) {
	$value=1;
    } elsif ($value =~ /^no$/i) {
	$value=0;
    }

    $name=$value if ($key eq 'scheme');		# we need this

    $comp="_comp" if ($key eq 'add_complement' && $value == 1 && $name eq 'analogic');	# we need this

    if ($key eq 'add_complement') {
     if ($name eq 'analogic') {
       $scheme->$key($value);			# allow complement if analogic
     } else {
       $scheme->$key(0);			# turn complement off, unless analogic
     }
    } else {

       if ($key eq 'from_hue') {
 	$value+=$self->color_scheme->{'fine_tune'};
       }

      $scheme->$key($value);			# turn complement off, unless analogic
    }
  }

    # for the scheme selected or default
    my $this=$self->color_scheme_settings->{"$name$comp"};

    # set all the attributes the the RGB colors
    for my $key (keys %{$this}) {
      my @colors=@{$this->{$key}};
      $self->set_menu_color($key,_GetCS2RGBColor($scheme,@colors));
    }

}
# ==============================================================
sub vtest {
my $screen=shift;
#SDL::Video::update_rect( $screen, 0,0,0,0);
#sleep (1);
}

sub render {
    
    my ($self, $screen) = @_;

    my @RED=(255,0,0);
    my @GREEN=(0,255,0);
    my @BLUE=(0,0,255);
    my @PURPLE=(255,0,255);
    my @WHITE=(255,255,255);
    my @BLACK=(0,0,0);
    my @YELLOW=(255,255,0);
    my @CYAN=(0,255,255);

    my @MOUSE_WHEEL_AREA=(@YELLOW);
    my @MENU_ITEM_AREA=(@GREEN);
    my @MENU_ITEM_BACKGROUND_AREA=(@RED);

    my @STATE_ITEM_BACKGROUND_AREA=(@WHITE);
    my @STATE_ITEM_BACKGROUND_BLANK_AREA=(@WHITE);
    my @SEPARATOR_AREA=(@CYAN);
    my @STATE_ITEM_AREA=(@MOUSE_WHEEL_AREA);
    my @HELP_AREA=(@PURPLE);
    my @HELP_AREA_BACKGROUND=(@BLUE);
    my @UNUSED_AREA=(@BLACK);
    my @TITLE_AREA=(@WHITE);

    $self->ColorBorder($screen);

    my $maxwidth=$self->_max_width;

    $maxwidth=$self->_max_width + ($self->center_spacing * $self->_font_width) if ($self->center_spacing_enable && $self->center_spacing);
    my $hwidth=($self->horizontal_spacing * $self->_font_width) /2;

    my $vheight=($self->vertical_spacing * $self->_font_height )/2;

    $maxwidth+= $hwidth;
#    $maxwidth=$self->_max_width + ($self->center_spacing * $self->_font_width) + ($self->horizontal_spacing * $self->_font_width /2) if ($self->center_spacing_enable && $self->center_spacing);

    my $max_state_width=$self->_max_state_width;

    $max_state_width=$self->_max_state_width + ($self->center_spacing * $self->_font_width) unless ($self->center_spacing_enable && $self->center_spacing);

    $max_state_width+=$hwidth;
    
#    my $vtest=sub {vtest($screen);};

if ($self->title_enable && $self->title_lines) {
  
    # fill title background

    my @title_background_color=@{$self->{title_background_color}};
    my @pos=(
	    $self->x +$self->_border_width + $self->_border_padding_width, 
	    $self->y +$self->_border_height + $self->_border_padding_height, 
	    $maxwidth+$max_state_width, ($self->title_lines * $self->_font_height));

    my $rect=SDL::Rect->new( @pos);
    my $pixelx=SDL::Video::map_RGBA ( $screen->format, @title_background_color,255);
    SDL::Video::fill_rect( $screen, $rect, $pixelx);
#$vtest->();
 
    if ($self->outline) {
      $pos[2]+=$pos[0]; $pos[3]+=$pos[1]; $pos[0]+=1; $pos[1]+=1; $pos[2]-=1; $pos[3]-=1; 
      SDL::GFX::Primitives::rectangle_RGBA(  $screen, @pos,@TITLE_AREA, 255);
#$vtest->();
    }
 	my $title_color=SDL::Color->new( @{$self->title_color});
 	my $title_name = $self->{_menu_name};
        my $surface = SDL::TTF::render_text_blended( $self->_title_font, $title_name, $title_color);

 	my $align=$self->title_align;

	# Align Title Left
 	@pos=(
 	    $self->x +$self->_border_width + $self->_border_padding_width, 
 	    $self->y +$self->_border_height + $self->_border_padding_height, 
 	    $maxwidth+$max_state_width, ($self->title_lines * $self->_font_height));
 
  	if ($align != SDL_MENUS_ALIGN_LEFT) {
	    if ($align == SDL_MENUS_ALIGN_CENTER) {
		$pos[0] = $self->x + $self->_border_width + $self->_border_padding_width +
		(($maxwidth+$max_state_width)/2) - ($surface->w /2);
	    } else {
		$pos[0] = $self->x + $self->_border_width + $self->_border_padding_width +
		$maxwidth+$max_state_width - $surface->w;
	    }
 	}

	my $valign=$self->title_valign;

	if ($valign == SDL_MENUS_ALIGN_BOTTOM) {
	$pos[1]+= (($self->title_lines * $self->_font_height) - $surface->h);
	} 

   	elsif ($valign == SDL_MENUS_ALIGN_MIDDLE) {
 	$pos[1]+= (($self->title_lines  * $self->_font_height) /2) - ($surface->h /2);
   	}

        SDL::Video::blit_surface(
                $surface, 
                SDL::Rect->new(0,0,$surface->w, $surface->h),
                $screen,
                SDL::Rect->new( @pos),
        );
 
#$vtest->();

}

    my $current=$self->current * 2;
    my $name=0;

    my $count;

    my $maxitems=($#{$self->_items}-1)/2;

    for ( 0 .. $maxitems ) {
    $count=$_;

    my $COUNT2=$count * 2;
    my $item_name=$self->_items->[$COUNT2];			# name

	# clear background of menu item area


	my @background_color=@{$self->{background_color}};
	my @pos=($self->_x, $self->_y + ($count * $self->_font_height)+$vheight, $maxwidth, $self->_font_height);
 	$pos[1]+=-$vheight if ($count==0 );
 	$pos[3]+=+$vheight if ($count==0 || $count == $maxitems);
	my $rect=SDL::Rect->new( @pos);
 	my $pixelx=SDL::Video::map_RGBA ( $screen->format, @background_color,255);
 	SDL::Video::fill_rect( $screen, $rect, $pixelx);
#$vtest->();

	if ($self->selector_bar == SDL_MENUS_SELECTOR_BAR_FULL) {

	my @pos=($self->_x, $self->_y + ($count * $self->_font_height)+$vheight, $maxwidth, $self->_font_height);
	  $rect=SDL::Rect->new( @pos);
 	  if (defined $self->{select_background_color}) {
 	  @background_color = $item_name eq $self->_items->[$current] ? @{$self->{select_background_color}} : @{$self->{background_color}};
 	  }
 	}

 	$pixelx=SDL::Video::map_RGBA ( $screen->format, @background_color,255);
 	SDL::Video::fill_rect( $screen, $rect, $pixelx);
#$vtest->();


	# NOTE: x,y = top left of mouse wheel area
 	if (! $self->_mouse_get) {
	  push (@{$self->_mouse_wheel},$pos[0],$pos[0]) if (! $self->_mouse_get);
	}

	if ($self->outline) {
	  $pos[2]+=$pos[0]; $pos[3]+=$pos[1]; $pos[0]+=1; $pos[1]+=1; $pos[2]-=1; $pos[3]-=1; 
	  SDL::GFX::Primitives::rectangle_RGBA(  $screen, @pos,@MENU_ITEM_BACKGROUND_AREA, 255);
#$vtest->();
	}

        my $color = $item_name eq $self->_items->[$current] ? SDL::Color->new( @{$self->select_color}) : SDL::Color->new( @{$self->font_color} ) ;
	my $name = $item_name;

	if (defined $self->_items->[$current+SDL_MENUS_ITEMS]{active_text}) {
	  my $name2 = $item_name eq $self->_items->[$current] ? $self->_items->[$current+SDL_MENUS_ITEMS]{active_text} : $item_name ;
	  $name = $name2 if ($name2); # but not if undef or blank
	}
        my $surface = SDL::TTF::render_text_blended( $self->_font, $name, $color);

	# Align Left
	@pos = ( $hwidth+$self->_x, $self->_y+ ($count * $self->_font_height)+$vheight, $surface->w, $surface->h);
	my $align=($self->_items->[$COUNT2+SDL_MENUS_ITEMS]{align});

 	if (defined $align && $align != SDL_MENUS_ALIGN_LEFT && $align != SDL_MENUS_LOCKED_ALIGN_LEFT ) {
	    if ($align == SDL_MENUS_ALIGN_CENTER || $align == SDL_MENUS_LOCKED_ALIGN_CENTER ) {
		$pos[0] = ( $hwidth+($self->_max_width / 2) - ($surface->w /2)  +$self->_x);
	    } else {
		$pos[0] = ($hwidth+$self->_max_width-$surface->w +$self->_x);
	    }
 	}

	if ($self->selector_bar == SDL_MENUS_SELECTOR_BAR_PARTIAL) {
	  $rect=SDL::Rect->new( @pos);
	  if (defined $self->{select_background_color}) {
	    @background_color = $item_name eq $self->_items->[$current] ? @{$self->{select_background_color}} : @{$self->{background_color}};
	  }
	  my $pixelx=SDL::Video::map_RGBA ( $screen->format, @background_color,255);
	  SDL::Video::fill_rect( $screen, $rect, $pixelx);
#$vtest->();
	}

        SDL::Video::blit_surface(
                $surface, 
                SDL::Rect->new(0,0,$surface->w, $surface->h),
                $screen,
                SDL::Rect->new( @pos),
        );

	# overprint the hotkey if one exists

 	if ($self->{show_hotkeys} && defined $self->_items->[$COUNT2+SDL_MENUS_ITEMS]{'hotkeys'}) {
# 	
 	  my $keysym=${$self->_items->[$COUNT2+SDL_MENUS_ITEMS]{'hotkeys'}}[0];
# 

	  my $keysymA;
	  my $keysymB;
 	  if ($keysym >=SDLK_a && $keysym <= SDLK_z) {
 	    $keysymA = chr(($keysym - SDLK_a) + ord('A'));
 	    $keysymB = chr(($keysym - SDLK_a) + ord('a'));
	  }
	  elsif ($keysym >=SDLK_0 && $keysym <= SDLK_9) {
	      $keysymA = chr(($keysym - SDLK_0) + ord('0'));
	  }

	    my $result = -1;
	    $result = index($name, $keysymA) if ($keysymA);
	    if ($result == -1) {
		if ($keysymB) {
		  $result = index($name, $keysymB);
		  $keysymA=$keysymB;
		}
	    }

 	    if ($result != -1) {
	    my @pos=@pos;
	      if ($result != 0) {
		$name=substr($name,0,$result);
		$surface = SDL::TTF::render_text_blended( $self->_font, $name, $color);
		$pos[0]+=$surface->w;
	      }

	      my $color=SDL::Color->new( @{$self->hotkeys_color});
#	      my $color=SDL::Color->new( @YELLOW);
	      my $surface = SDL::TTF::render_text_blended( $self->_font, $keysymA, $color);
	      SDL::Video::blit_surface(
		  $surface, 
		  SDL::Rect->new(0,0,$surface->w, $surface->h),
		  $screen,
		  SDL::Rect->new( @pos),
	      );

 	    }

 	}
# 

#$vtest->();
	# ### Adjust @pos to become absolute mouse cords

 	$pos[2]+=$pos[0]; $pos[3]+=$pos[1]; $pos[0]+=1; $pos[1]+=1; $pos[2]-=1; $pos[3]-=1; 

 	if (! $self->_mouse_get) {
 	    push (@{$self->_mouse_menu},@pos) if (! $self->_mouse_get);
 	}

	if ($self->outline) {
 	    SDL::GFX::Primitives::rectangle_RGBA(  $screen, @pos,@MENU_ITEM_AREA, 255);
	}

	if (defined $self->_items->[$COUNT2+SDL_MENUS_ITEMS]{state}) {

	  # clear background of state area
	  @pos=($self->_x+$maxwidth, $self->_y+ ($count * $self->_font_height)+$vheight, $max_state_width, $self->_max_state_height);
	  $pos[1]+=-$vheight if ($count==0 );
	  $pos[3]+=+$vheight if ($count==0 || $count == $maxitems);

	  my $state_rect=SDL::Rect->new( @pos);

	  my @state_background_color=@{$self->{background_color}};

	  # use user specified background_color
	  if (defined $self->_items->[$COUNT2+SDL_MENUS_ITEMS]{state_background_color}) {
	    @state_background_color=@{$self->_items->[$COUNT2+SDL_MENUS_ITEMS]{state_background_color}};
	  }

	  my $pixel=SDL::Video::map_RGBA ( $screen->format, @state_background_color,255);
	  SDL::Video::fill_rect( $screen, $state_rect, $pixel);
	  if ($self->outline) {
	    $pos[2]+=$pos[0]; $pos[3]+=$pos[1]; $pos[0]+=1; $pos[1]+=1; $pos[2]-=1; $pos[3]-=1; 
#	    SDL::GFX::Primitives::rectangle_RGBA(  $screen, @pos,@STATE_ITEM_BACKGROUND_AREA,255);
	    SDL::GFX::Primitives::rectangle_RGBA(  $screen, @pos,@STATE_ITEM_BACKGROUND_AREA,255);
#$vtest->();
	  }

	  my $separator=$self->separator;    
	  my $sw=0;

	  if ($self->separator_enable && $separator) {
	    my $separator_color=( SDL::Color->new(@{$self->separator_color}));
	    $surface = SDL::TTF::render_text_blended( $self->_font, $separator, $separator_color);

	    $sw=$surface->w;

	    @pos=($self->_x+$maxwidth, $self->_y+ ($count * $self->_font_height)+$vheight, $max_state_width, $self->_max_state_height);
	    $pos[3]+=$vheight if ($count==0);
	    my $state_rect=SDL::Rect->new( @pos);

	    if ($self->outline) {
	      SDL::GFX::Primitives::rectangle_RGBA(  $surface, 1, 1, $surface->w-1,$surface->h-1,@SEPARATOR_AREA, 255 );
#$vtest->();
	    }

	    SDL::Video::blit_surface(
		    $surface, 
		    SDL::Rect->new(0,0,$surface->w, $surface->h),
		    $screen,
		    $state_rect,
	    );
	  }


	  my @state = @{$self->_items->[$COUNT2+SDL_MENUS_ITEMS]{state}};
	  my $state=$self->_items->[$COUNT2+SDL_MENUS_ITEMS]{current};
	  $state=$state[$state];

	  # use global state color
	  my $state_color = $self->_items->[$COUNT2+SDL_MENUS_ITEMS]{state_color};

	  # but allow overiding with private color
	  if (defined $self->_items->[$COUNT2+SDL_MENUS_ITEMS]{my_color}) {
	    $state_color = $self->_items->[$COUNT2+SDL_MENUS_ITEMS]{my_color};
	  }

	  # NOTE: if state_color is not set AND color_scheme_disable==1, 
	  #       set color to white
	  $state_color||=[255,255,255];
	  $state_color=( SDL::Color->new(@{$state_color}));
	  $surface = SDL::TTF::render_text_blended( $self->_font, $state, $state_color);

	  @pos=($self->_x+$maxwidth+$sw, $self->_y+ ($count * $self->_font_height)+$vheight, $surface->w,$surface->h);
	  $state_rect=SDL::Rect->new( @pos);

	# ### Adjust @pos to become absolute mouse cords

	if (! $self->_mouse_get) {
	    $pos[2]+=$pos[0]; $pos[3]+=$pos[1]; $pos[0]+=1; $pos[1]+=1; $pos[2]-=1; $pos[3]-=1; 
#	    SDL::GFX::Primitives::rectangle_RGBA(  $screen, @pos,@STATE_ITEM_AREA, 255);
	    push (@{$self->_mouse_state},@pos) if (! $self->_mouse_get);
#$vtest->();
	}

	  if ($self->outline) {
	    SDL::GFX::Primitives::rectangle_RGBA(  $surface, 1, 1, $surface->w-1,$surface->h-1,@STATE_ITEM_AREA, 255 );
#	    SDL::GFX::Primitives::rectangle_RGBA(  $screen, @pos,@STATE_ITEM_AREA, 255);
#$vtest->();
	  }

	  SDL::Video::blit_surface(
		  $surface, 
		  SDL::Rect->new(0,0,$surface->w, $surface->h),
		  $screen,
		  $state_rect,
	  );

	} else {

	# nothing here, so make sure we don't match anything
	push (@{$self->_mouse_state},-1,-1,-1,-1) if (! $self->_mouse_get);

	# For menu options with no state, fill wthe the background_color color

	  @pos=($self->_x+$maxwidth, $self->_y+ ($count * $self->_font_height)+$vheight, $max_state_width, $self->_max_state_height);
	  $pos[1]+=-$vheight if ($count==0 );
	  $pos[3]+=+$vheight if ($count==0 || $count == $maxitems);

	  my $state_rect=SDL::Rect->new( @pos);

	  my @state_background_color=@{$self->{background_color}};

	  # use user specified background_color
	  if (defined $self->_items->[$COUNT2+SDL_MENUS_ITEMS]{state_background_color}) {
	    @state_background_color=@{$self->_items->[$COUNT2+SDL_MENUS_ITEMS]{state_background_color}};
	  }

	  my $pixel=SDL::Video::map_RGBA ( $screen->format, @state_background_color,255);
	  SDL::Video::fill_rect( $screen, $state_rect, $pixel);

	  if ($self->outline) {
	    $pos[2]+=$pos[0]; $pos[3]+=$pos[1]; $pos[0]+=1; $pos[1]+=1; $pos[2]-=1; $pos[3]-=1; 
	    SDL::GFX::Primitives::rectangle_RGBA(  $screen, @pos,@STATE_ITEM_BACKGROUND_BLANK_AREA, 255);
#$vtest->();
	  }

	}
#SDL::Video::update_rect( $screen, 0,0,0,0);
	$count++;
    }

    # NOTE: Calculate the mouse wheel position

    my @pos=($self->_x, $self->_y,$maxwidth, $count * $self->_font_height +($vheight * 2));
    $pos[2]+=$pos[0]; $pos[3]+=$pos[1]; $pos[0]+=1; $pos[1]+=1; $pos[2]-=1; $pos[3]-=1; 

    if (! $self->_mouse_get) {
      $self->{_mouse_wheel}=[@pos];
    }

    if ($self->outline) {
      $pos[0]+=2; $pos[1]+=2; $pos[2]-=2; $pos[3]-=2; 
      SDL::GFX::Primitives::rectangle_RGBA(  $screen, @pos,@MOUSE_WHEEL_AREA, 255);
#$vtest->();
    }

      $self->{_mouse_get}++;					# mouse update complete

      # Next fillin the unused area

     if ($count < ($self->_max_lines - $self->title_lines - $self->help_lines)) {
      my $count2=(($self->_max_lines - $self->title_lines - $count ) - $self->help_lines) -1;

 	  my @pos=($self->_x, $self->_y+ ($count * $self->_font_height)+($vheight*2), $maxwidth+$max_state_width, $self->_max_state_height+ ($count2 * $self->_font_height)-($vheight * 2));
 	  my $state_rect=SDL::Rect->new( @pos);
 	  my @background_color=@{$self->{background_color}};
 	  my $pixel=SDL::Video::map_RGBA ( $screen->format, @background_color,255);
 	  SDL::Video::fill_rect( $screen, $state_rect, $pixel);
 	  if ($self->outline) {
 	    $pos[2]+=$pos[0]; $pos[3]+=$pos[1]; $pos[0]+=1; $pos[1]+=1; $pos[2]-=1; $pos[3]-=1; 
 	    SDL::GFX::Primitives::rectangle_RGBA(  $screen, @pos,@UNUSED_AREA, 255);
#$vtest->();
 	  }
      $count+=$count2;
     }

      # Next fillin the help line
      # fill help background color

      if ($self->help_lines) {

 	  @pos=($self->_x, $self->_y+ ($count * $self->_font_height)+($vheight*2), $maxwidth+$max_state_width, $self->_max_state_height+ ($self->help_lines * $self->_font_height) - ($vheight * 2));
 	  my $state_rect=SDL::Rect->new( @pos);
 	  my @help_background_color=@{$self->{help_background_color}};
 	  my $pixel=SDL::Video::map_RGBA ( $screen->format, @help_background_color,255);
 	  SDL::Video::fill_rect( $screen, $state_rect, $pixel);

 	  if ($self->outline) {
 	    $pos[2]+=$pos[0]; $pos[3]+=$pos[1]; $pos[0]+=1; $pos[1]+=1; $pos[2]-=1; $pos[3]-=1; 
 	    SDL::GFX::Primitives::rectangle_RGBA(  $screen, @pos,@HELP_AREA_BACKGROUND, 255);
#$vtest->();
	  }
      }

      if (defined $self->_items->[$current+SDL_MENUS_ITEMS]{help} && $self->help_show && $self->help_lines) {
	$count++;

	my $help = $self->_items->[$current+SDL_MENUS_ITEMS]{help};

	my $help_color =  SDL::Color->new( @{$self->help_color} ) ;

  	my $maxchars=int($self->w - (($self->_border_width + $self->_border_padding_width) * 2) / $self->_font_thin_width);
  	my $textmax=int($self->w - (($self->_border_width + $self->_border_padding_width) * 2));

	my $newmax=$maxchars;

      my @strings;

      if (ref $help eq 'SCALAR') {
	$help=$$help;
      }

      my @help=split ("\n",$help);

      while (@help) {

	if ($self->help_lines_format) {
	  @help = split /\n/, Text::Wrap::fill( '', '', @help);
	}

	$Text::Wrap::columns = $newmax +1;
	$Text::Wrap::unexpand = 0;		# no tabs in result
	my @test;
	@test = split /\n/, Text::Wrap::fill( '', '', $help[0]);

	my $text=shift(@test);
	$text = '' unless (defined $text);
	my ($width, $height) = @{ SDL::TTF::size_text( $self->_font, $text) };# if ($text);	# ie blank lines

	if ($width <= $textmax) {
	  push (@strings,$text);
	  shift (@help);
	  unshift (@help,@test);
	  $newmax=$maxchars;
	} else {
	$newmax--;
	}
      }

	if (@strings > $self->help_lines) {
	  @strings=splice (@strings,0,$self->help_lines)
	}

	my $textlines=scalar @strings;

	my $valign=$self->help_valign;
	my $y=$self->_y + ($count * $self->_font_height);

	if ($valign == SDL_MENUS_ALIGN_BOTTOM) {
	$y+=(($self->help_lines) * $self->_font_height) - $textlines * $self->_font_height;
	} 

  	elsif ($valign == SDL_MENUS_ALIGN_MIDDLE) {
	$y+=(($self->help_lines-$textlines) * $self->_font_height)/2;
  	}

	my @pos = ( $self->_x, $y);

      for ( 1 .. $textlines) {

	$help=shift (@strings);
	unless ($help) {
	  $pos[1]+=$self->_font_height;
	  next;
    	}

	my $surface = SDL::TTF::render_text_blended( $self->_font, $help, $help_color);
	$pos[2]=$surface->w;
	$pos[3]=$surface->h;

	my $align=$self->help_align;

	  if ($align != SDL_MENUS_ALIGN_LEFT) {
	      if ($align == SDL_MENUS_ALIGN_CENTER) {
		    $pos[0] = (($maxwidth + $max_state_width) / 2) - ($surface->w /2)  + $self->_x;
	      } else {
		    $pos[0] = (($maxwidth + $max_state_width) - $surface->w + $self->_x);
	      }
	  }

	  if ($self->outline) {
	    my @pos=@pos;
	    $pos[2]+=$pos[0]; $pos[3]+=$pos[1]; $pos[0]+=1; $pos[1]+=1; $pos[2]-=1; $pos[3]-=1; 
	    SDL::GFX::Primitives::rectangle_RGBA(  $screen, @pos,@HELP_AREA, 255);
#	    SDL::GFX::Primitives::rectangle_RGBA(  $surface, 2, 2, $surface->w-2,$surface->h-2,0,255,255, 255 );
#$vtest->();
	  }

	SDL::Video::blit_surface(
		  $surface, 
		  SDL::Rect->new(0,0,$surface->w, $surface->h),
		  $screen,
		  SDL::Rect->new(@pos),
	);

      $pos[1]+=$self->_font_height;
      }

	}

}
# ==============================================================
1;
__END__

=head1 ABSTRACT

Mist::Menus - create simple and complex menus for your SDL apps easily

Before going any further you should run the example menu supplied with this module, it demonstrates
visually most of the features availabling via this module, it will also motivate you to understand 
this module in more detail in order to get the best out of it.

e.g. # MistMenus

=head1 HISTORY

I spent a few days looking at various different menu type widget solutions that I could integrate with perl-sdl,
needless to say I did not find a good enough solution, but I did found SDLx::Widgit::Menu which came close to what
I wanted, but it was not complete and lacked many of the features I required. 

Menus is basically a complete re-write of SDLx::Widgit::Menu.


=head1 SYNOPSIS

Create simple or complex SDL menus for your games and applications:

  my $menu=Menus->new($MenuControl,@MenuList);

$MenuControl includes your specified maximum width, the menu object returned by Menus->new will fit within that width,
it may be a few pixels smaller, but will not be bigger.

The menu height is dictated by the number of menu items you have as well as other options you enable.

$menu->w and $menu->h contained the actual menu dimentions that will be used, you can then centre this on your surface by providing
x,y offsets to the set_menu method as show below.

  SDL::init(SDL_INIT_VIDEO);
  my $display = SDL::Video::set_video_mode( $menu->w+100, $menu->h+100, 32, SDL_SWSURFACE|SDL_VIDEORESIZE);

  $menu->set_menu('Main Menu',50,50);

The set_menu method includes the initial menu name (e.g. 'Main Menu') to activate and x,y offsets into your window surface that the menu should be displayed.

To render the menu, simply call the render method with your surface name e.g.

  $status=$menu->render( $display );

You should render an initial display before entering your event loop, because the event_hook method returns status 0 which indicates
that nothing has changed in the menu and therefore you should not waste CPU by re-rednering the same menu, or 1 which indicates
something has changed and you should re-render to see the latest update.

  my $status=$menu->event_hook( $event );

  e.g.

  my $event = SDL::Event->new;                                          # create a new event
  SDL::Events::pump_events();
  SDL::Events::enable_key_repeat( 100,100,);				# delay,interval

  $menu->render( $display );
  SDL::Video::update_rect( $display, 0,0,0,0);

  while (1) {

    if (SDL::Events::poll_event( $event)) {
	  my $type = $event->type();                                    # get event type
	  if ($type == SDL_QUIT) {
	    exit;
	  } else {

	  my $status=$menu->event_hook( $event );
	    if ($status) {
	      $menu->render( $display );
	      SDL::Video::update_rect( $display, 0,0,0,0);
	    } else {
	      # pass $event to something else
	    }
	  }
      } else {
	sleep .05;		# small sleep, requires 'use Time::HiRes qw( sleep )';
      }
  }


=head1 DESCRIPTION

Menus provides a complete comprehensive menu system that is simple to configure and very easy to use.

Menus manages font sizes automatically for you, so you never have to specify a font size, 
this is really handy, because your menus will scale from around 50x50 upto whatever you want,
and you will not have to worry about any scaling details and regardless of the size, your menus
will always look identical

There is no menu 'structure', hierarchy or menu 'stack', menus can contain options that lead to other menus in any order you like,
 you just  need to make it seem logical for the user.

The following a list of features provided:

=item * Main Menu title (can be turned off)

You can align horzontally (center, left or right) and vertically (top, middle and bottom)

The width/height of the title is expressed in 'characters' not pixels/points.

=item * Border  (can be turned off)

The menu can have a border, the width/height of the border is expressed in 'characters' and not pixels/points because that would not scale.
e.g. 1 = 1 character width, .5 = half character width, .1 = 1/10th, etc.. this ensures that regardless of the menu size,
 reletivly it will look the same.

=item * Border Padding  (can be turned off)

This is much the same as Border, but is padding that sits inside the border boundary, width/height of the border is expressed in 'characters'.

=item * Vertical and Horzontal spacing  (can be turned off)

This is spacing (again expressin in chars or fractions of chars) that sits and acts a a boundary inside the border padding, the idea
 is that you don't want you menu items flush against the side of the border or border padding.

=item * Full mouse support

You can control most aspects of the menus using just the mouse, this includes using the mouse wheel.

=item * Full keyboard support

You can control all aspects of the menus using just the keyboard.

=item * Hotkey support  (can be turned off)

you can tag menu item with SDLK_xxx keys, and when pressed, the menu bar will move to that item, if already on that item_name
the item will be selected/activated.

=item * Help area  (can be turned off)

The bottom area of the menu can be used to display help to the user, the help area can be anywhere from 1 line to whatever you
you require, but this is usually 1 or lines only. You help text will automatically will redendered using inteligent multiline
 rendering so you dont have to worry about positioning text. You can also align the help vertically and horzontally.

=item * ourlines  (can be turned off)

This is a debugging feature so you can see what is renderred,

=item * separator  (can be turned off)

The separator is a character or string that can be displayed to the right of your menu items such as an equal sign " = "

=item * center spacer  (can be turned off)

The center spacer is a number if spaces that can be used to 'push' the right hand side of the menu further to the right and aids
the menu layout, but you can disable this if you want.

=item * selector bar (can be turned off)

The selector bar is a long cursor bar, it may extend the full width of the menus or include only the menu item text or it may
be turned off.

=item * Alternative Menu Item text (usually turned off)

When a menu item is highlighed, it can display alternative text for example 'Advanced Options' could be shown as '-->Advanced Options<--'
when the cursor moved over it.

=item * Font Style

You cannot specify font size, but you can specify font style for Titles and menu items such as normal, bold, italic etc.

=item * Font hinting

Font hinting can also be specified for the Titles and menu items.

=item Colour Scheme Generator

Colours are applied to every attribute of the menus using the built in the colour scheme generator.

To understand the colour scheme in more detail, please see: http://search.cpan.org/~ian/Color-Scheme-1.02/
and http://colorschemedesigner.com/

=head1 METHODS

=head2 new

TODO.

=head1 AUTHORS

Albert Graham C<< <albert.graham at gmail.com> >>

Credit should also go to all the authors perl-SDL and specifically SDLx::Widgit::Menu as many ideas
and princples 're-used' - thanks guys.

    Breno G. de Oliveira, C<< <garu at cpan.org> >>
    Kartik thakore C<< <kthakore at cpan.org> >>

=head1 SEE ALSO

L<< SDL >>, L <<SDLx::Widgit::Menu>>, L<< SDLx::App >>, L<< SDLx::Controller >>


