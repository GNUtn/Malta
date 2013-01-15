package ReportGenerator;
use Moose::Role;

requires
  qw(parse_values get_entry new_entry get_flattened_data get_lowest 
  	 post_process write_report);

1;