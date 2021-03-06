#
# (C) Tenable Network Security, Inc.
#


include("compat.inc");


if (description)
{
  script_id(38911);
  script_version("$Revision: 1.3 $");

  script_cve_id("CVE-2009-1484");
  script_bugtraq_id(34716);
  script_xref(name:"OSVDB", value:"54091");
  script_xref(name:"Secunia", value:"34402");
  script_xref(name:"Secunia", value:"34958");

  script_name(english:"AXIGEN Webmail < 7.1.0 HTML Body Script Insertion");
  script_summary(english:"Checks AXIGEN Webmail version");
 
  script_set_attribute(
    attribute:"synopsis",
    value:string(
      "The remote webmail service is affected by a cross-site scripting\n",
      "vulnerability."
    )
  );
  script_set_attribute(
    attribute:"description", 
    value:string(
      "The version of AXIGEN Webmail running on the remote host is earlier\n",
      "than 7.1.0.  Such versions fail to fully sanitize text in the body of\n",
      "e-mail messages.  If an attacker can trick a user into opening a \n",
      "specially crafted message using the affected webmail application, he\n",
      "can leverage this issue to inject malicious HTML and script code into\n",
      "the user's browser, to be executed within the security context of the\n",
      "affected site."
    )
  );
  script_set_attribute(
    attribute:"see_also", 
    value:"http://www.axigen.com/forum/showthread.php?t=5998"
  );
  script_set_attribute(
    attribute:"solution", 
    value:"Upgrade to AXIGEN version 7.1.0 or later."
  );
  script_set_attribute(
    attribute:"cvss_vector", 
    value:"CVSS2#AV:N/AC:M/Au:N/C:N/I:P/A:N"
  );
  script_end_attributes();
 
  script_category(ACT_GATHER_INFO);
  script_family(english:"CGI abuses : XSS");
 
  script_copyright(english:"This script is Copyright (C) 2009 Tenable Network Security, Inc.");

  script_dependencies("http_version.nasl");
  script_require_ports("Services/www", 8000);

  exit(0);
}


include("global_settings.inc");
include("misc_func.inc");
include("http.inc");


port = get_http_port(default:8000, embedded:TRUE);


# Unless we're paranoid, make sure the banner is from AXIGEN's Webmail service.
if (report_paranoia < 2)
{
  banner = get_http_banner(port:port);
  if (!banner || "Server: Axigen-Webmail" >!< banner) exit(0);
}


# Get the version from the login page.
url = "/?login=";
res = http_send_recv3(method:"GET", item:url, port:port);
if (isnull(res)) exit(0);

if ("<title>AXIGEN Webmail - v" >< res[2])
{
  foreach line (split(res[2], keep:FALSE))
  {
    if ("<title>AXIGEN Webmail - v" >< line && "</title>" >< line)
    {
      version = strstr(line, "<title>AXIGEN Webmail - v") - "<title>AXIGEN Webmail - v";
      version = version - strstr(version, "</title>");

      # There's a problem if the version is before 7.1.0.
      if (version =~ "^([0-6]\.|7\.0([^0-9]|$))")
      {
        set_kb_item(name:'www/'+port+'/XSS', value:TRUE);

        if (report_verbosity > 0)
        {
          report = string(
            "\n",
            "AXIGEN Webmail version ", version, " appears to be running on the remote host\n",
            "based on the following title on the initial login page :\n",
            "\n",
            "  ", line, "\n"
          );
          security_warning(port:port, extra:report);
        }
        else security_warning(port);
      }
    }
  }
}
