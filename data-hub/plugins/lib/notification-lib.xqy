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

declare variable $XSL-FO-SERVER := "127.0.0.1";
declare variable $XSL-FO-PORT := "8080";
declare variable $PDF-STRATEGY := "xsl-fo";
declare variable $XSL-FO-AUTHENTICATION := ();

declare variable $globalmap := map:map();
declare variable $xsl-fo-transform := "/app/xslt/ApprovalNoticeForABAWD.xsl";

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

declare function notify:pdf-create(
  $node as node(),
  $appId as xs:string,
  $ezAppId as xs:string,
  $extramap as map:map?) as element()
{
  let $_ :=
    for $k in map:keys($extramap)
    return
      map:put($globalmap, $k, map:get($extramap, $k))
  let $_ := map:put($globalmap, "appId", $appId)
  let $_ := map:put($globalmap, "ezAppId", $ezAppId)
  let $account-id := map:get($globalmap, "actrId")
  let $_ :=
    xdmp:log(
      fn:concat("Attempting transform for PDF creation for FFM App ID: ",
                $appId,
                "; EZAppID: ",
                $ezAppId),
      "info")
  return
    notify:transform-pdf-dispatch($node)
};

declare function notify:transform-pdf-dispatch($node as node()) as element() {
  typeswitch($node)
    case text() return
      $node
    case element(at-exch:AccountTransferRequest) return
      notify:account-transfer($node)
    case element() return
      $node
    default return
      notify:passthru($node)
};

declare function notify:transform-notice-transfer-fo($node as element(at-exch:AccountTransferRequest)) as element() {
  let $xslt-params := map:map()
  let $put := map:put($xslt-params, “notice-details”, $node)
  let $transform :=
    try {
      xdmp:xslt-invoke($xsl-fo-transform, document{$node}, $xslt-params)/fo:root
    } catch($e) {
      ($e, xdmp:log($e, "error"))
    }
  let $_ := xdmp:log($transform, "info")
  return $transform
};

declare function notify:account-transfer(
  $node as element(at-exch:AccountTransferRequest)) as element()
{
  let $ezappid := map:get($globalmap, "ezAppId")
  let $appId := map:get($globalmap, "appId")
  let $activity-id := map:get($globalmap, "actrId")
  let $_ :=
    xdmp:log(
      fn:concat(
        "Attempting AT transform for PDF creation for FFM App ID: ",
        $appId,
        "; EZAppID: ",
        $ezappid,
        " ACTR ID: ",
        $activity-id),
      "info")
  let $strategy := $http-config/http:account-transfer/@strategy/fn:string()
  let $myconfig := $http-config/http:account-transfer/http:strategy[@name eq $strategy]
  let $host := $myconfig/http:endpoint
  let $_ :=
    xdmp:log(
      fn:concat(
        "Generating ",
        $strategy,
        " PDF transform output for Account Transfer ActivityIdentification: ",
        $activity-id,
        "; EZAppID: ",
        $ezappid,
        "; FFM AppID: ",
        $appId),
      "info")
  return
    if ($strategy eq "xsl-fo") then
      let $transform := notify:transform-notice-transfer-fo($node)
      return
        if ($transform instance of element(error:error)) then
        (
          xdmp:log(
            fn:concat("Error in generation XSL:FO/PDF output for human readable
                       Account Transfer save with ActivityIdentification ",
              $activity-id),
            "error"),
          $transform
        )
        else
          let $inserttransform := notify:insert(fn:concat("/", $ezappid, "/xslfo"), $transform)
          let $_ := xdmp:log("Created Account Transfer XSL:FO for EZAppID: "||$ezappid, "info")
          let $_ := xdmp:log("Sending XSL:FO to FOPServlet for EZAppID: "||$ezappid, "info")
          let $options :=
            <options xmlns="xdmp:http">
              {$XSL-FO-AUTHENTICATION}
              <data>{xdmp:quote($transform)}</data>
              <headers>
                <X-AT-PDF-EZAppID>{$ezappid}</X-AT-PDF-EZAppID>
                <X-AT-PDF-AppID>{$appId}</X-AT-PDF-AppID>
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
              let $pdfuri := fn:concat("/", $ezappid, "/pdf")
              let $insertpdf := notify:insert($pdfuri, $request[2]/binary())
              let $_ := xdmp:log(fn:concat("Created Account Transfer XSL:FO PDF for EZAppID: ", $ezappid), "info")
              (:
              let $sidecar := atnotify:get-pdf-sidecar($ezappid, $appId, $node, $pdfuri)
        let $insertside := notify:insert(fn:concat("/", $ezappid, "/sidecar"), $sidecar)
        let $_ := xdmp:log(fn:concat("Created Account Transfer PDF sidecar XML for EZAppID: ", $ezappid), "info")
        :)
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

declare private function notify:passthru($nodes as node()*) as item()* {
  for $node in $nodes/node()
  return
    notify:transform-pdf-dispatch($node)
};

declare private function notify:insert(
  $uri as xs:string,
  $node as node()) as empty-sequence()
{
  xdmp:document-insert($uri, $node, xdmp:default-permissions(), "ezat")
};

declare function notify:http-process-response(
  $request as node()+,
  $ezappid as xs:string,
  $method as xs:string) as node()+
{
  let $thismethod :=
    if (fn:matches($method, "(GET|POST|PUT|HEAD)", "i")) then
      $method
    else
      "request"
  return
    if ($request instance of element(error:error)) then
      let $_ := xdmp:log($request, "error")
      return $request
    else
      let $headers := $request[1]
      let $body := $request[2]
      let $status := $headers/http:code/fn:string()
      let $content-type := $headers/http:headers/http:content-type
      let $_ :=
        xdmp:log(
          fn:concat(
            "HTTP ", $thismethod, " received status ", $status,
            " with Content-Type ", fn:normalize-space($content-type),
            " for EZAppID ",$ezappid, " request to ALC Service"),
          "info")
      return
        if ($status ne "200") then
          let $_ := xdmp:log($body, "error")
          return
            <error:error/>
        else
          ($content-type, $body)
};