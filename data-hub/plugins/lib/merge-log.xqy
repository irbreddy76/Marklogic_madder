xquery version "1.0-ml";

declare variable $merge-log as map:map external;
declare variable $permissions as element(permissions) external;

xdmp:document-insert("/merges/" || xdmp:hash64(xdmp:to-json-string($merge-log)) || ".json", 
  xdmp:to-json($merge-log), $permissions/*
)