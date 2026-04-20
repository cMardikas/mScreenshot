<?xml version="1.0" encoding="utf-8"?>
<!--
mScreenshot // Nmap Bootstrap XSL
Dark terminal/hacker aesthetic reskin
Based on original by Andreas Hontzia (@honze_net) & LRVT (@l4rm4nd)
This software must not be used by military or secret service organisations.
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html" encoding="utf-8" indent="yes" doctype-system="about:legacy-compat"/>
  <xsl:template match="/">
    <html lang="en">
      <head>
        <meta name="referrer" content="no-referrer"/> 
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous"/>
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap-theme.min.css" integrity="sha384-rHyoN1iRsVXV4nD0JutlnGaslCJuC7uwjduW9SVrLvRYooPp2bWYgmgJQIXwl/Sp" crossorigin="anonymous"/>
        <link rel="stylesheet" href="https://cdn.datatables.net/buttons/2.0.1/css/buttons.dataTables.min.css" integrity="sha384-0OeHd2TJxoSDnW9bOIukOL7+BcfI6b17OHv54+JWrUbWq7ABgBO0rjW3OinB5vbG" crossorigin="anonymous"/>
        <link rel="stylesheet" href="https://cdn.datatables.net/1.10.19/css/dataTables.bootstrap.min.css" type="text/css" integrity="sha384-VEpVDzPR2x8NbTDZ8NFW4AWbtT2g/ollEzX/daZdW/YvUBlbgVtsxMftnJ84k0Cn" crossorigin="anonymous"/>

        <script src="https://code.jquery.com/jquery-3.3.1.js" integrity="sha384-fJU6sGmyn07b+uD1nMk7/iSb4yvaowcueiQhfVgQuD98rfva8mcr1eSvjchfpMrH" crossorigin="anonymous"></script>
        <script src="https://cdn.datatables.net/1.10.19/js/jquery.dataTables.min.js" integrity="sha384-rgWRqC0OFPisxlUvl332tiM/qmaNxnlY46eksSZD84t+s2vZlqGeHrncwIRX7CGp" crossorigin="anonymous"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/jszip/3.1.3/jszip.min.js" integrity="sha384-v9EFJbsxLXyYar8TvBV8zu5USBoaOC+ZB57GzCmQiWfgDIjS+wANZMP5gjwMLwGv" crossorigin="anonymous"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.1.53/pdfmake.min.js" integrity="sha384-HUHsYVOhSyHyZRTWv8zkbKVk7Xmg12CCNfKEUJ7cSuW/22Lz3BITd3Om6QeiXICb" crossorigin="anonymous"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.1.53/vfs_fonts.js" integrity="sha384-UAA3vlTPq9dwxB61awBFhR7Y5uBFOKQWuZueu4C6uI48gjIoqI/OTmYWEYWZXbGR" crossorigin="anonymous"></script>
        <script src="https://cdn.datatables.net/buttons/2.0.1/js/dataTables.buttons.min.js" integrity="sha384-MGimb05YiSGNcXiLlj03UNahXBECHmFTe5iVBqh6sf2G7ccabI3/EOqzBnNw97/T" crossorigin="anonymous"></script>
        <script src="https://cdn.datatables.net/buttons/2.0.1/js/buttons.html5.min.js" integrity="sha384-pp2ArcKo71umWphZ7QCCjQbnICkbOkLF88ZeoeZDPbqdAVvxZlcrla3lyT7pY/ue" crossorigin="anonymous"></script>
        <script src="https://cdn.datatables.net/buttons/2.0.1/js/buttons.colVis.min.js" integrity="sha384-enGTgEZOvC7C8P91Jt/27n1V3xD5SIzGi1e+DzYJvAts546YTsj3CNmnL0G/zlVn" crossorigin="anonymous"></script>
        <script src="https://cdn.datatables.net/buttons/2.0.1/js/buttons.bootstrap.min.js" integrity="sha384-Ndtz/aMKkdc9b0uTCirKXA6kJ8QfBTv73Ph9sv0wOiqK7NENdLN+qTpPX5skuhiM" crossorigin="anonymous"></script>
        <script src="https://cdn.datatables.net/1.10.19/js/dataTables.bootstrap.min.js" integrity="sha384-7PXRkl4YJnEpP8uU4ev9652TTZSxrqC8uOpcV1ftVEC7LVyLZqqDUAaq+Y+lGgr9" crossorigin="anonymous"></script>
        <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js" integrity="sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa" crossorigin="anonymous"></script>
        <script src="https://cdn.datatables.net/plug-ins/2.1.0/sorting/ip-address.js" integrity="sha384-pbrITLqgA4lSZJgcYMK/c5hfUpOg+2vjjMQPdRv4hPEoBFYVWEuF1H3faZskzO9a" crossorigin="anonymous"></script>
        <style>
/* =========================================================
   mScreenshot // Light Professional Theme
   ========================================================= */

/* --- Base --- */
*, *::before, *::after {
  box-sizing: border-box;
}

html {
  scroll-behavior: smooth;
}

body {
  background-color: #fff;
  color: #1a1a1a;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', sans-serif;
  font-size: 14px;
  line-height: 1.6;
}

/* --- Headings --- */
h1, h2, h3, h4, h5, h6 {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', sans-serif;
  color: #1a1a1a;
  font-weight: 600;
}

h2 {
  border-bottom: 1px solid #dee2e6;
  padding-bottom: 8px;
  margin-bottom: 16px;
}

h4, h5 {
  color: #374151;
}

/* --- Links --- */
a, a:visited {
  color: #2563eb;
  text-decoration: none;
}
a:hover, a:focus {
  color: #1d4ed8;
  text-decoration: underline;
}

/* --- Navbar --- */
.navbar {
  background-color: #1e293b !important;
  border-bottom: 1px solid #0f172a !important;
  box-shadow: 0 1px 4px rgba(0,0,0,0.15);
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', sans-serif;
}
.navbar-default {
  background-color: #1e293b !important;
  border-color: #0f172a !important;
}
.navbar-default .navbar-brand,
.navbar-default .navbar-nav > li > a {
  color: #f1f5f9 !important;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', sans-serif;
}
.navbar-default .navbar-brand:hover,
.navbar-default .navbar-nav > li > a:hover,
.navbar-default .navbar-nav > li > a:focus {
  color: #fff !important;
  background-color: #0f172a !important;
}
.navbar-default .navbar-nav > .active > a,
.navbar-default .navbar-nav > .active > a:hover,
.navbar-default .navbar-nav > .active > a:focus {
  color: #fff !important;
  background-color: #2563eb !important;
}
.navbar-default .navbar-toggle {
  border-color: #475569;
}
.navbar-default .navbar-toggle:hover,
.navbar-default .navbar-toggle:focus {
  background-color: #0f172a;
}
.navbar-default .navbar-toggle .icon-bar {
  background-color: #f1f5f9;
}
.navbar-default .navbar-collapse {
  border-color: #0f172a;
}

/* --- Container --- */
.container {
  background-color: transparent;
}

/* --- Jumbotron --- */
.jumbotron {
  background-color: #f1f5f9 !important;
  border: 1px solid #dee2e6;
  border-radius: 6px;
  box-shadow: 0 1px 4px rgba(0,0,0,0.06);
  color: #1a1a1a;
  padding: 28px 32px 32px 32px !important;
  margin-top: 80px !important;
}
.jumbotron h2 {
  color: #1e293b;
  font-size: 26px;
  border-bottom: none;
  padding-bottom: 0;
}
.jumbotron h2 small {
  color: #6c757d;
  font-size: 14px;
}
.jumbotron .lead {
  color: #374151;
  font-size: 14px;
}
.jumbotron pre {
  background-color: #fff;
  border: 1px solid #dee2e6;
  color: #1a1a1a;
  border-radius: 4px;
  padding: 10px 14px;
  font-family: 'SFMono-Regular', Consolas, 'Liberation Mono', Menlo, monospace;
  font-size: 13px;
}
.jumbotron pre a {
  color: #2563eb;
}
.jumbotron pre a:hover {
  color: #1d4ed8;
}

/* --- Progress bar --- */
.progress {
  background-color: #e9ecef;
  border: 1px solid #dee2e6;
  border-radius: 4px;
  box-shadow: none;
  height: 22px;
}
.progress-bar-success {
  background-color: #16a34a !important;
  color: #fff !important;
  font-weight: 600;
  text-shadow: none;
  box-shadow: none;
}
.progress-bar-danger {
  background-color: #dc2626 !important;
  color: #fff !important;
  font-weight: 600;
  text-shadow: none;
  box-shadow: none;
}

/* --- Keyword highlight form --- */
#form-wrapper {
  margin-top: 16px;
}
#form-wrapper textarea {
  background-color: #fff;
  color: #1a1a1a;
  border: 1px solid #ced4da;
  border-radius: 4px;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', sans-serif;
  font-size: 13px;
  padding: 6px 10px;
  resize: vertical;
  outline: none;
  width: 100%;
}
#form-wrapper textarea:focus {
  border-color: #2563eb;
  box-shadow: 0 0 0 2px rgba(37,99,235,0.12);
}
#form-wrapper button {
  background-color: #fff;
  color: #2563eb;
  border: 1px solid #2563eb;
  border-radius: 4px;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', sans-serif;
  font-size: 13px;
  padding: 5px 14px;
  margin-right: 6px;
  cursor: pointer;
  transition: background-color 0.15s, color 0.15s;
}
#form-wrapper button:hover {
  background-color: #2563eb;
  color: #fff;
}

/* --- Section headings (anchored) --- */
.target:before {
  content: "";
  display: block;
  height: 50px;
  margin: -20px 0 0;
}

/* --- Tables --- */
.table {
  background-color: #fff;
  color: #1a1a1a;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', sans-serif;
  font-size: 13px;
  border-collapse: collapse;
}
.table > thead > tr > th {
  background-color: #f1f5f9;
  color: #374151;
  border-bottom: 2px solid #dee2e6;
  border-color: #dee2e6;
  font-size: 12px;
  font-weight: 600;
  letter-spacing: 0.03em;
  text-transform: uppercase;
  padding: 10px 12px;
}
.table > tbody > tr > td,
.table > tbody > tr > th {
  border-top: 1px solid #dee2e6;
  padding: 8px 12px;
  color: #1a1a1a;
  vertical-align: middle;
}
.table-striped > tbody > tr:nth-of-type(odd) {
  background-color: #fff;
}
.table-striped > tbody > tr:nth-of-type(even) {
  background-color: #f8f9fa;
}
.table-bordered,
.table-bordered > thead > tr > th,
.table-bordered > tbody > tr > td {
  border-color: #dee2e6 !important;
}
.table-responsive {
  border-color: #dee2e6;
  background-color: transparent;
}

/* Open port rows — light green */
.table > tbody > tr.success,
.table > tbody > tr.success > td,
.table > tbody > tr.success > th {
  background-color: #f0fdf4 !important;
  color: #14532d !important;
  border-color: #bbf7d0 !important;
}
/* Filtered rows — light amber */
.table > tbody > tr.warning,
.table > tbody > tr.warning > td {
  background-color: #fffbeb !important;
  color: #78350f !important;
  border-color: #fde68a !important;
}
/* Closed rows */
.table > tbody > tr.active,
.table > tbody > tr.active > td {
  background-color: #f8f9fa !important;
  color: #6c757d !important;
}
/* Info rows */
.table > tbody > tr.info,
.table > tbody > tr.info > td {
  background-color: #eff6ff !important;
  color: #1e3a5f !important;
  border-color: #bfdbfe !important;
}

/* --- Labels (state badges) --- */
.label {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', sans-serif;
  font-size: 11px;
  font-weight: 600;
  letter-spacing: 0.03em;
  border-radius: 3px;
  padding: 2px 7px;
}
.label-success {
  background-color: #16a34a !important;
  color: #fff !important;
}
.label-danger {
  background-color: #dc2626 !important;
  color: #fff !important;
}
.label-warning {
  background-color: #d97706 !important;
  color: #fff !important;
}

/* --- Panels (online hosts) --- */
.panel {
  background-color: #fff;
  border: 1px solid #dee2e6;
  border-radius: 6px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.06);
  margin-bottom: 12px;
}
.panel-default {
  border-color: #dee2e6;
}
.panel-default > .panel-heading {
  background-color: #f8f9fa;
  border-bottom: 1px solid #dee2e6;
  color: #1e293b;
  padding: 10px 16px;
  border-radius: 5px 5px 0 0;
  transition: background-color 0.15s;
}
.panel-default > .panel-heading:hover {
  background-color: #f1f5f9;
}
.panel-heading.collapsed {
  border-bottom-color: transparent;
  border-radius: 5px;
}
.panel-title {
  color: #1e293b;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', sans-serif;
  font-size: 14px;
  font-weight: 600;
}
.panel-body {
  background-color: #fff;
  color: #1a1a1a;
  padding: 16px;
}
.panel-heading > h3:before {
  font-family: 'Glyphicons Halflings';
  content: "\e114"; /* glyphicon-chevron-down */
  padding-right: 1em;
  color: #6c757d;
}
.panel-heading.collapsed > h3:before {
  content: "\e080"; /* glyphicon-chevron-right */
}

/* --- Collapse animation --- */
.collapse.in {
  display: block;
}

/* --- Pre / code blocks --- */
pre {
  background-color: #f8f9fa;
  border: 1px solid #dee2e6;
  color: #1a1a1a;
  font-family: 'SFMono-Regular', Consolas, 'Liberation Mono', Menlo, monospace;
  font-size: 12px;
  border-radius: 4px;
  padding: 10px 12px;
  white-space: pre-wrap;
  word-wrap: break-word;
}

/* --- Screenshot containers --- */
.resize-container {
  width: 400px;
  height: 280px;
  overflow: hidden;
  border: 1px solid #dee2e6;
  border-radius: 4px;
  box-shadow: 0 1px 4px rgba(0,0,0,0.08);
  background-color: #f8f9fa;
}
.resize-container img {
  width: 100%;
  height: 100%;
  object-fit: contain;
}

/* --- DataTables overrides --- */
.dataTables_wrapper {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', sans-serif;
  color: #1a1a1a;
}
.dataTables_wrapper .dataTables_length,
.dataTables_wrapper .dataTables_filter,
.dataTables_wrapper .dataTables_info,
.dataTables_wrapper .dataTables_paginate {
  color: #6c757d !important;
  font-size: 13px;
  margin-bottom: 6px;
}
.dataTables_wrapper .dataTables_filter input,
.dataTables_wrapper .dataTables_length select {
  background-color: #fff !important;
  color: #1a1a1a !important;
  border: 1px solid #ced4da !important;
  border-radius: 4px;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', sans-serif;
  font-size: 13px;
  padding: 4px 8px;
  outline: none;
}
.dataTables_wrapper .dataTables_filter input:focus,
.dataTables_wrapper .dataTables_length select:focus {
  border-color: #2563eb !important;
  box-shadow: 0 0 0 2px rgba(37,99,235,0.12);
}
.dataTables_wrapper .dataTables_paginate .paginate_button {
  color: #374151 !important;
  background-color: #fff !important;
  border: 1px solid #dee2e6 !important;
  border-radius: 4px;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', sans-serif;
  font-size: 13px;
}
.dataTables_wrapper .dataTables_paginate .paginate_button:hover {
  background-color: #f1f5f9 !important;
  color: #1a1a1a !important;
  border-color: #adb5bd !important;
}
.dataTables_wrapper .dataTables_paginate .paginate_button.current,
.dataTables_wrapper .dataTables_paginate .paginate_button.current:hover {
  background-color: #2563eb !important;
  color: #fff !important;
  border-color: #2563eb !important;
  box-shadow: none;
}
.dataTables_wrapper .dataTables_paginate .paginate_button.disabled,
.dataTables_wrapper .dataTables_paginate .paginate_button.disabled:hover {
  color: #adb5bd !important;
}

/* --- Export buttons (DataTables Buttons plugin) --- */
.dt-buttons .dt-button,
.dt-buttons .dt-button:visited {
  background-color: #fff !important;
  background-image: none !important;
  color: #374151 !important;
  border: 1px solid #ced4da !important;
  border-radius: 4px !important;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', sans-serif !important;
  font-size: 12px !important;
  padding: 5px 12px !important;
  margin-right: 4px !important;
  box-shadow: none !important;
  text-shadow: none !important;
  transition: background-color 0.15s, border-color 0.15s;
}
.dt-buttons .dt-button:hover,
.dt-buttons .dt-button:focus,
.dt-buttons .dt-button:active {
  background-color: #f1f5f9 !important;
  color: #1a1a1a !important;
  border-color: #adb5bd !important;
  box-shadow: none !important;
  outline: none !important;
}
div.dt-buttons {
  float: left;
  margin-bottom: 6px;
}

/* --- Keyword highlight color --- */
span[style*="color: red"] {
  color: #dc2626 !important;
  background-color: #fef2f2;
  border-radius: 2px;
  padding: 0 2px;
}

/* --- Wide screen --- */
@media only screen and (min-width: 1900px) {
  .container {
    width: 1800px;
  }
}

/* --- Footer --- */
.footer {
  margin-top: 60px;
  padding-top: 30px;
  padding-bottom: 20px;
  width: 100%;
  min-height: 80px;
  background-color: #f8f9fa;
  border-top: 1px solid #dee2e6;
  color: #6c757d;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', sans-serif;
  font-size: 12px;
  text-align: center;
}

/* --- Clickable cursor --- */
.clickable {
  cursor: pointer;
}

/* --- Italic text (cert info, titles) --- */
i {
  color: #6c757d;
}

/* --- Misc Bootstrap overrides --- */
.well {
  background-color: #f8f9fa;
  border-color: #dee2e6;
  color: #1a1a1a;
  box-shadow: none;
}
.btn-default {
  background-color: #fff;
  color: #374151;
  border-color: #ced4da;
}
.btn-default:hover {
  background-color: #f1f5f9;
  color: #1a1a1a;
  border-color: #adb5bd;
}
        </style>
        <title>mScreenshot // Scan Report</title>
      </head>
      <body>
        <script>
          function highlight(){
              $("#table-services").dataTable().fnDestroy()
              let keywords = document.getElementById('keyword-input').value.split(',');
              let content = document.getElementById('table-services').innerHTML;
              document.getElementById('table-services').innerHTML = transformContent(content, keywords)
              $('#table-services').DataTable( {
              "lengthMenu": [ [10, 25, 50, 100, -1], [10, 25, 50, 100, "All"] ],
	      "pageLength": -1,
              "order": [[ 0, 'desc' ]],
              "columnDefs": [
                { "targets": [0], "orderable": true },
              ],
              dom:'lBfrtip', 
              stateSave: true,
              buttons: [
                  {
                      extend: 'copyHtml5',
                      exportOptions: { orthogonal: 'export' }
                  },
                  {
                      extend: 'csvHtml5',
                      exportOptions: { orthogonal: 'export' }
                  },
                  {
                      extend: 'excelHtml5',
                      exportOptions: { orthogonal: 'export' },
                      autoFilter: true,
                      title: '',
                  },
                  {
                      extend: 'pdfHtml5',
                      exportOptions: { orthogonal: 'export' },
                      orientation: 'landscape',
                      pageSize: 'LEGAL',
                      download: 'open',
                      exportOptions: {
                      columns: [ 0,1,2,3,4,5,6,7,8 ]
                }
                  }
              ],
            });
          }

          function transformContent(content, keywords){
            let temp = content

            keywords.forEach(keyword => {
              temp = temp.replace(new RegExp(keyword, 'ig'), wrapKeywordWithHTML(keyword, keyword))
            })

            return temp
          }

          function wrapKeywordWithHTML(keyword, url){
            return `&lt;span style="color: red;"&gt;${keyword}&lt;/span&gt;`
          }
        </script>
        <nav class="navbar navbar-default navbar-fixed-top">
          <div class="container-fluid">
            <div class="navbar-header">
              <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#bs-example-navbar-collapse-1" aria-expanded="false">
                <span class="sr-only">Toggle navigation</span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
              </button>
              <a class="navbar-brand" href="#"><span class="glyphicon glyphicon-home"></span></a>
            </div>
            <div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
              <ul class="nav navbar-nav">
                <li><a href="#scannedhosts">Scanned Hosts</a></li>
                <li><a href="#openservices">Open Services</a></li>
                <li><a href="#webservices">Web Services</a></li>
                <li><a href="#onlinehosts">Online Hosts</a></li>
              </ul>
            </div>
          </div>
        </nav>
        <div class="container" style="width: 94%">
          <div class="jumbotron" style="margin-top: 80px; padding-top: 5px; padding-bottom: 30px; padding-left: 30px; padding-right: 30px">
            <h2>mScreenshot // Scan Report</h2>
            <h2><small>Nmap Version <xsl:value-of select="/nmaprun/@version"/>
            <br/><xsl:value-of select="/nmaprun/@startstr"/> – <xsl:value-of select="/nmaprun/runstats/finished/@timestr"/></small></h2>
            <pre style="white-space:pre-wrap; word-wrap:break-word;"><a target="_blank"><xsl:attribute name="href">https://explainshell.com/explain?cmd=<xsl:value-of select="/nmaprun/@args"/></xsl:attribute><xsl:value-of select="/nmaprun/@args"/></a></pre>
            <p class="lead">
              <xsl:value-of select="/nmaprun/runstats/hosts/@total"/> hosts scanned.
              <xsl:value-of select="/nmaprun/runstats/hosts/@up"/> hosts up.
              <xsl:value-of select="/nmaprun/runstats/hosts/@down"/> hosts down.
            </p>
            <div class="progress">
              <div class="progress-bar progress-bar-success" style="width: 0%">
                <xsl:attribute name="style">width:<xsl:value-of select="/nmaprun/runstats/hosts/@up div /nmaprun/runstats/hosts/@total * 100"/>%;</xsl:attribute>
                <xsl:value-of select="/nmaprun/runstats/hosts/@up"/>
                <span class="sr-only"></span>
              </div>
              <div class="progress-bar progress-bar-danger" style="width: 0%">
                <xsl:attribute name="style">width:<xsl:value-of select="/nmaprun/runstats/hosts/@down div /nmaprun/runstats/hosts/@total * 100"/>%;</xsl:attribute>
                <xsl:value-of select="/nmaprun/runstats/hosts/@down"/>
                <span class="sr-only"></span>
              </div>
              </div>
              <div id="form-wrapper">
                <div>
                    <textarea style="width: 100%;" title="Insert comma separated keywords to be highlighted" rows = "1" name = "keywords" placeholder="sha1,password,..." id="keyword-input">sha1,login,password,md5</textarea>
                </div>
                <div style="margin-top: 2px">
                    <button title="Keyword highlighing in 'Open Services'" id="highlight-button" onclick="highlight()">Highlight Keywords</button>
                    <button title="Reset keyword highlighing" id="reset-highlight-button" onclick="document.location.reload(true);">Reset</button>
                </div>
            </div>
          </div>
          <h2 id="scannedhosts" class="target">Scanned Hosts<xsl:if test="/nmaprun/runstats/hosts/@down > 0"><small> (offline hosts are hidden)</small></xsl:if></h2>
          <div class="table-responsive">
            <table id="table-overview" class="table table-striped dataTable" role="grid">
              <thead>
                <tr>
                  <th>State</th>
                  <th>Address</th>
                  <th>Hostname</th>
                  <th>TCP (open)</th>
                  <th>UDP (open)</th>
                </tr>
              </thead>
              <tbody>
                <xsl:choose>
                  <xsl:when test="/nmaprun/runstats/hosts/@down > 0">
                    <xsl:for-each select="/nmaprun/host[status/@state='up']">
                      <tr>
                        <td><span class="label label-danger"><xsl:if test="status/@state='up'"><xsl:attribute name="class">label label-success</xsl:attribute></xsl:if><xsl:value-of select="status/@state"/></span></td>
                        <td><a><xsl:attribute name="href">#onlinehosts-<xsl:value-of select="translate(address/@addr, '.', '-')"/></xsl:attribute><xsl:value-of select="address/@addr"/></a></td>
                        <td><xsl:value-of select="hostnames/hostname/@name"/></td>
                        <td><xsl:value-of select="count(ports/port[state/@state='open' and @protocol='tcp'])"/></td>
                        <td><xsl:value-of select="count(ports/port[state/@state='open' and @protocol='udp'])"/></td>
                      </tr>
                    </xsl:for-each>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:for-each select="/nmaprun/host">
                      <tr>
                        <td><span class="label label-danger"><xsl:if test="status/@state='up'"><xsl:attribute name="class">label label-success</xsl:attribute></xsl:if><xsl:value-of select="status/@state"/></span></td>
                        <td><a><xsl:attribute name="href">#onlinehosts-<xsl:value-of select="translate(address/@addr, '.', '-')"/></xsl:attribute><xsl:value-of select="address/@addr"/></a></td>
                        <td><xsl:value-of select="hostnames/hostname/@name"/></td>
                        <td><xsl:value-of select="count(ports/port[state/@state='open' and @protocol='tcp'])"/></td>
                        <td><xsl:value-of select="count(ports/port[state/@state='open' and @protocol='udp'])"/></td>
                      </tr>
                    </xsl:for-each>
                  </xsl:otherwise>
                </xsl:choose>
              </tbody>
            </table>
          </div>
          <h2 id="openservices" class="target">Open Services</h2>
          <div class="table-responsive">
            <table id="table-services" class="table table-striped dataTable" role="grid">
              <thead >
                <tr>
                  <!--<th title="Temporary Checkbox"></th>-->
                  <th>Hostname</th>
                  <th>Address</th>
                  <th>Port</th>
                  <th>Protocol</th>
                  <th>Service</th>
                  <th>Product</th>
                  <th>Version</th>
                  <th>Extra</th>
                  <th>SSL Certificate</th>
                  <th title="Title of HTTP services">Title</th>
                  <th>CPE</th>
                </tr>
              </thead>
              <tbody>
                <xsl:for-each select="/nmaprun/host">
                  <xsl:for-each select="ports/port[state/@state='open']">
                    <tr>
                      <!--<td><input name="select_all" value="1" type="checkbox"></input></td>-->
                      <td>
                      <xsl:if test="count(../../hostnames/hostname) = 0">N/A</xsl:if>
                      <xsl:if test="count(../../hostnames/hostname) > 0"><xsl:value-of select="../../hostnames/hostname/@name"/></xsl:if></td>
                      <td><a>
                      <xsl:attribute name="href">#onlinehosts-<xsl:value-of select="translate(../../address/@addr, '.', '-')"/></xsl:attribute><xsl:value-of select="../../address/@addr"/></a></td>
                      
                      <td><a>
                      <xsl:attribute name="href">#port-<xsl:value-of select="translate(../../address/@addr, '.', '-')"/>-<xsl:value-of select="@portid"/></xsl:attribute><xsl:value-of select="@portid"/></a></td>
                      <td><xsl:value-of select="@protocol"/></td>
                      <td><xsl:if test="count(service/@tunnel) > 0"><xsl:value-of select="service/@tunnel"/>/</xsl:if><xsl:value-of select="service/@name"/></td>
                      <td><xsl:value-of select="service/@product"/></td>
                      <td><xsl:value-of select="service/@version"/></td>
                      <td><xsl:value-of select="service/@extrainfo"/></td>
                      <td>
                        <xsl:if test="count(script/table[@key='subject']/elem[@key='commonName']) > 0">CN: <i><xsl:value-of select="script/table[@key='subject']/elem[@key='commonName']"/></i></xsl:if>
                        <xsl:if test="count(script/table[@key='validity']/elem[@key='notAfter']) > 0"><br/>Expiry: <i><xsl:value-of select="script/table[@key='validity']/elem[@key='notAfter']"/></i></xsl:if>
                        <xsl:if test="count(script/elem[@key='sig_algo']) > 0"><br/>SigAlgo: <i><xsl:value-of select="script/elem[@key='sig_algo']"/></i></xsl:if>
                      </td>
                      <td><xsl:choose><xsl:when test="count(script[@id='http-title']/elem[@key='title']) > 0"><i><xsl:value-of select="script[@id='http-title']/elem[@key='title']"/></i></xsl:when><xsl:otherwise><xsl:if test="count(script[@id='http-title']/@output) > 0"><i><xsl:value-of select="script[@id='http-title']/@output"/></i></xsl:if></xsl:otherwise></xsl:choose></td>
                      <td><xsl:value-of select="service/cpe"/></td>
                    </tr>
                  </xsl:for-each>
                </xsl:for-each>
              </tbody>
            </table>
          </div>

          <h2 id="webservices" class="target">Web Services</h2>
          <div class="table-responsive">
            <table id="web-services" class="table table-striped dataTable" role="grid">
              <thead >
                <tr>
                  <!--<th title="Temporary Checkbox"></th>-->
                  <th>Hostname</th>
                  <th>Address</th>
                  <th>Port</th>
                  <th>Service</th>
                  <th>Screenshot</th>
                  <th>Product</th>
                  <th>Version</th>
                  <th>Title</th>
                  <th>SSL Certificate</th>
                  <th>URL</th>
                </tr>
              </thead>
              <tbody>
                <xsl:for-each select="/nmaprun/host">
                  <xsl:for-each select="ports/port[state/@state='open' and @protocol='tcp' and (starts-with(service/@name, 'http') or script[@id='http-screenshot'])]">

                    <tr>
                      <!--<td><input name="select_all" value="5" type="checkbox"></input></td>-->
                      <td>
                      <xsl:if test="count(../../hostnames/hostname) = 0">N/A</xsl:if>
                      <xsl:if test="count(../../hostnames/hostname) > 0"><xsl:value-of select="../../hostnames/hostname/@name"/></xsl:if></td>
                      <td><a>
                      <xsl:attribute name="href">#onlinehosts-<xsl:value-of select="translate(../../address/@addr, '.', '-')"/></xsl:attribute><xsl:value-of select="../../address/@addr"/></a></td>
                      
                      <td><a>
                      <!--PORT-->
                      <xsl:attribute name="href">#port-<xsl:value-of select="translate(../../address/@addr, '.', '-')"/>-<xsl:value-of select="@portid"/></xsl:attribute><xsl:value-of select="@portid"/></a></td>
                      <!--Service-->
                      <td><xsl:if test="count(service/@tunnel) > 0"><xsl:value-of select="service/@tunnel"/>/</xsl:if><xsl:value-of select="service/@name"/></td>
<td>
<xsl:for-each select="script">
        <xsl:if test="@id='http-screenshot'">
                <div class="resize-container">
                        <a><xsl:attribute name="href">#port-<xsl:value-of select="translate(../../../address/@addr, '.', '-')"/>-<xsl:value-of select="../@portid"/></xsl:attribute><xsl:value-of select="@portid"/><xsl:value-of select="@output" disable-output-escaping="yes"/></a>
                </div>
        </xsl:if>
</xsl:for-each>
</td>
                      <td><xsl:value-of select="service/@product"/></td>
                      <td><xsl:value-of select="service/@version"/></td>
                      <!--Title-->
                      <td><xsl:choose><xsl:when test="count(script[@id='http-title']/elem[@key='title']) > 0"><i><xsl:value-of select="script[@id='http-title']/elem[@key='title']"/></i></xsl:when><xsl:otherwise><xsl:if test="count(script[@id='http-title']/@output) > 0"><i><xsl:value-of select="script[@id='http-title']/@output"/></i></xsl:if></xsl:otherwise></xsl:choose></td>
                      <!--SSL Cert-->
                      <td>
                        <xsl:if test="count(script/table[@key='subject']/elem[@key='commonName']) > 0">CN: <i><xsl:value-of select="script/table[@key='subject']/elem[@key='commonName']"/></i></xsl:if>
                        <xsl:if test="count(script/table[@key='validity']/elem[@key='notAfter']) > 0"><br/>Expiry: <i><xsl:value-of select="script/table[@key='validity']/elem[@key='notAfter']"/></i></xsl:if>
                        <xsl:if test="count(script/elem[@key='sig_algo']) > 0"><br/>SigAlgo: <i><xsl:value-of select="script/elem[@key='sig_algo']"/></i></xsl:if>
                      </td>
                      <!--URL-->
                      <xsl:choose>
                        <!-- when SSL -->
                        <xsl:when test="count(service/@tunnel) > 0 or service/@name = 'https' or service/@name = 'https-alt'">
                              <td>
                                <xsl:if test="count(../../hostnames/hostname) > 0"><a target="_blank" href="https://{../../hostnames/hostname/@name}:{@portid}"><xsl:value-of select="actionUrl"/>https://<xsl:value-of select="../../hostnames/hostname/@name"/>:<xsl:value-of select="@portid"/></a></xsl:if>
                                <xsl:if test="count(../../hostnames/hostname) = 0"><a target="_blank" href="https://{../../address/@addr}:{@portid}"><xsl:value-of select="actionUrl"/>https://<xsl:value-of select="../../address/@addr"/>:<xsl:value-of select="@portid"/></a></xsl:if>
                              </td>
                        </xsl:when>
                        <!-- when not SSL -->
                        <xsl:otherwise>
                              <td>
                                <xsl:if test="count(../../hostnames/hostname) > 0"><a target="_blank" href="http://{../../hostnames/hostname/@name}:{@portid}"><xsl:value-of select="actionUrl"/>http://<xsl:value-of select="../../hostnames/hostname/@name"/>:<xsl:value-of select="@portid"/></a></xsl:if>
                                <xsl:if test="count(../../hostnames/hostname) = 0"><a target="_blank" href="http://{../../address/@addr}:{@portid}"><xsl:value-of select="actionUrl"/>http://<xsl:value-of select="../../address/@addr"/>:<xsl:value-of select="@portid"/></a></xsl:if>
                              </td>
                        </xsl:otherwise>
                    </xsl:choose>
                    </tr>
                  </xsl:for-each>
                </xsl:for-each>
              </tbody>
            </table>
          </div>

          <h2 id="onlinehosts" class="target">Online Hosts</h2>
          <xsl:for-each select="/nmaprun/host[status/@state='up']">
            <div class="panel panel-default">
              <div class="panel-heading clickable" data-toggle="collapse">
                  <xsl:attribute name="id">onlinehosts-<xsl:value-of select="translate(address/@addr, '.', '-')"/></xsl:attribute>
                  <xsl:attribute name="data-target">#<xsl:value-of select="translate(address/@addr, '.', '-')"/></xsl:attribute>
                <h3 class="panel-title"><xsl:value-of select="address/@addr"/><xsl:if test="count(hostnames/hostname) > 0"> - <xsl:value-of select="hostnames/hostname/@name"/></xsl:if></h3>
              </div>
              <div class="panel-body collapse in">
                <xsl:attribute name="id"><xsl:value-of select="translate(address/@addr, '.', '-')"/></xsl:attribute>
                <xsl:if test="count(hostnames/hostname) > 0">
                  <h4>Hostnames</h4>
                  <ul>
                    <xsl:for-each select="hostnames/hostname">
                      <li><xsl:value-of select="@name"/> (<xsl:value-of select="@type"/>)</li>
                    </xsl:for-each>
                  </ul>
                </xsl:if>
                <h4>Ports</h4>
                <div class="table-responsive">
                  <table class="table table-bordered">
                    <thead>
                      <tr>
                        <th>Port</th>
                        <th>Protocol</th>
                        <th>State<br/>Reason</th>
                        <th>Service</th>
                        <th>Product</th>
                        <th>Version</th>
                        <th>Extra Info</th>
                      </tr>
                    </thead>
                    <tbody>
                      <xsl:for-each select="ports/port">
                        <xsl:choose>
                          <xsl:when test="state/@state = 'open'">
                            <tr class="success">
                              <td title="Port"><xsl:attribute name="id">port-<xsl:value-of select="translate(../../address/@addr, '.', '-')"/>-<xsl:value-of select="@portid"/></xsl:attribute><xsl:value-of select="@portid"/></td>
                              <td title="Protocol"><xsl:value-of select="@protocol"/></td>
                              <td title="State / Reason"><xsl:value-of select="state/@state"/><br/><xsl:value-of select="state/@reason"/></td>
                              <td title="Service"><xsl:if test="count(service/@tunnel) > 0"><xsl:value-of select="service/@tunnel"/>/</xsl:if><xsl:value-of select="service/@name"/></td>
                              <td title="Product"><xsl:value-of select="service/@product"/></td>
                              <td title="Version"><xsl:value-of select="service/@version"/></td>
                              <td title="Extra Info"><xsl:value-of select="service/@extrainfo"/></td>
                            </tr>
                            <tr>
                              <td colspan="7">
                                <a><xsl:attribute name="href">https://nvd.nist.gov/vuln/search/results?form_type=Advanced&amp;cves=on&amp;cpe_version=<xsl:value-of select="service/cpe"/></xsl:attribute><xsl:value-of select="service/cpe"/></a>
                                <xsl:for-each select="script">
                                  <h5><xsl:value-of select="@id"/></h5>
                        	  <xsl:choose>
                            		<xsl:when test="@id='http-screenshot'">
                                		<xsl:value-of select="@output" disable-output-escaping="yes"/>
				</xsl:when>
                            	  	<xsl:otherwise>
                                		<pre style="white-space:pre-wrap; word-wrap:break-word;"><xsl:value-of select="@output"/></pre>
                            	  	</xsl:otherwise>
                        	  </xsl:choose>
                                </xsl:for-each>
                              </td>
                            </tr>
                          </xsl:when>
                          <xsl:when test="state/@state = 'filtered'">
                            <tr class="warning">
                              <td><xsl:value-of select="@portid"/></td>
                              <td><xsl:value-of select="@protocol"/></td>
                              <td><xsl:value-of select="state/@state"/><br/><xsl:value-of select="state/@reason"/></td>
                              <td><xsl:value-of select="service/@name"/></td>
                              <td><xsl:value-of select="service/@product"/></td>
                              <td><xsl:value-of select="service/@version"/></td>
                              <td><xsl:value-of select="service/@extrainfo"/></td>
                            </tr>
                          </xsl:when>
                          <xsl:when test="state/@state = 'closed'">
                            <tr class="active">
                              <td><xsl:value-of select="@portid"/></td>
                              <td><xsl:value-of select="@protocol"/></td>
                              <td><xsl:value-of select="state/@state"/><br/><xsl:value-of select="state/@reason"/></td>
                              <td><xsl:value-of select="service/@name"/></td>
                              <td><xsl:value-of select="service/@product"/></td>
                              <td><xsl:value-of select="service/@version"/></td>
                              <td><xsl:value-of select="service/@extrainfo"/></td>
                            </tr>
                          </xsl:when>
                          <xsl:otherwise>
                            <tr class="info">
                              <td><xsl:value-of select="@portid"/></td>
                              <td><xsl:value-of select="@protocol"/></td>
                              <td><xsl:value-of select="state/@state"/><br/><xsl:value-of select="state/@reason"/></td>
                              <td><xsl:value-of select="service/@name"/></td>
                              <td><xsl:value-of select="service/@product"/></td>
                              <td><xsl:value-of select="service/@version"/></td>
                              <td><xsl:value-of select="service/@extrainfo"/></td>
                            </tr>
                          </xsl:otherwise>
                        </xsl:choose>
                      </xsl:for-each>
                    </tbody>
                  </table>
                </div>
                <xsl:if test="count(hostscript/script) > 0">
                  <h4>Host Script</h4>
                </xsl:if>
                <xsl:for-each select="hostscript/script">
                  <h5><xsl:value-of select="@id"/></h5>
                  <pre style="white-space:pre-wrap; word-wrap:break-word;"><xsl:value-of select="@output"/></pre>
                </xsl:for-each>
                <xsl:if test="count(os/osmatch) > 0">
                  <h4>OS Detection</h4>
                  <xsl:for-each select="os/osmatch">
                    <h5>OS details: <xsl:value-of select="@name"/> (<xsl:value-of select="@accuracy"/>%)</h5>
                    <xsl:for-each select="osclass">
                      Device type: <xsl:value-of select="@type"/><br/>
                      Running: <xsl:value-of select="@vendor"/><xsl:text> </xsl:text><xsl:value-of select="@osfamily"/><xsl:text> </xsl:text><xsl:value-of select="@osgen"/> (<xsl:value-of select="@accuracy"/>%)<br/>
                      OS CPE: <a><xsl:attribute name="href">https://nvd.nist.gov/vuln/search/results?form_type=Advanced&amp;cves=on&amp;cpe_version=<xsl:value-of select="cpe"/></xsl:attribute><xsl:value-of select="cpe"/></a>
                      <br/>
                    </xsl:for-each>
                    <br/>
                  </xsl:for-each>
                </xsl:if>
              </div>
            </div>
          </xsl:for-each>
        </div>
        <footer class="footer">
        </footer>

        <script>
          $(document).ready(function() {
            $('#table-services').DataTable();
            $("a[href^='#onlinehosts-']").click(function(event){     
                event.preventDefault();
                $('html,body').animate({scrollTop:($(this.hash).offset().top-60)}, 500);
            });
            $("a[href^='#']").not("[href='#']").not("[href^='#onlinehosts-']").on('click', function(event) {
                var target = $(this.getAttribute('href'));
                if (target.length) {
                    event.preventDefault();
                    $('html, body').animate({ scrollTop: target.offset().top - 60 }, 400);
                }
            });
          });
          $('#table-services').DataTable( {
            "lengthMenu": [ [10, 25, 50, 100, -1], [10, 25, 50, 100, "All"] ],
            "pageLength": -1, 
            "order": [[ 0, 'desc' ]],
            "columnDefs": [
              { "targets": [0], "orderable": true },
              { "targets": [1], "type": "ip-address" },
            ],
            dom:'lBfrtip', 
            stateSave: true,
            buttons: [
                {
                    extend: 'copyHtml5',
                    exportOptions: { orthogonal: 'export' }
                },
                {
                    extend: 'csvHtml5',
                    exportOptions: { orthogonal: 'export' }
                },
                {
                    extend: 'excelHtml5',
                    exportOptions: { orthogonal: 'export' },
                    autoFilter: true,
                    title: '',
                },
                {
                    extend: 'pdfHtml5',
                    orientation: 'landscape',
                    pageSize: 'LEGAL',
                    download: 'open',
                    exportOptions: {
                      columns: [ 0,1,2,3,4,5,6,7,8 ]
                    }
                }
            ],
          });
        </script>
        <script>      
          $(document).ready(function() {
            $('#web-services').DataTable();
          });
          $('#web-services').DataTable( {
            "lengthMenu": [ [10, 25, 50, 100, -1], [10, 25, 50, 100, "All"] ],
            "pageLength": -1,
            "order": [[ 0, 'desc' ]],
            "columnDefs": [
              { "targets": [0], "orderable": true },
              { "targets": [1], "type": "ip-address" },
            ],
            dom:'lBfrtip', 
            stateSave: true,
            buttons: [
                {
                    extend: 'copyHtml5',
                    exportOptions: { orthogonal: 'export' }
                },
                {
                    extend: 'csvHtml5',
                    exportOptions: { orthogonal: 'export' }
                },
                {
                    extend: 'excelHtml5',
                    exportOptions: { orthogonal: 'export' },
                    autoFilter: true,
                    title: '',
                },
                {
                    extend: 'pdfHtml5',
                    orientation: 'landscape',
                    pageSize: 'LEGAL',
                    download: 'open',
                    exportOptions: {
                      columns: [ 0,1,2,3,4,5,6,7,8 ]
                    }
                }
            ],
          });
        </script>      
        <script>
          $(document).ready(function() {
            $('#table-overview').DataTable();
          });
          $('#table-overview').DataTable( {
            "lengthMenu": [ [5, 10, 25, 50, 100, -1], [5, 10, 25, 50, 100, "All"] ],
            "pageLength": -1,
            "columnDefs": [
              { "targets": [1], "type": "ip-address" },
            ],
          });
        </script>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>

