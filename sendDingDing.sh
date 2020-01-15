#!/bin/sh
SIGN_KEY="YOUR-KEY";
WEB_HOOK="https://oapi.dingtalk.com/robot/send?access_token=YOUR-TOKEN";
#$1=url
URLEncode() {
  local string="${1}"
  local strlen=${#string}
  local encoded=""
  local pos c o
  for (( pos=0 ; pos<strlen ; pos++ )); do
     c=${string:$pos:1}
     case "$c" in
        [-_.~a-zA-Z0-9] ) o="${c}" ;;
        * )	printf -v o '%%%02X' "'$c"
     esac
     encoded+="${o}"
  done
  echo "${encoded}"
}
#$1-str,$2-key
HMACSHA256(){
	echo -ne "$1" | openssl dgst -sha256 -hmac "$2" -binary | base64
}
#$1-message,$2-secret
SendMessage(){
	local ts=$[$(date +%s%N)/1000000];
	local str2Sign="$ts\n$2";
	local sign=$(HMACSHA256 "$str2Sign" "$2");
	local encodeSign=$(URLEncode "$sign");
	curl -vvvvvv "${WEB_HOOK}&timestamp=$ts&sign=$encodeSign" \
   -H 'Content-Type: application/json' \
   -d "$1"	
}
SendMessage '{"msgtype":"text","text":{"content":"send message to dingding by shell."}}' "$SIGN_KEY"
