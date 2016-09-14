xquery version "1.0-ml";

module namespace resource = "http://marklogic.com/rest-api/resource/notification";

import module namespace notify = "http://marklogic.com/notification-service" at
  "/lib/notification-lib.xqy";

import module namespace json="http://marklogic.com/xdmp/json" at "/MarkLogic/json/json.xqy"; 

declare namespace rapi= "http://marklogic.com/rest-api"; 


declare function get(
  $context as map:map,
  $params  as map:map
  ) as document-node()*
{
  fn:error((), "RESTAPI-SRVEXERR", (405, "Method Not Allowed", "GET is not implemented"))
};

declare function put(
  $context as map:map,
  $params  as map:map,
  $input   as document-node()*
  ) as document-node()?
{
  fn:error((), "RESTAPI-SRVEXERR", (405, "Method Not Allowed", "PUT is not implemented"))
};

(: POST Parameters
    Notification Core Parameters
    rs:LDSS
    rs:LDSS-Address
    rs:notice-date
    rs:clientID
    rs:clientLanguagePreferenceCode
    rs:recipient-name
    rs:recipient-mailing-address1
    rs:recipient-mailing-address2

    Notice Parameters for noticeType = AppointmentNotice
    rs:appointment-dateTime
    rs:telephone-contact-number   

    Notice Parameters for noticeType = ApprovalNotice
    rs:noticeType
    rs:approval-date
    rs:receive-begin-amount
    rs:receive-end-amount
    rs:monthYear-begin
    rs:monthYear-end

    Notice Parameters for noticeType = CaseClosureNotice
    rs:case-closure-date

    Notice Parameters for noticeType = ChangeNotice
    rs:nil  

    Notice Parameters for noticeType = ReapplicationDenialNotice
    rs:application-date
    rs:telephone-contact-number

    Notice Parameters for noticeType = WarningNoticeMonth-1
    rs:nil   

    Notice Parameters for noticeType = WarningNoticeMonth-2
    rs:provide-proof-date       
:)
declare %rapi:transaction-mode("update") function post(
  $context as map:map,
  $params  as map:map,
  $input   as document-node()*
  ) as document-node()*
{
  try {
    map:put($context, "output-types", "application/xml"),
    xdmp:set-response-code(200, "Ok"),
    let $noticeType := map:get($params, "noticeType")
    (: let $result := notify:echo-parameters($params) 
    return xdmp:to-json($result) :)
    let $result := notify:xml-create($params)
    return document{$result}
  } catch($e) {
    map:put($context, "output-types", "text/plain"),
    xdmp:set-response-code(500, "Error"),
    xdmp:log($e, "error"),
    document{ "An unexpected error has occurred.  Check logs for details" }
  }
};

declare function delete(
  $context as map:map,
  $params  as map:map
  ) as document-node()?
{
  fn:error((), "RESTAPI-SRVEXERR", (405, "Method Not Allowed", "DELETE is not implemented"))
};
