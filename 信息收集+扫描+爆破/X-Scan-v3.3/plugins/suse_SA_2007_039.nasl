#
# (C) Tenable Network Security
#
# This plugin text was extracted from SuSE Security Advisory SUSE-SA:2007:039
#


if ( ! defined_func("bn_random") ) exit(0);

include("compat.inc");

if(description)
{
 script_id(26173);
 script_version ("$Revision: 1.4 $");
 
 name["english"] = "SUSE-SA:2007:039: libexif";
 
 script_name(english:name["english"]);
 
 script_set_attribute(attribute:"synopsis", value:
"The remote host is missing a vendor-supplied security patch" );
 script_set_attribute(attribute:"description", value:
"The remote host is missing the patch for the advisory SUSE-SA:2007:039 (libexif)." );
 script_set_attribute(attribute:"solution", value:
"http://www.novell.com/linux/security/advisories/2007_39_libexif.html" );
 script_set_attribute(attribute:"risk_factor", value:"High" );



 script_end_attributes();

 
 summary["english"] = "Check for the version of the libexif package";
 script_summary(english:summary["english"]);
 
 script_category(ACT_GATHER_INFO);
 
 script_copyright(english:"This script is Copyright (C) 2007 Tenable Network Security");
 family["english"] = "SuSE Local Security Checks";
 script_family(english:family["english"]);
 
 script_dependencies("ssh_get_info.nasl");
 script_require_keys("Host/SuSE/rpm-list");
 exit(0);
}

include("rpm.inc");
if ( rpm_check( reference:"libexif-0.6.13-5.6", release:"SUSE10.0") )
{
 security_hole(0);
 exit(0);
}
if ( rpm_check( reference:"libexif5-0.5.12-5.3", release:"SUSE10.0") )
{
 security_hole(0);
 exit(0);
}
