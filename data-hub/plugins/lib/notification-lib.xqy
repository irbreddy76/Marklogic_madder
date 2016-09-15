xquery version "1.0-ml";

module namespace notify = "http://marklogic.com/notification-service";
declare namespace at-exch = "http://at.dsh.cms.gov/exchange/1.0";

(:
import module namespace c = "http://marklogic.com/roxy/config"
  at "/app/config/config.xqy";

import module namespace sm = "http://marklogic.com/ps/servicemetrics"
  at "/modules/marklogic/servicemetrics/servicemetrics.xqy";

import module namespace atnotify = "http://notify.ezapp.cms.gov/at/"
  at "/app/models/lib-notify-at.xqy";

declare namespace hix-core = "http://hix.cms.gov/0.1/hix-core";
declare namespace nc = "http://niem.gov/niem/niem-core/2.0";
declare namespace at-exch = "http://at.dsh.cms.gov/exchange/1.0";
declare namespace at-ext = "http://at.dsh.cms.gov/extension/1.0";
declare namespace s = "http://niem.gov/niem/structures/2.0";
declare namespace hix-ee = "http://hix.cms.gov/0.1/hix-ee";
declare namespace st = "info:dsh/at/states";
:)

declare default element namespace "info:md/dhr/abawd/notices#";

declare namespace local = "local";
declare namespace http = "xdmp:http";
declare namespace fo = "http://www.w3.org/1999/XSL/Format";
declare namespace an = "info:md/dhr/abawd/notices#";

declare variable $XSL-FO-SERVER := "10.88.186.20";
declare variable $XSL-FO-PORT := "8080";
declare variable $PDF-STRATEGY := "xsl-fo";
declare variable $XSL-FO-AUTHENTICATION := ();

declare variable $globalmap := map:map();
declare variable $xsl-fo-transform := "/ABAWD-Notice-xsl/AppointmentNoticeForABAWD.xsl";

declare variable $XSL-FO-URL :=
  "http://" || $XSL-FO-SERVER || ":" || $XSL-FO-PORT || "/fop/rest/converter";

declare variable $http-config :=
  <http-config xmlns="xdmp:http">
    <notify strategy="{$PDF-STRATEGY}">
      <strategy name="xsl-fo">
        <endpoint>{$XSL-FO-URL}</endpoint>
      </strategy>
    </notify>
  </http-config>;


declare option xdmp:mapping "false";

declare function notify:xml-create($params  as map:map) as element(an:abawd-notices)
{
  let $noticeType := map:get($params, "noticeType")
  let $notificationCore := 
    <an:notification-core>
        <an:LDSS>{map:get($params, "LDSS")}</an:LDSS>
        <an:LDSS-Address>{map:get($params, "LDSS-Address")}</an:LDSS-Address>
        <an:notice-date>{map:get($params, "notice-date")}</an:notice-date>
        <an:clientID>{map:get($params, "clientID")}</an:clientID>
        <an:clientLanguagePreferenceCode>{map:get($params, "clientLanguagePreferenceCode")}</an:clientLanguagePreferenceCode>
        <an:recipient-name>{map:get($params, "recipient-name")}</an:recipient-name>
        <an:recipient-mailing-address1>{map:get($params, "recipient-mailing-address1")}</an:recipient-mailing-address1>
        <an:recipient-mailing-address2>{map:get($params, "recipient-mailing-address2")}</an:recipient-mailing-address2>
    </an:notification-core>
   let $notice := 
    if ($noticeType = "ApprovalNotice") then
    <an:notice xsi:type='{$noticeType}'>
        <an:approval-date>{map:get($params, "approval-date")}</an:approval-date>
        <an:receive-begin-amount>{map:get($params, "receive-begin-amount")}</an:receive-begin-amount>
        <an:receive-end-amount>{map:get($params, "receive-end-amount")}</an:receive-end-amount>
        <an:monthYear-begin>{map:get($params, "monthYear-begin")}</an:monthYear-begin>
        <an:monthYear-end>{map:get($params, "monthYear-end")}</an:monthYear-end>
    </an:notice>
    else if ($noticeType = "AppointmentNotice") then
    <an:notice xsi:type='{$noticeType}'>
        <an:appointment-dateTime>{map:get($params, "appointment-dateTime")}</an:appointment-dateTime>
        <an:telephone-contact-number>{map:get($params, "telephone-contact-number")}</an:telephone-contact-number>
    </an:notice> 
    else if ($noticeType = "ChangeNotice") then
    <an:notice xsi:type='{$noticeType}'>
        <an:nil/>
    </an:notice>   
    else if ($noticeType = "CaseClosureNotice") then
    <an:notice xsi:type='{$noticeType}'>
      <an:case-closure-date>{map:get($params, "case-closure-date")}</an:case-closure-date>
    </an:notice>      
    else if ($noticeType = "ReapplicationDenialNotice") then
    <an:notice xsi:type='{$noticeType}'>
        <an:application-date>{map:get($params, "application-date")}</an:application-date>
        <an:telephone-contact-number>{map:get($params, "telephone-contact-number")}</an:telephone-contact-number>
    </an:notice>  
    else if ($noticeType = "WarningNoticeMonth-1") then
    <an:notice xsi:type='{$noticeType}'>
        <an:nil/>
    </an:notice>   
    else if ($noticeType = "WarningNoticeMonth-2") then
    <an:notice xsi:type='{$noticeType}'>
        <an:provide-proof-date>{map:get($params, "provide-proof-date")}</an:provide-proof-date>
    </an:notice>              
    else ()   
    return 
      <an:abawd-notices xmlns:an="info:md/dhr/abawd/notices#" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
        {$notificationCore}
        {$notice} 
      </an:abawd-notices>
};

declare function notify:echo-parameters($params as map:map)
{
  let $result := "Parmaters Passed:"
  let $inputParams := fn:concat($result,map:get($params, "LDSS"),":",
    map:get($params, "LDSS-Address"),":",
    map:get($params, "notice-date"),":",
    map:get($params, "clientID"),":",
    map:get($params, "clientLanguagePreferenceCode"),":",
    map:get($params, "recipient-name"),":",
    map:get($params, "recipient-mailing-address1"),":",
    map:get($params, "recipient-mailing-address2"),":",
    map:get($params, "noticeType"))
  return $inputParams
};

declare function notify:pdf-create($node as node(), 
          $noticeType as xs:string, $clientId as xs:string) as element() {
  typeswitch($node)
    case text() return
      $node
    case element(an:abawd-notices) return
      notify:notice-transfer($node, $noticeType, $clientId)
    case element() return
      $node
    default return
      notify:passthru($node, $noticeType, clientId)
};

declare function notify:transform-notice-transfer-fo($node as element(an:abawd-notices)) as element() {
  let $xslt-params := map:map()
  let $put := map:put($xslt-params, "notice-details", $node)
  let $transform :=
    try {
      (: xdmp:xslt-eval(fn:doc($xsl-fo-transform)/node(), document{$node}, $xslt-params)/fo:root :)
      xdmp:xslt-invoke($xsl-fo-transform, document{$node}, $xslt-params)/fo:root
    } catch($e) {
      ($e, xdmp:log($e, "error"))
    }
  let $_ := xdmp:log($transform, "info")
  return $transform
};

declare function notify:notice-transfer(
  $node as element(an:abawd-notices), $noticeType as xs:string, $clientId as xs:string) as element()
{
  let $_ :=
    xdmp:log(
      fn:concat(
        "Attempting AT transform for PDF creation for Notices: ",
        $noticeType),
      "info")
  let $strategy := $http-config/http:notify/@strategy/fn:string()
  let $myconfig := $http-config/http:notify/http:strategy[@name eq $strategy]
  let $host := $myconfig/http:endpoint
  let $_ :=
    xdmp:log(
      fn:concat(
        "Generating ",
        $strategy,
        " PDF transform output for Notice Transfer: ",
        $noticeType),
      "info")
  return
    if ($strategy eq "xsl-fo") then
      let $transform := notify:transform-notice-transfer-fo($node)
      return
        if ($transform instance of element(error:error)) then
        (
          xdmp:log(
            fn:concat("Error in generation XSL:FO/PDF output for human readable
                       Notice Transfer save with Notice Type ",
              $noticeType),
            "error"),
          $transform
        )
        else
          (: let $inserttransform := notify:insert(fn:concat("/", $ezappid, "/xslfo"), $transform) :)
          let $_ := xdmp:log("Created Notice Transfer XSL:FO for Notice Type: "||$noticeType, "info")
          let $_ := xdmp:log("Sending XSL:FO to FOPServlet for Notice Type: "||$noticeType, "info")
          let $options :=
            <options xmlns="xdmp:http">
              {$XSL-FO-AUTHENTICATION}
              <data>{xdmp:quote($transform)}</data>
              <headers>
                <content-type>text/xml</content-type>
              </headers>
            </options>
          let $request :=
            try {
              xdmp:http-post($host, $options)
            }
            catch($e) {
              $e,
              xdmp:log($e, "error")
            }
          let $_ := xdmp:log($request)
          let $response :=
            if ($request instance of element(error:error)) then
              $request
            else
              let $pdfuri := fn:concat("/ABAWD-notices/", $noticeType, "/", $clientId, ".pdf")
              let $insertpdf := notify:insert($pdfuri, $request[2]/binary())
              let $_ := xdmp:log(fn:concat("Created Notice Transfer XSL:FO PDF for Notice Type: ", $noticeType), "info")
        return
        $transform
          return
            $transform
    else
      let $msg := "PDF creation strategy must be &quot;alc&quot; or &quot;xsl-fo.&quot;"
      let $_ := xdmp:log($msg, "error")
      return
        fn:error(xs:QName("PDF_CREATION_STRATEGY_ERROR"), $msg)
};

declare private function notify:passthru($nodes as node()*, 
      $noticeType as xs:string, $clientId as xs:string) as item()* {
  for $node in $nodes/node()
  return
    notify:pdf-create($node, $noticeType, $clientId)
};

declare private function notify:insert(
  $uri as xs:string,
  $node as node()) as empty-sequence()
{
  xdmp:document-insert($uri, $node, xdmp:default-permissions(), "ABAWD-Notice")
};